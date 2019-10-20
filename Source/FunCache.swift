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
        
        private var cachePool = [String: CacheData]()
        
        init() {
            NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        }
        
        public struct CacheData {
            var data: Any?
            var cache_time: TimeInterval?
        }
        
        public func cache(key: String?, data: Any?) {
            guard let key = key else { return }
            guard let data = data else { return }
            
            let cacheData = CacheData.init(data: data, cache_time: Date().timeIntervalSince1970)
            
            cachePool[key] = cacheData
            
        }
        
        public func loadCache(key: String?) -> CacheData? {
            guard let key = key else { return nil }
            if let data = cachePool[key] {
                return data
            }
            
            return nil
        }
        
        public func removeCache(key: String?) {
            guard let key = key else { return }
            
            cachePool.removeValue(forKey: key)
        }
        
        @objc private func didReceiveMemoryWarning() {
            
            cachePool.removeAll()
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        }
    }
}
