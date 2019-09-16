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
            
            if success {
                if let data = data, var model = T.deserialize(from: String(data: data, encoding: .utf8)) {
                    model.success = success
                    completion(model)
                }
            } else {
                
                var model = T()
                model.success = success
                if let data = data, let message = String(data: data, encoding: .utf8) {
                    model.message = message
                }
            }

        }
    }
    
    
}
