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

public extension FunFreedom {
    
    // 构建请求
    class NetworkKit {
        
        // 创建一个请求时就会对应的创建组请求的数据
        public lazy var element = RequestElement()
        
        // 请求管理器
        private let sessionManager: Session
        
        public static var `default`: NetworkKit {
            
            let _kit = NetworkKit(sessionManager: Session.sessionManager)
            
            return _kit
        }
        
        public init(sessionManager: Session) {
            self.sessionManager = sessionManager
        }
        
        public func build(_ type: RequestElement.RequestType) -> Responder {
            
            let responder = Responder(manager: self)
            
            if let URLString = element.urlString {
                
                element.requestType = type
                
                switch type {
                    
                case .default: // 创建普通请求
                    responder.request = sessionManager.request(URLString, method: element.method, parameters: element.params, encoding: URLEncoding.default, headers: element.headers)
                    
                case .download: // 创建下载请求
                    let downloadRequest = sessionManager.download(URLString, method: element.method, parameters: element.params, headers: element.headers, to: element.destination)
                    
                    responder.request = downloadRequest
                    
                case .upload: // 创建上传请求
                    let formData = MultipartFormData(fileManager: FileManager.default)
                    
                    if let formDataHandler = element.formDataHandler {
                        formDataHandler(formData)
                    }
                    
                    let uploadRequest = sessionManager.upload(multipartFormData: formData, to: URLString, method: element.method, headers: element.headers)
                    
                    responder.request = uploadRequest
                    
                }
                
            }
            
            return responder
        }
        
        deinit {
            print("NetworkKit die")
        }
        
    }
    
}

// 请求&响应信息
public extension FunFreedom.NetworkKit {
    // 请求响应内容
    struct RequestResponse {
        // 上传&下载进度
        public var progress: Progress?
        
        // 下载恢复文件
        public let resumeData: Data?
        
        // 真实的下载请求
        public let request: URLRequest?
        
        /// The server's response to the URL request.
        public let response: HTTPURLResponse?
        
        // 请求结果
        public var data: Data?
        // 错误信息
        public var error: Error?
        // 下载任务的地址
        public let fileURL: URL?
        
        
        public init(request: URLRequest?,
                    response: HTTPURLResponse?,
                    fileURL: URL?,
                    resumeData: Data?) {
            self.request = request
            self.response = response
            self.fileURL = fileURL
            self.resumeData = resumeData
            
        }
        
    }
    // 请求元素
    struct RequestElement {
        public enum RequestType: String {
            case `default` = "default"
            case download = "download"
            case upload = "upload"
        }
        // method
        public var method: HTTPMethod = .post
        // 请求地址
        public var urlString: String?
        // 请求参数
        public var params: [String: Any]?
        // baseURL
        public var baseUrl: String? = FunFreedom.networkManager.baseUrl
        // 请求头
        public var headers: HTTPHeaders? = FunFreedom.networkManager.headers
        // body体
        public var formDataHandler: ((MultipartFormData)->Void)?
        // 储存路径
        public var destinationURL: URL?
        fileprivate var destination = DownloadRequest.suggestedDownloadDestination(
            for: .cachesDirectory,
            in: .userDomainMask,
            options: .removePreviousFile
        )
        // 请求类型
        public var requestType: RequestType = .default
        // 是否开启请求的缓存（默认不开启）
        public var isCache: Bool = false
        // 缓存时效
        public var cacheTimeOut: TimeInterval?
        // 请求的响应者（请求开始的时候会关闭这个响应者的响应链，防止重复请求）
        public var sender: UIControl?
        // 可以自定义请求标示
        private var _identifier: String?
        public var identifier: String? {
            get {
                guard let identifier = _identifier else {
                    
                    guard let url = urlString else { return nil}
                    var key = url
                    
                    if let header = headers, let data = try? JSONSerialization.data(withJSONObject: header, options: []), let header_string = String(data: data, encoding: String.Encoding.utf8) {
                        key = key + header_string
                    }
                    
                    if let params = params, let data = try? JSONSerialization.data(withJSONObject: params, options: []), let params_string = String(data: data, encoding: String.Encoding.utf8) {
                        key = key + params_string
                    }
                    
                    return key
                    
                }
                
                return identifier
            }
            set {
                _identifier = newValue
            }
        }
    }
}

// 最终发出请求响应
public extension FunFreedom.NetworkKit {
    
    class Responder {
        deinit {
            print("Responder die")
        }
        // 请求实体
        var request: Request?
        
        let manager: FunFreedom.NetworkKit?
        
        public var progressHandler: ((Progress) -> Void)?
        
        init(manager: FunFreedom.NetworkKit?) {
            self.manager = manager
        }
        
        public func progress(_ a_progressHandler: ((Progress) -> Void)?) -> Self {
            progressHandler = a_progressHandler
            
            return self
        }
        
