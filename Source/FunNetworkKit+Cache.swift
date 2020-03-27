//
//  FunFreedom+Cache.swift
//  FunFreedom
//
//  Created by choarkinphe on 2019/9/12.
//  Copyright © 2019 whyq_dxj. All rights reserved.
//

import Foundation
public extension FunFreedom.NetworkKit {
    
    func cache_request(session: FunFreedom.RequestSession, response: Data?) {
        FunFreedom.networkManager.request_cache.cache_request(session: session, response: response)
    }
    
    func remove_request(session: FunFreedom.RequestSession) {
        FunFreedom.networkManager.request_cache.remove_request(session: session)
    }
    
    func remove_request(identifier: String?) {
        FunFreedom.networkManager.request_cache.remove_request(identifier: identifier)
    }
    
    func load_request(session: FunFreedom.RequestSession) -> Data? {
        return FunFreedom.networkManager.request_cache.load_request(session: session)
    }
    
    
}

private extension FunFreedom.Cache {
    // 缓存
    func cache_request(session: FunFreedom.RequestSession, response: Data?) {
        guard let key_str = session.identifier else { return }
        
        cache(key: key_str, data: response, timeOut: session.cacheTimeOut)
        
        debugPrint("cache_request=",session.urlString ?? "")
    }
    // 按完整请求信息删除对应缓存
    func remove_request(session: FunFreedom.RequestSession) {
        guard let key_str = session.identifier else { return }
        
        removeCache(key: key_str)
        
        debugPrint("remove_request=",session.urlString ?? "")
    }
    // 按标识符删除对应的缓存
    func remove_request(identifier: String?) {
        guard let key_str = identifier else { return }
        
        removeCache(key: key_str)
        
        debugPrint("remove_request=",identifier ?? "")
    }
    
    // 读取缓存
    func load_request(session: FunFreedom.RequestSession) -> Data? {
        guard let key_str = session.identifier,
            let cache_data = loadCache(key: key_str)
            else { return nil}
        
        debugPrint("load_request=",session.urlString ?? "")
        
        return cache_data
    }
    
//    private func format_key(session: FunFreedom.NetworkKit.RequestSession) -> String? {
//
//        if let identifier = session.identifier {
//            return identifier
//        }
//        guard let url = session.urlString else { return nil}
//        var key = url
//
//        if let header = session.headers, let data = try? JSONSerialization.data(withJSONObject: header, options: []), let header_string = String(data: data, encoding: String.Encoding.utf8) {
//            key = key + header_string
//        }
//
//        if let params = session.params, let data = try? JSONSerialization.data(withJSONObject: params, options: []), let params_string = String(data: data, encoding: String.Encoding.utf8) {
//            key = key + params_string
//        }
//
//        return key
//    }
}

