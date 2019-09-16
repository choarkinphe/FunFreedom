//
//  FunFreedom+Ex.swift
//  FunFreedom_Example
//
//  Created by 肖华 on 2019/9/16.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Alamofire
import HandyJSON
import FunFreedom

public struct ResponseModel<T>: ResponseDecodable {
    
    public init() {
        
    }
    
    public var success: Bool = false
    public var code: Int?
    public var message: String?
    public var data: T?
    
    public mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &message, name: "msg")
    }
    
}

extension FunFreedom {
    
    enum ResponseCode: Int {
        case success = 0
        case needLogin = 2
        case nullCode = 996
    }
    
    func ck_params<T>(_ a_parameters: T?) -> Self {
        
        if let model = a_parameters as? HandyJSON {
            
            return ck_params(model.toJSON())
        }
        
        return self
    }
    
    func request_handy_completion<T>(_ type: T.Type?, _ completion: @escaping ((T?)->Void)) where T : HandyJSON {
        
        request_completion(ResponseModel<T>.self) { (responseModel) in
            
            if responseModel.code == ResponseCode.success.rawValue {
                completion(responseModel.data)
            } else {
                
            }
        }
    }
    
    
    func response_needLogin(title: String?) {
        
        
        
    }
    
}
