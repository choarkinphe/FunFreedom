//
//  FunFreedom+Cache.swift
//  FunFreedom
//
//  Created by choarkinphe on 2019/9/12.
//  Copyright © 2019 whyq_dxj. All rights reserved.
//

import Foundation

public extension FunFreedom {
    
    func cache_request(config: FunFreedom.RequestConfig, response: Data?) {
        ResponseCache.cache_request(config: config, response: response)
    }
    
    func remove_request(config: FunFreedom.RequestConfig) {
        ResponseCache.remove_request(config: config)
    }
    
    func load_request(config: FunFreedom.RequestConfig) -> Data? {
        return ResponseCache.load_request(config: config)
    }
    
}

private extension ResponseCache {
    
    static func cache_request(config: FunFreedom.RequestConfig, response: Data?) {
        guard let key_str = format_key(config: config) else { return }
        
        cache(key: key_str, data: response)
        
        debugPrint("cache_request=",config.urlString ?? "")
    }
    
    static func remove_request(config: FunFreedom.RequestConfig) {
        guard let key_str = format_key(config: config) else { return }
        
        removeCache(key: key_str)
        
        debugPrint("remove_request=",config.urlString ?? "")
    }
    
    static func load_request(config: FunFreedom.RequestConfig) -> Data? {
        guard let key_str = format_key(config: config),
            let cache_data = loadCache(key: key_str),
            let cache_time = cache_data.cache_time
            else { return nil}
        let load_time = Date().timeIntervalSince1970
        if (load_time - cache_time) > config.cacheTimeOut {
            debugPrint("cache_timeOut=",config.urlString ?? "")
            removeCache(key: key_str)
            return nil
        }
        debugPrint("load_request=",config.urlString ?? "")
        
        return cache_data.data as? Data
    }
    
    private static func format_key(config: FunFreedom.RequestConfig) -> String? {
        guard let url = config.urlString else { return nil}
        var key = url
        
        if let params = config.params, let data = try? JSONSerialization.data(withJSONObject: params, options: []), let params_string = String(data: data, encoding: String.Encoding.utf8) {
            key = key + params_string
        }
        
        return "\(key.hashValue)"
    }
}
