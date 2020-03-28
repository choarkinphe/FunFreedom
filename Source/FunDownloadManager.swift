//
//  FunDownloadManager.swift
//  FunFreedom
//
//  Created by 肖华 on 2020/3/26.
//

import Foundation
import Alamofire
public extension FunFreedom.DownloadManager {
    
    struct Response {
        // 下载进度
        public lazy var progress = Progress()
        
        // 文件地址
        public var fileURL: URL?
        
    }
    
    class Responder {
        lazy var response = Response()
        // 实际的下载任务
        fileprivate let downloadTask: URLSessionDownloadTask?
        
        // 下载进度
        fileprivate var progressHandler: ((Progress)->Void)?
        public func progressHandler(_ a_progressHandler: ((Progress)->Void)?) -> Self {
            progressHandler = a_progressHandler
            
            return self
        }
        // 恢复文件
        public var resumeData: Data?
        // 储存路径
        public var destinationURL: URL?
        // 是否休眠（可以永远不会自动执行下载，但是始终存在于等待队列）
        public var isDormancy: Bool = true
        
        public init(downloadTask: URLSessionDownloadTask?) {
            self.downloadTask = downloadTask
        }
        
        public func response(_ complete: (()->Void)?) {
//            let manager = FunFreedom.DownloadManager.default
            // 关闭休眠状态，让任务可以添加到下载队列
            isDormancy = false
        }
    }
}
public extension FunFreedom {
    class DownloadManager: NSObject {

        struct Static {
            static let instance_downloadManager = DownloadManager()
        }
        
        // 最大同时下载数（默认一次下载一条）
        public var maxDownloadCount: Int = 1
        
        // 下载中的任务列表
        public var downloadTasks = [URLRequest: FunFreedom.DownloadManager.Responder]()
        // 等待列队（错误，异常终止的都会加入到等待队列）
        public var waitTasks = [URLRequest: FunFreedom.DownloadManager.Responder]()

        public let rootQueue = DispatchQueue(label: "com.funfreedom.download.rootQueue")
        
        public static var `default`: DownloadManager {
            return Static.instance_downloadManager
            
        }
        public var isDownloadFree: Bool {
            return downloadTasks.count < maxDownloadCount
        }
        
        private lazy var fileManager  = FileManager.default
        
        func buildResponder(request: URLRequest) -> DownloadManager.Responder {
            
            // 判断任务池里有没有这条任务
            if let downloadResponder = downloadTasks[request] {
                
                // 下载中的任务不可再次操作，直接抛出
                return downloadResponder
            }
            
            // 创建下载任务
            let downloadTask = session.downloadTask(with: request)
            
            // 生成对应的响应器
            let responder = Responder(downloadTask: downloadTask)
            // 添加到等待队列
            waitTasks[request] = responder
            
            // 有新的任务添加进来，所以重启计时器
            timer.fireDate = Date()
            
            return responder
        }
        

        public override init() {
            super.init()

            // 默认先启动计时器
            timer.fire()

        }
        
        private lazy var timer: Timer = {
            // 开启一个周期为1s的计时器
            let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkTask(timer:)), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: .default)
            
            return timer
        }()

        fileprivate lazy var session: URLSession = {
            
            let configuration = URLSessionConfiguration.background(withIdentifier: "com.funfreedom.downloadManager.background")
            
            configuration.headers = .default
            configuration.timeoutIntervalForRequest = 10

            let session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)

            return session
        }()

        // 轮循检查任务状态
        @objc func checkTask(timer: Timer) {
            
            if waitTasks.count + downloadTasks.count == 0 {
                // 任务归零时暂停计时器
                timer.fireDate = Date.distantFuture
            }
            
            debugPrint("轮询任务")
            waitTasks.forEach { (task) in
                if (isDownloadFree) {
                    
                    downloadTasks[task.key] = task.value
                    waitTasks.removeValue(forKey: task.key)
                }
            }

            downloadTasks.forEach { (task) in
                if let downloadTask = task.value.downloadTask {
                    if !task.value.isDormancy, (downloadTask.state == .suspended || downloadTask.state == .canceling) {
                        // 开启任务
                        downloadTask.resume()
                    }
                } else {
                    // 任务丢失，移动到等待列表中等待重建任务
                    waitTasks[task.key] = task.value
                    // 从下载队列中移除
                    downloadTasks.removeValue(forKey: task.key)
                }
            }

        }

    }
}

extension FunFreedom.DownloadManager: URLSessionTaskDelegate, URLSessionDownloadDelegate {
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
        // 获取当前任务响应信息
        
        if let request = downloadTask.currentRequest, let responder = downloadTasks[request] {
            // 获取存储文件路径
            if let path = responder.destinationURL, let fileName = downloadTask.response?.suggestedFilename {
                
                let destination = path.appendingPathComponent(fileName)
                
                do {
                    // 存在有旧文件，就先移除
                    if fileManager.fileExists(atPath: destination.path) {
                        try fileManager.removeItem(at: destination)
                    }
                    
//                    let directory = destination.deletingLastPathComponent()
//                    try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
                    
                    // 移动文件到目标路径
                    try fileManager.moveItem(at: location, to: destination)
                    // 下载完成后移除任务
                    downloadTasks.removeValue(forKey: request)
                    
                }
                catch {
                    print(error)
                }

            }
        }
  
    }
    /**
    每当下载完一部分时就会调用（可能会被调用多次）
    参数：
    bytesWritten 这次调用下载了多少
    totalBytesWritten 累计写了多少长度到沙盒中了
    totalBytesExpectedToWrite 文件总大小
    */
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // 获取当前任务响应信息
        if let request = downloadTask.currentRequest, let responder = downloadTasks[request] {
            // 获取当前任务的下载进度
            
            responder.response.progress.totalUnitCount = totalBytesExpectedToWrite
            responder.response.progress.completedUnitCount = totalBytesWritten
            
            // 回调出去
            if let progressHandler = responder.progressHandler {
                progressHandler(responder.response.progress)
            }
            // 换算成MB
            let size = Double(totalBytesWritten) / 1024.0 / 1024.0
            debugPrint(String(format: "已下载%.2fMB",size))
            
        }
        
    }
    
}


public extension FunFreedom.NetworkKit {
    var downloadResponder: FunFreedom.DownloadManager.Responder? {
        
        guard let request = element.request else { return nil }
        
        let sessionManager = FunFreedom.DownloadManager.default
        
        let responder = sessionManager.buildResponder(request: request)
        
        responder.destinationURL = element.destinationURL
        
        return responder

    }

  
}
