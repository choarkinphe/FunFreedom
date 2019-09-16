//
//  FunFreedomManager.swift
//  FunFreedomManager
//
//  Created by choarkinphe on 2019/9/12.
//  Copyright © 2019 whyq_dxj. All rights reserved.
//

import Foundation
import Alamofire

public class FunFreedomManager {
    
    private struct Static {
        
        static var instance: FunFreedomManager = FunFreedomManager()
        
    }
    
    public static var manager: FunFreedomManager {
        return Static.instance
    }
    
    public var baseUrl: String?
    public var headers: HTTPHeaders?
    
}

extension SessionManager {
    static let sharedSessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        return SessionManager(configuration: configuration)
        
    }()
}
