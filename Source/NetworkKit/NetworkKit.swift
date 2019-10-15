//
//  FunFreedom.swift
//  FunFreedom
//
//  Created by choarkinphe on 2019/7/23.
//  Copyright © 2019 whyq_dxj. All rights reserved.
//

import Foundation
import Alamofire
import HandyJSON

open class NetworkKit {
    public struct RequestConfig {
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
        
        public var identifier: String?
        
        public var isCache: Bool = false
        
        public var cacheTimeOut: TimeInterval = FunFreedom.networkManager.cacheTimeOut
        
        public var sender: UIControl?
        
        public var completion: ((Bool,Data?)->Void)?
    }

    
    public lazy var config = RequestConfig()


    
    public init() {
        
    }
    
    public func downloadClosure(_ downloadClosure: ((Progress) -> Void)?) -> Self {
        config.downloadClosure = downloadClosure
        
        return self
    }
    
    public func downloadComplete(_ downloadComplete: ((URL?) -> Void)?) -> Self {
        config.downloadComplete = downloadComplete
        return self
    }
    
    public func headers(_ header: HTTPHeaders?) -> Self {
        config.headers = header
        
        return self
    }
    
    public func urlString(_ url: String?) -> Self {
        config.urlString = url
        
        if let a_url = url {
            if !a_url.hasPrefix("http") {
                if let baseURL = config.baseUrl {
                    config.urlString = baseURL + a_url
                }
            }
        }
        
        
        return self
    }
    
    public func identifier(_ identifier: String?) -> Self {
        config.identifier = identifier

        return self
    }
    
    public func isCache(_ isCache: Bool) -> Self {
        config.isCache = isCache
        return self
    }
    
    public func cacheTimeOut(_ cacheTimeOut: TimeInterval) -> Self {
        config.cacheTimeOut = cacheTimeOut
        return self
    }
    
    public func params(_ params: [String: Any]?) -> Self {
        config.params = params
        return self
    }
    
    public func requestType(_ type: HTTPMethod) -> Self {
        config.requestType = type
        return self
    }
    
    public func sender(_ sender: UIControl?) -> Self {
        config.sender = sender
        return self
    }
    
    public func request(_ completion: ((Bool,Data?)->Void)?=nil) {
        
        config.completion = completion

        if var URLString = config.urlString {
            if load_cache() {
                
                return
            }
            
            request_start()
            let dataRequest =  Alamofire.SessionManager.sharedSessionManager.request(URLString, method: config.requestType, parameters: config.params, encoding: URLEncoding.default, headers: config.headers)
            
            debugPrint("url = " + URLString + " Type = " + config.requestType.rawValue)
            
            if let params = config.params {
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
                

            }
            
        }
    }
    
    
    
    public func upload() {
        if let URLString = config.urlString {
            request_start()
            
            Alamofire.SessionManager.sharedSessionManager.upload(multipartFormData: { (multipartFormData) in
                debugPrint("upload_url = " + URLString)
                
                if let files = self.config.uploadFiles {
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
                
            }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: URLString, method: config.requestType, headers: config.headers) { (encodingResult) in
                
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
                
            }
        }
        
    }
    
    public func download() {
        
        if let URLString = config.urlString {
            request_start()
            
            Alamofire.SessionManager.sharedSessionManager.download(URLString, method: config.requestType, parameters: config.params, encoding: JSONEncoding.default, headers: config.headers, to: config.destination).downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                
                debugPrint("Progress: \(progress.fractionCompleted)")
                if let closureHandel = self.config.downloadClosure {
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
                    
                    if let complete = self.config.downloadComplete {
                        complete(response.destinationURL)
                    }
                    
            }
        }
    }
    
    internal func internal_response(success: Bool, data: Any?) {
        request_end()
        
        if success {
            if let json = data as? Data {
                
                response_success(json: json)
                if let complete = config.completion {
                    
                    complete(true,json)
                }
                if config.isCache {
                    
                    cache_request(config: config, response: json)
                }
            }
            
        } else {
            if let error = data as? Error {
                response_failure(error: error)
                if let complete = config.completion {
                    
                    complete(false,error.localizedDescription.data(using: .utf8))
                }
            }
            
        }
        
    }
    
    open func response_success(json: Data) {
//        request_end()
        

    }

    open func response_failure(error: Error){
//        request_end()
    }
    
    private func load_cache() -> Bool {
        
        if config.isCache {
            if let data = load_request(config: config) {
                
                internal_response(success: true, data: data)
                
                return true
            }
        }
        
        return false
    }
    
    private func request_start() {
        config.sender?.isEnabled = false
    }
    
    private func request_end() {
        config.sender?.isEnabled = true
    }
    
}
    






