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
    
    private var cachePool = [String: Any]()
    
    static var shared: ResponseCache {
        
        return Static.instance
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    static func cache(key: String?, data: Any?) {
        guard let key = key else { return }
        guard let data = data else { return }
        
        shared.cachePool[key] = data
        
    }
    
    static func loadCache(key: String?) -> Any? {
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