        public func response(_ completion: ((FunFreedom.NetworkKit.RequestResponse)-> Void)?) {
            guard let request = request, let element = manager?.element else { return }
            // 请求开启关闭响应者事件
            element.sender?.isEnabled = false
            // 开启缓存时，优先读取缓存的内容
            if element.isCache, let data = manager?.load_request(element: element) {
                
                if let result = completion {
                    
                    var response = FunFreedom.NetworkKit.RequestResponse(request: request.request, response: request.response, fileURL: nil, resumeData: nil)
                    response.data = data
                    result(response)
                }
                
                element.sender?.isEnabled = true
                // 拿到对应的缓存后直接回调，执行真正的请求
                return
            }
            
            
            // 普通任务（包含上传）
            if let dataRequest = request as? DataRequest {
                if let progressHandler = progressHandler {
                    dataRequest.uploadProgress(closure: progressHandler)
                }
                // 开启请求任务
                dataRequest.responseData {[weak self] (data_response) in
                    if let result = completion {
                        var response = FunFreedom.NetworkKit.RequestResponse(request: request.request, response: request.response, fileURL: nil, resumeData: nil)
                        
                        // 处理结果
                        switch data_response.result {
                        case .success(_):
                            
                            if let data = data_response.data {
                                response.data = data
                                // 开启了缓存
                                if element.isCache == true {
                                    
                                    self?.manager?.cache_request(element: element, response: data)
                                }
                            } else {
                                response.error = FunError.init(desc: "responseData is empty")
                            }
                            
                        case .failure(let error):
                            
                            response.error = error
                            
                            // 默认的错误HUD
                            if FunFreedom.networkManager.errorHUD {
                                FunFreedom.toast.message(error.localizedDescription).showToast()
                            }
                            
                        }
                        result(response)
                    }
                    
                    // 请求完成时打开sender事件
                    element.sender?.isEnabled = true
                }
                
            }
            
            // 下载任务
            if let downloadRequest = request as? DownloadRequest {
                if let progressHandler = progressHandler {
                    downloadRequest.downloadProgress(closure: progressHandler)
                }
                downloadRequest.responseData { (download_response) in
                    if let result = completion {
                        
                        
                        var response = FunFreedom.NetworkKit.RequestResponse(request: request.request, response: request.response, fileURL: download_response.fileURL, resumeData: nil)
                        // 内部回调
                        
                        switch download_response.result {
                        case .success(_):
                            
                            
                            response.data = download_response.fileURL?.dataRepresentation
                            
                            
                        case .failure(let error):
                            
                            response.error = error
                            
                            // 默认的错误HUD
                            if FunFreedom.networkManager.errorHUD {
                                FunFreedom.toast.message(error.localizedDescription).showToast()
                            }
                        }
                        
                        result(response)
                    }
                    // 请求完成时打开sender事件
                    element.sender?.isEnabled = true
                }
                
            }
            
        }
    }
}

extension FunFreedom.NetworkKit {
    
    // 用来检测所有请求，方便处理公共事件
    fileprivate class Monitor: EventMonitor {
        
        struct Static {
            static let instance_monitor = Monitor()
        }
        
        static var `default`: Monitor {
            return Static.instance_monitor
        }
        
    }
    
}

// MARK: - 快速创建请求信息
public extension FunFreedom.NetworkKit {
    
    func body(_ body: ((MultipartFormData) -> Void)?) -> Self {
        element.formDataHandler = body
        
        return self
    }
    
    func headers(_ header: HTTPHeaders?) -> Self {
        element.headers = header
        
        return self
    }
    
    func urlString(_ url: String?) -> Self {
        element.urlString = url
        
        if let a_url = url {
            if !a_url.hasPrefix("http") {
                if let baseURL = element.baseUrl {
                    element.urlString = baseURL + a_url
                }
            }
        }
        
        
        return self
    }
    
    func identifier(_ identifier: String?) -> Self {
        element.identifier = identifier
        
        return self
    }
    
    func isCache(_ isCache: Bool) -> Self {
        element.isCache = isCache
        return self
    }
    
    func cacheTimeOut(_ cacheTimeOut: TimeInterval) -> Self {
        element.cacheTimeOut = cacheTimeOut
        return self
    }
    
    func params(_ params: [String: Any]?) -> Self {
        element.params = params
        return self
    }
    
    func method(_ method: HTTPMethod) -> Self {
        element.method = method
        return self
    }
    
    func sender(_ sender: UIControl?) -> Self {
        element.sender = sender
        return self
    }
    
    func destinationURL(_ destinationURL: URL?) -> Self {
        element.destinationURL = destinationURL
        element.destination = { temporaryURL, response in
            
            let url = destinationURL?.appendingPathComponent(response.suggestedFilename!) ?? temporaryURL
            
            return (url, .removePreviousFile)
        }
        
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
        configuration.headers = .default
        configuration.timeoutIntervalForRequest = 15
        return Session(configuration: configuration, eventMonitors: [FunFreedom.NetworkKit.Monitor.default])
        
    }()
}




