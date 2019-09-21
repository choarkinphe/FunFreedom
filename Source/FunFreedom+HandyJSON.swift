//
//  FunFreedom+HandyJSON.swift
//  FunFreedom
//
//  Created by 肖华 on 2019/9/14.
//

import Foundation
import HandyJSON

public protocol ResponseDecodable: HandyJSON {
    associatedtype JSONType
    var success: Bool {get set}
    var code: Int? {get set}
    var message: String? {get set}
    var data: JSONType? {get set}
}

extension FunFreedom {
    
    public func request_completion<T>(_ type: T.Type?, _ completion: @escaping ((T)->Void)) where T : ResponseDecodable {
        
        request { (success, data) in
            var model = T()
            
            if let data = data {
                if let message = String(data: data, encoding: .utf8) {
                    model.message = message
                }
                if let a_model = T.deserialize(from: String(data: data, encoding: .utf8)) {
                    model = a_model
                }
            }
            
            model.success = success

            completion(model)
        }
    }
    
    
}
