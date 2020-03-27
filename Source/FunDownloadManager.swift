//
//  FunDownloadManager.swift
//  FunFreedom
//
//  Created by 肖华 on 2020/3/26.
//

import Foundation
import Alamofire

public extension FunFreedom {
    public class DownloadManager: NSObject {
        
        class DownloadQueue: OperationQueue {
            
        }
        
        struct Static {
            static let instance_downloadManager = DownloadManager()
        }
        lazy var downloadQueue = DispatchQueue(label: "com.funfreedom.download", attributes: .concurrent)
        
        public let rootQueue = DispatchQueue(label: "com.funfreedom.download.rootQueue")
        
        public static var `default`: DownloadManager {
            return Static.instance_downloadManager
            
        }
        
//        public override init() {
//            super.init()
//        }
        
        fileprivate lazy var session: URLSession = {
            let configuration = URLSessionConfiguration.background(withIdentifier: "com.funfreedom.downloadManager.background")
            configuration.headers = .default
            configuration.timeoutIntervalForRequest = 10
            
            let delegateQueue = DownloadQueue()
            delegateQueue.maxConcurrentOperationCount = 1
            delegateQueue.underlyingQueue = self.rootQueue
            delegateQueue.name = "com.funfreedom.downloadManager.delegateQueue"
            
            let session = URLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
            
            return session
        }()

        

        
//        public var backgroundCompletionHandler: (() -> Void)?
        
    }
}

extension FunFreedom.DownloadManager: URLSessionTaskDelegate {
    // 任务完成、失败、手动停止都会走这里
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let ns_error = error as NSError?, let resumeData = ns_error.userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
            // resumeData 存储
            print(resumeData)
        }
        
    }
    /**
    下载完毕后调用
    参数：lication 临时文件的路径（下载好的文件）
    */
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
    }
    /**
    每当下载完一部分时就会调用（可能会被调用多次）
    参数：
    bytesWritten 这次调用下载了多少
    totalBytesWritten 累计写了多少长度到沙盒中了
    totalBytesExpectedToWrite 文件总大小
    */
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
    }
    
}


public extension FunFreedom.NetworkKit {
    /*
    func mutli_download(_ completion: ResponseResult<URL>?=nil) {
        
        let sessionManager = FunFreedom.DownloadManager.default
        
        sessionManager.downloadQueue.async {
            
            
            if let URLString = self.element.urlString {
                
                do {
                    
                    let request = try URLRequest(url: URLString, method: self.element.method, headers: self.element.headers)
                    
                    var task: URLSessionDownloadTask?
//                    if let resumeData = self.response.resumeData {
//                        task = sessionManager.session.downloadTask(withResumeData: resumeData)
//                    } else {
                        task = sessionManager.session.downloadTask(with: request)
//                    }
                    
                    task?.resume()
                }
                catch {
                    if let complete = completion {
                        complete((false,nil,error))
                    }
                }
            }
            
        }
        
    }
    
    // 统一的请求结果处理
    private func internal_response(request: DownloadRequest, resultHandler: ResponseResult<Data>?=nil) {
        
        // 请求开启关闭响应者事件
        element.sender?.isEnabled = false
        
//        // 开启缓存时，优先读取缓存的内容
//        if session.isCache, let data = load_request(session: session) {
//
//            if let result = resultHandler {
//                result((true,data,nil))
//            }
//
//            session.sender?.isEnabled = true
//            // 拿到对应的缓存后直接回调，执行真正的请求
//            return
//        }
        
        
        request.responseData { (response) in
            
            // 内部回调
            switch response.result {
            case .success(_):
                
                success(data: response.fileURL?.dataRepresentation)
            case .failure(let error):
                
                failure(error: error)
            }

        }
        
        
        // Success handling
        func success(data : Data?) {
            
            // 内部回调
            if let result = resultHandler {
                result((true,data,nil))
            }
            
            // 请求完成时打开sender事件
            element.sender?.isEnabled = true
        }
        
        //Error handling - pop-up error message
        func failure(error : Error?) {
            
            // 内部回调
            if let result = resultHandler {
                result((false,nil,error))
            }
            // 默认的错误HUD
            if FunFreedom.networkManager.errorHUD {
                FunFreedom.toast.message(error?.localizedDescription).showToast()
            }
            // 请求完成时打开sender事件
            element.sender?.isEnabled = true
            
        }
    }
     */
    
    
    
}
