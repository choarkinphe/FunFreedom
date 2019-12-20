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

public protocol ResponseDecodable: HandyJSON {
    associatedtype JSONType
    var success: Bool {get set}
    var code: Int? {get set}
    var message: String? {get set}
    var data: JSONType? {get set}
}
public struct BaseModel<T>: ResponseDecodable  {
    public var success: Bool = false
    
    public init() {
        
    }
    
    public var code: Int?
    
    public var message: String?
    
    public var data: T?

    var Code: Int {
        return code ?? 0
    }
    var Data: String? {
        return data as? String
    }
    var Message: String {
        return message ?? ""
    }
    
    public mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &code, name: "code")
        mapper.specify(property: &data, name: "data")
        mapper.specify(property: &message, name: "message")
    }

}

typealias CKNetwork = FunFreedom.NetworkKitManager
typealias CKNetworkKit = FunFreedom.NetworkKit
typealias SuccessHandlerType = ((BaseModel<String>) -> Void)
typealias FailureHandlerType = ((Int?, String) ->Void)

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


private var NetwokKitSuccessKey = "NetwokKitSuccessKey"
private var NetwokKitFailureKey = "NetwokKitFailureKey"

extension FunFreedom.NetworkKit: FunResponseDelegate {
    
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
    
//    func request_handy_completion<T>(_ type: T.Type?, _ completion: @escaping ((T?)->Void)) where T : HandyJSON {
//        
//        request_completion(ResponseModel<T>.self) { (responseModel) in
//            
//            if responseModel.code == ResponseCode.success.rawValue {
//                completion(responseModel.data)
//            } else {
//                
//            }
//        }
//    }
    
    static var hz: FunFreedom.NetworkKit {
        let a = FunFreedom.NetworkKit()
        a.delegate = a
        return a
    }
    
    func response_needLogin(title: String?) {
        
        
        
    }
    
    final var success: SuccessHandlerType? {
        set {
            objc_setAssociatedObject(self, &NetwokKitSuccessKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        
        get {
            if let rs = objc_getAssociatedObject(self, &NetwokKitSuccessKey) {
                return rs as? SuccessHandlerType
            }
            return nil
        }
    }
    
    final var failure: FailureHandlerType? {
        set {
            objc_setAssociatedObject(self, &NetwokKitFailureKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        
        get {
            if let rs = objc_getAssociatedObject(self, &NetwokKitFailureKey) {
                return rs as? FailureHandlerType
            }
            return nil
        }
    }
    
//    private var success: SuccessHandlerType?
//    private var failure: FailureHandlerType?
    
    
    final func success(_ handler: @escaping SuccessHandlerType) -> Self {
            success = handler
            return self
        }
        
        final func failure(_ handler: @escaping FailureHandlerType) -> Self {
            failure = handler
            return self
        }

    public func response_success(json: Data) {
            
            do {
                // ***********Error code can be unified here, unified error pop-up ****
    //            let decoder = JSONDecoder()
    //            let baseModel = try? decoder.decode(BaseModel<String>.self, from: json)
                
                guard let model = BaseModel<String>.deserialize(from: String(data: json, encoding: .utf8)) else {
                    if let failureBlack = self.failure {
                        failureBlack(nil, "Parse failure")
                    }
                    return
                }
                switch (model.Code) {
                case 0:
                    //Data return correct
                    self.success?(model)
                case 2:
                    //Please login again
                    self.failure?(model.Code ,model.Message)
                    //                alertLogin(model.generalMessage)
                    response_needLogin(title: model.message)
                default:
                    //Other errors
                    self.failure?(model.Code ,model.Message)

                }
            }
        }
        
    public func response_failure(error: Error) {
            
//            self.failure?(nil ,"Parse failure")
        }
    
}

public extension FunFreedom.NetworkKit {
    

    func request_completion<T>(_ type: T.Type?, _ completion: @escaping ((T)->Void)) where T : ResponseDecodable {
        
        request { (result) in
            
            var model = T()
            
            if let data = result.data {
                if let message = String(data: data, encoding: .utf8) {
                    model.message = message
                }
                if let a_model = T.deserialize(from: String(data: data, encoding: .utf8)) {
                    model = a_model
                }
            }
            
            model.success = result.success
            
            completion(model)
        }
    }
    

    
    
}
