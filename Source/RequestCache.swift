//
//  ResponseCache.swift
//  ResponseCache
//
//  Created by choarkinphe on 2019/9/9.
//  Copyright © 2019 whyq_dxj. All rights reserved.
//

import Foundation

class ResponseCache {
    
    private struct Static {
        
        static var instance: ResponseCache = ResponseCache()
        
    }
    
    private var cachePool = [String: CacheData]()
    
    static var shared: ResponseCache {
        
        return Static.instance
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    public struct CacheData {
        var data: Any?
        var cache_time: TimeInterval?
    }
    
    static func cache(key: String?, data: Any?) {
        guard let key = key else { return }
        guard let data = data else { return }
        
        let cacheData = CacheData.init(data: data, cache_time: Date().timeIntervalSince1970)
        
        shared.cachePool[key] = cacheData
        
    }
    
    static func loadCache(key: String?) -> CacheData? {
        guard let key = key else { return nil }
        if let data = shared.cachePool[key] {
            return data
        }
        
        return nil
    }
    
    static func removeCache(key: String?) {
        guard let key = key else { return }
        
        shared.cachePool.removeValue(forKey: key)
    }
    
    @objc private func didReceiveMemoryWarning() {
        
        cachePool.removeAll()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
}
