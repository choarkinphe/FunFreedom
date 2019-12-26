//
//  ResponseCache.swift
//  ResponseCache
//
//  Created by choarkinphe on 2019/9/9.
//  Copyright © 2019 whyq_dxj. All rights reserved.
//

import Foundation
public extension FunFreedom {
    class Cache {
        
        private var cachePool = NSCache<NSString,NSDictionary>()
        
        public struct CacheData<T> {
            public var data: T?
            public var cache_time: TimeInterval?
        }
        
        public func cache(key: String?, data: Any?) {
            guard let key = key else { return }
            guard let data = data else { return }
            
            let cacheData = CacheData.init(data: data, cache_time: Date().timeIntervalSince1970)
            
            let cacheKey = NSString.init(string: key)
            let cacheDict = NSDictionary.init(object: cacheData, forKey: cacheKey)
            
            cachePool.setObject(cacheDict, forKey: cacheKey)
        }
        
        public func loadCache(key: String?) -> CacheData<Any>? {
            guard let key = key else { return nil }
            let cacheKey = NSString.init(string: key)
            if let cacheDict = cachePool.object(forKey: cacheKey), let data = cacheDict.object(forKey: cacheKey) {
                return data as? CacheData
            }
            
            return nil
        }
        
        public func loadCache<T>(type: T.Type, key: String?) -> CacheData<T>? {
            guard let key = key else { return nil }
            let cacheKey = NSString.init(string: key)
            if let cacheDict = cachePool.object(forKey: cacheKey), let data = cacheDict.object(forKey: cacheKey) {
                return data as? CacheData<T>
            }
            
            return nil
        }
        
        public func removeCache(key: String?) {
            guard let key = key else { return }
            let cacheKey = NSString.init(string: key)
            cachePool.removeObject(forKey: cacheKey)
        }
        
        public func removeAllCache() {

            cachePool.removeAllObjects()
        }

    }
}
