//
//  FunFreedom.swift
//  FunFreedom
//
//  Created by choarkinphe on 2019/7/23.
//  Copyright © 2019 whyq_dxj. All rights reserved.
//

import Foundation
import Alamofire
// 缓存用的线程
fileprivate let FunNetworkCachePathName = "com.funfreedom.funnetwork.cache"
// 成功回调
public typealias ResponseResult<T> = (((success: Bool, data: T?))->Void)

public extension FunFreedom {
    
    class NetworkKit {
        // 请求用到的所有相关信息
        public struct RequestSession {
            public struct UploadFile {
                public var name: String?
                public var type: String?
                public var data: Data?
                public var withName: String?
                
                public init(name a_name: String?, type a_type: String?, data a_data: Data?, withName a_withName: String?) {
                    name = a_name
                    type = a_type
                    data = a_data
                    withName = a_withName
                }
            }
            
            public var requestType: HTTPMethod = .post
            public var urlString: String?
            public var params: [String: Any]?
            
            public var baseUrl: String? = FunFreedom.networkManager.baseUrl
            public var headers: HTTPHeaders? = FunFreedom.networkManager.headers
            
            public var uploadFiles: [UploadFile]?
            
            public var destination = DownloadRequest.suggestedDownloadDestination(
                for: .cachesDirectory,
                in: .userDomainMask
            )
            
            public var downloadClosure: ((Progress) -> Void)?
            public var downloadComplete: ((URL?) -> Void)?
            // 可以自定义请求标示
            public var identifier: String?
            
            public var isCache: Bool = false
            // 缓存时效
            public var cacheTimeOut: TimeInterval?
            // 请求的响应者（请求开始的时候会关闭这个响应者的响应链，防止重复请求）
            public var sender: UIControl?
            // 统一的回调信号
            public var completion: ResponseResult<Data>?
        }
        
        // 创建一个请求时就会对应的创建组请求的数据
        public lazy var session = RequestSession()
        
        public static var `default`: NetworkKit {
            
            let _kit = NetworkKit()
            
            return _kit
        }
        
        public init() {
            
        }
        
        public func downloadClosure(_ downloadClosure: ((Progress) -> Void)?) -> Self {
            session.downloadClosure = downloadClosure
            
            return self
        }
        
        public func downloadComplete(_ downloadComplete: ((URL?) -> Void)?) -> Self {
            session.downloadComplete = downloadComplete
            return self
        }
        
        public func headers(_ header: HTTPHeaders?) -> Self {
            session.headers = header
            
            return self
        }
        
        public func urlString(_ url: String?) -> Self {
            session.urlString = url
            
            if let a_url = url {
                if !a_url.hasPrefix("http") {
                    if let baseURL = session.baseUrl {
                        session.urlString = baseURL + a_url
                    }
                }
            }
            
            
            return self
        }
        
        public func identifier(_ identifier: String?) -> Self {
            session.identifier = identifier
            
            return self
        }
        
        public func isCache(_ isCache: Bool) -> Self {
            session.isCache = isCache
            return self
        }
        
        public func cacheTimeOut(_ cacheTimeOut: TimeInterval) -> Self {
            session.cacheTimeOut = cacheTimeOut
            return self
        }
        
        public func params(_ params: [String: Any]?) -> Self {
            session.params = params
            return self
        }
        
        public func requestType(_ type: HTTPMethod) -> Self {
            session.requestType = type
            return self
        }
        
        public func sender(_ sender: UIControl?) -> Self {
            session.sender = sender
            return self
        }
        
        public func request(_ completion: ResponseResult<Data>?=nil) {
            
            session.completion = completion
            
            if var URLString = session.urlString {
                if load_cache() {
                    
                    return
                }
                
                request_start()
                let dataRequest =  Alamofire.SessionManager.sharedSessionManager.request(URLString, method: session.requestType, parameters: session.params, encoding: URLEncoding.default, headers: session.headers)
                
                debugPrint("url = " + URLString + " Type = " + session.requestType.rawValue)
                
                if let params = session.params {
                    debugPrint("parameters =", params)
                }
                
                
                dataRequest.responseData { (response) in
                    
                    self.request_end()
                    
                    guard let json = response.data else {
                        return
                    }
                    switch response.result {
                    case let .success(response):
                        success(json: json)
                        
                    case let .failure(error):
                        
                        failure(error: error)
                    }
                }
                
                
                // Success handling
                func success(json : Data) {
                    
                    internal_response(success: true, data: json)
                    
                }
                
                //Error handling - pop-up error message
                func failure(error : Error) {
                    
                    internal_response(success: false, data: error)
                    
                    if FunFreedom.networkManager.errorHUD {
                        FunFreedom.toast.message(error.localizedDescription).showToast()
                    }
                    
                }
                
            }
        }
        
        
        
