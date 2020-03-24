//
//  ResponseCache.swift
//  ResponseCache
//
//  Created by choarkinphe on 2019/9/9.
//  Copyright © 2019 whyq_dxj. All rights reserved.
//

import Foundation
import CommonCrypto

fileprivate let FunCachePathName = "com.funfreedom.funcache"

public extension FunFreedom {
    class Cache {
        
        private struct Static {
            
            static var instance_cache: Cache = Cache.init(path: nil)
        }
        
        static var `default`: Cache {
            
            return Static.instance_cache
        }
        
        init(path: String?) {
            if let path = path {
                diskCachePath = path
            }
            
        }
        
        private var memoryCache = NSCache<NSString,NSData>()
        // 生成默认的缓存路径
        private var diskCachePath: String? = {
            if let directoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
                
                return directoryPath + "/\(FunCachePathName)"
            }
            
            return nil
        }()
        private var ioQueue = DispatchQueue.init(label: "com.funfreedom.cache_io")
        private var fileManager = FileManager.default
        // 默认缓存时效为1周
        var cacheTimeOut: TimeInterval = 604800
        
        private class CacheData: Codable {
            var data: Data? // 缓存数据
            var invalid_time: TimeInterval? // 失效时间
            
            private enum CodingKeys: String,CodingKey {
                case data
                case invalid_time
            }
            
            init(data: Data?, invalid_time: TimeInterval?) {
                self.data = data
                self.invalid_time = invalid_time
            }
            
            required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                data = try container.decode(Data.self, forKey: .data)
                invalid_time = try container.decode(TimeInterval.self, forKey: .invalid_time)
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(data, forKey: .data)
                try container.encode(invalid_time, forKey: .invalid_time)
            }
        }
        
        public func cache(key: String?, data: Data?, timeOut: TimeInterval? = nil) {
//            weak var weakSelf = self
            ioQueue.async {
                // 获取保存地址，判断缓存数据是否存在
                guard let a_data = data, let cachePath = self.cachePathForKey(key: key) else { return }
                
                // 获取当前时间
                let load_time = Date().timeIntervalSince1970
                // 创建真实的缓存模型（直接算出时效时间，并存储） * 优先存储传入的有效期，没有再读取默认值
                let cacheModel = CacheData.init(data: a_data, invalid_time: Date().timeIntervalSince1970 + (timeOut ?? self.cacheTimeOut))
                // 获取缓存key
//                let cacheKey = cachePath.absoluteString
                // 获取真实的Data
                let encoder = JSONEncoder()
                
                do {
                    let cacheData = try encoder.encode(cacheModel)
                    // 放进缓存池
                    self.memoryCache.setObject(cacheData as NSData, forKey: NSString(string: cachePath))
                    // 写入
                    if let diskCachePath = self.diskCachePath {
                        if !self.fileManager.fileExists(atPath: diskCachePath) {
                            try self.fileManager.createDirectory(atPath: diskCachePath, withIntermediateDirectories: true, attributes: nil)
                        }
//                        try cacheData.write(to: URL(fileURLWithPath: cachePath), options: .atomic)
                        if !NSKeyedArchiver.archiveRootObject(cacheData, toFile: cachePath) {
                            debugPrint("FunFreedomCache: archive failed")
                        }
                    }

                } catch let error {
                    debugPrint("FunFreedomCache: \(error.localizedDescription)")
                }
            }
            
        }
        
        public func containsData(key: String?) -> Bool {
            guard let cachePath = self.cachePathForKey(key: key) else { return false }
            
            var exists = fileManager.fileExists(atPath: cachePath)
            
            if !exists, let diskCachePath = self.diskCachePath {
                exists = fileManager.fileExists(atPath: diskCachePath)
            }
            
            return exists
        }
        
        public func loadCache(key: String?) -> Data? {
            
            guard let cachePath = self.cachePathForKey(key: key), containsData(key: key) else { return nil }
            
            // 获取内存缓存
            if let cacheData = memoryCache.object(forKey: NSString(string: cachePath)) as? Data {
                return proving(key: key, data: cacheData)
            }
            // 读取磁盘缓存
            if let cacheData = NSKeyedUnarchiver.unarchiveObject(withFile: cachePath) as? Data {
                return proving(key: key, data: cacheData)
                
            }
            
            return nil
        }
        
        // 验证程序（判断有效期，或者拓展其他）
        private func proving(key: String?, data: Data) -> Data? {
            
            let decoder = JSONDecoder()
            // 解码数据
            if let cacheModel = try? decoder.decode(CacheData.self, from: data) {
                // 获取当前时间
                let load_time = Date().timeIntervalSince1970
                // 失效时间在当前时间以前,删除当前数据，且不返回数据
                if let invalid_time = cacheModel.invalid_time, invalid_time < load_time {
                    
                    removeCache(key: key)
                    
                    return nil
                }
                return cacheModel.data
            }
            
            return nil
        }
        
        // 删除指定的缓存数据
        public func removeCache(key: String?) {
            weak var weakSelf = self
            ioQueue.async {
                guard let cachePath = self.cachePathForKey(key: key), let cacheTool = weakSelf else { return }
                // 获取真实key与文件路径
//                let cacheKey = cachePath.absoluteString
                // 删除memory缓存
                cacheTool.memoryCache.removeObject(forKey: NSString(string: cachePath))
                // 删除磁盘缓存
                try? cacheTool.fileManager.removeItem(atPath: cachePath)
            }
            
        }
        
        // 清除所有缓存
        public func removeAllCache() {
            weak var weakSelf = self
            ioQueue.async {
                if let cacheTool = weakSelf, let cachePath = weakSelf?.diskCachePath {
                    // 清空缓存池
                    cacheTool.memoryCache.removeAllObjects()
                    // 清空磁盘
                    try? cacheTool.fileManager.removeItem(atPath: cachePath)
                }
            }
        }
        
        // 计算本地缓存的大小
        public var totalSize: Int
        {
            guard let diskCachePath = diskCachePath else {
                return 0
            }
            
            var size = 0
            if let fileEnumerator = fileManager.enumerator(atPath: diskCachePath) {
                for file in fileEnumerator {
                    if let fileName = file as? String {
                        let filePath = diskCachePath + "/\(fileName)"
                        if let attrs = try? fileManager.attributesOfItem(atPath: filePath) {
                            size = attrs.count + size
                        }
                    }
                    
                    
                }
            }
            
            return size
        }
        
        // 将key进行一次md5，拼接最终储存路径（防止key过长与重复）
        private func cachePathForKey(key: String?) -> String? {
            
            if let fileName = key?.md5, let cachePath = diskCachePath {
                
                return cachePath + "/\(fileName)"
            }
            
            return nil
        }
        
        
    }
    
}

extension String {
    var md5:String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02X", $1)
            
        }
    }
}
