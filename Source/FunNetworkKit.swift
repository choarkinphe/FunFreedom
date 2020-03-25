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
// 回调
public typealias ResponseResult<T> = (((success: Bool, data: T?, message: String?))->Void)

public extension FunFreedom {
    
    class NetworkKit {
        // 请求用到的所有相关信息
        public struct RequestSession {

            public var method: HTTPMethod = .post
            
            public var urlString: String?
            
            public var params: [String: Any]?
            
            public var baseUrl: String? = FunFreedom.networkManager.baseUrl
            // 请求头
            public var headers: HTTPHeaders? = FunFreedom.networkManager.headers
            // body体
            public var formDataHandler: ((MultipartFormData)->Void)?
            // 储存路径
            public var destination = DownloadRequest.suggestedDownloadDestination(
                for: .cachesDirectory,
                in: .userDomainMask,
                options: .removePreviousFile
            )
            // 上传&下载进度
            public var progressHandler: ((Progress) -> Void)?
            
            // 可以自定义请求标示
            public var identifier: String?
            // 是否开启请求的缓存（默认不开启）
            public var isCache: Bool = false
            // 缓存时效
            public var cacheTimeOut: TimeInterval?
            // 请求的响应者（请求开始的时候会关闭这个响应者的响应链，防止重复请求）
            public var sender: UIControl?
        }
        
        // 创建一个请求时就会对应的创建组请求的数据
        public lazy var session = RequestSession()
        // 请求实例（最终的请求管理者）
        private var sessionManager = Session.sessionManager
        
        public static var `default`: NetworkKit {
            
            let _kit = NetworkKit()
            
            return _kit
        }
        
        public init() {
            
        }
        
        
        // 普通请求
        public func request(_ completion: ResponseResult<Data>?=nil) {

            if let URLString = session.urlString {

                let dataRequest =  sessionManager.request(URLString, method: session.method, parameters: session.params, encoding: URLEncoding.default, headers: session.headers)
                
                internal_response(request: dataRequest, resultHandler: completion)
            }
        }
        
        // 单上传任务
        public func upload(_ completion: ResponseResult<Data>?=nil) {

            if let URLString = session.urlString {
                
                let formData = MultipartFormData(fileManager: FileManager.default)
                
                if let formDataHandler = session.formDataHandler {
                    formDataHandler(formData)
                }
                
                let uploadRequest = sessionManager.upload(multipartFormData: formData, to: URLString, method: session.method, headers: session.headers)
                
                if let progressHandler = session.progressHandler {
                    uploadRequest.uploadProgress(closure: progressHandler)
                }

                internal_response(request: uploadRequest, resultHandler: completion)
                
            }
        }
        
        // 单下载任务
        public func download(_ completion: ResponseResult<URL>?=nil) {
            
            if let URLString = session.urlString {
                
                let downloadRequest = sessionManager.download(URLString, method: session.method, parameters: session.params, headers: session.headers, to: session.destination)
                
                if let progressHandler = session.progressHandler {
                    downloadRequest.downloadProgress(closure: progressHandler)
                }
                
                internal_response(request: downloadRequest) { (result) in
                    if let complete = completion {
                        var filePath: URL?
                        if let data = result.data {
                            filePath = URL.init(dataRepresentation: data, relativeTo: nil)
                        }
                        complete((result.success, filePath, result.message))
                    }
                    
                }
                
            }
        }
        
        // 统一的请求结果处理
        private func internal_response(request: Request, resultHandler: ResponseResult<Data>?=nil) {
            
            // 请求开启关闭响应者事件
            session.sender?.isEnabled = false
            // 开启缓存时，优先读取缓存的内容
            if session.isCache, let data = load_request(session: session) {
                
                if let result = resultHandler {
                    result((true,data,nil))
                }
                
                session.sender?.isEnabled = true
                // 拿到对应的缓存后直接回调，执行真正的请求
                return
            }
            
            // 普通任务（包含上传）
            if let dataRequest = request as? DataRequest {
                
                // 开启请求任务
                dataRequest.responseData { (response) in
                    guard let data = response.data else {
                        // 实际返回数据为空时，抛出异常直接退出
                        // 内部回调
                        if let result = resultHandler {
                            result((false,nil,"responseData is empty"))
                        }
                        return
                    }
                    
                    // 处理结果
                    switch response.result {
                    case let .success(response):
                        success(data: data)
                        
                    case let .failure(error):
                        
                        failure(error: error)
                        
                    }
                }
                
            }
            
            // 下载任务
            if let downloadRequest = request as? DownloadRequest {
                downloadRequest.responseData { (response) in
                    if let result = resultHandler {
                        // 内部回调
                        switch response.result {
                        case let .success(data):
                            
                            success(data: response.fileURL?.dataRepresentation)
                        case let .failure(error):
                            
                            failure(error: error)
                        }
                        
                    }
                }
                
            }
            
            // Success handling
            func success(data : Data?) {
                
                // 内部回调
                if let result = resultHandler {
                    result((true,data,nil))
                }
                
                // 开启了缓存
                if session.isCache {
                    
                    cache_request(session: session, response: data)
                }
                // 请求完成时打开sender事件
                session.sender?.isEnabled = true
            }
            
            //Error handling - pop-up error message
            func failure(error : Error?) {
                
                // 内部回调
                if let result = resultHandler {
                    result((false,nil,error?.localizedDescription))
                }
                // 默认的错误HUD
                if FunFreedom.networkManager.errorHUD {
                    FunFreedom.toast.message(error?.localizedDescription).showToast()
                }
                // 请求完成时打开sender事件
                session.sender?.isEnabled = true
                
            }
            
        }
        
    }
    
}

// MARK: - 快速创建请求
public extension FunFreedom.NetworkKit {
    func progress(_ progressHandler: ((Progress) -> Void)?) -> Self {
        session.progressHandler = progressHandler
        
        return self
    }
    
    func body(_ body: ((MultipartFormData) -> Void)?) -> Self {
        session.formDataHandler = body
        
        return self
    }
    
    func headers(_ header: HTTPHeaders?) -> Self {
        session.headers = header
        
        return self
    }
    
    func urlString(_ url: String?) -> Self {
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
    
    func identifier(_ identifier: String?) -> Self {
        session.identifier = identifier
        
        return self
    }
    
    func isCache(_ isCache: Bool) -> Self {
        session.isCache = isCache
        return self
    }
    
    func cacheTimeOut(_ cacheTimeOut: TimeInterval) -> Self {
        session.cacheTimeOut = cacheTimeOut
        return self
    }
    
    func params(_ params: [String: Any]?) -> Self {
        session.params = params
        return self
    }
    
    func method(_ method: HTTPMethod) -> Self {
        session.method = method
        return self
    }
    
    func sender(_ sender: UIControl?) -> Self {
        session.sender = sender
        return self
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

extension Session {
    static let sessionManager: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        return Session(configuration: configuration)
        
    }()
}