        public func upload() {
            if let URLString = session.urlString {
                request_start()
                
                Alamofire.SessionManager.sharedSessionManager.upload(multipartFormData: { (multipartFormData) in
                    debugPrint("upload_url = " + URLString)
                    
                    if let files = self.session.uploadFiles {
                        for file in files {
                            if let data = file.data {
                                if let withName = file.withName {
                                    let fileType = file.type ?? "unknow"
                                    if let name = file.name {
                                        multipartFormData.append(data, withName: withName, fileName: name, mimeType: fileType)
                                    } else {
                                        multipartFormData.append(data, withName: withName)
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: URLString, method: session.requestType, headers: session.headers) { (encodingResult) in
                    
                    self.request_end()
                    
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            guard let json = response.data else {
                                return
                            }
                            
                            success(json: json)
                            
                        }
                    case .failure(let error):
                        
                        failure(error: error)
                    }
                    
                    
                    
                    
                }
                // Success handling
                func success(json : Data) {
                    internal_response(success: true, data: json)
                }
                
                //Error handling - pop-up error message
                func failure(error : Error) {
                    internal_response(success: false, data: error)
                    if FunFreedom.networkManager.errorHUD {
                        FunFreedom.toast.message(error.localizedDescription).showToast()
                    }
                }
            }
            
        }
        
        public func download() {
            
            if let URLString = session.urlString {
                request_start()
                
                Alamofire.SessionManager.sharedSessionManager.download(URLString, method: session.requestType, parameters: session.params, encoding: JSONEncoding.default, headers: session.headers, to: session.destination).downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                    
                    debugPrint("Progress: \(progress.fractionCompleted)")
                    if let closureHandel = self.session.downloadClosure {
                        DispatchQueue.main.async {
                            closureHandel(progress)
                        }
                    }
                }
                .validate { request, response, temporaryURL, destinationURL in
                    
                    return .success
                }
                .responseJSON { response in
                    self.request_end()
                    debugPrint(response)
                    debugPrint(response.temporaryURL as Any)
                    debugPrint(response.destinationURL as Any)
                    
                    if let complete = self.session.downloadComplete {
                        complete(response.destinationURL)
                    }
                    
                }
            }
        }
        
        // 内部统一请求结果的处理
        internal func internal_response(success: Bool, data: Any?, loadCache: Bool? = false) {
            
            request_end()
            
            if success {
                if let json = data as? Data {
                    
                    if let complete = session.completion {
                        
                        complete((success: true, data: json))
                    }
                    
                    // 开启了缓存，并且结果不是从缓存内读取的，就写入缓存
                    if session.isCache, loadCache != true {
                        
                        cache_request(session: session, response: json)
                    }
                }
                
            } else {
                if let error = data as? Error {
                    
                    if let complete = session.completion {
                        
                        complete((success: false, data: error.localizedDescription.data(using: .utf8)))
                    }
                }
                
            }
            
        }
        
        private func load_cache() -> Bool {
            
            if session.isCache {
                if let data = load_request(session: session) {
                    
                    internal_response(success: true, data: data, loadCache: true)
                    
                    return true
                }
            }
            
            return false
        }
        
        private func request_start() {
            session.sender?.isEnabled = false
        }
        
        private func request_end() {
            session.sender?.isEnabled = true
        }
        
    }
    
}


public extension FunFreedom.NetworkKit {
    class Manager {
        
        public var baseUrl: String?
        public var headers: HTTPHeaders?
        
        // 默认不显示错误HUD
        public var errorHUD: Bool = false
        public lazy var request_cache: FunFreedom.Cache = {
            
            // 默认的请求缓存放在temp下（重启或储存空间报警自动移除）
            // 生成对应的请求缓存工具
            let request_cache = FunFreedom.Cache.init(path: NSTemporaryDirectory() + "/\(FunNetworkCachePathName)")
            // 默认请求缓存的时效为2分钟
            request_cache.cacheTimeOut = 120
            
            return request_cache
            
            
        }()
    }
}

extension SessionManager {
    static let sharedSessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        return SessionManager(configuration: configuration)
        
    }()
}




