//
//  FunFreedomManager.swift
//  FunFreedomManager
//
//  Created by choarkinphe on 2019/9/12.
//  Copyright © 2019 whyq_dxj. All rights reserved.
//

import Foundation
import Alamofire

public class FunNetworkKitManager {
    
    public var baseUrl: String?
    public var headers: HTTPHeaders?
    public var cacheTimeOut: TimeInterval = 300
}

extension SessionManager {
    static let sharedSessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        return SessionManager(configuration: configuration)
        
    }()
}
