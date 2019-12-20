//
//  FunFreedom+HandyJSON.swift
//  FunFreedom
//
//  Created by 肖华 on 2019/9/14.
//

import Foundation
import HandyJSON



public extension FunFreedom.NetworkKit {
    
    func request<T>(_ type: T.Type?, _ completion: @escaping ResponseResult<T?>) where T: Codable {
        
        request { (result) in
            if let data = result.data {

                let model = try? JSONDecoder().decode(T.self, from: data)
                completion((success: result.success, data: model))
                

            } else {
                completion((success: result.success, data: nil))
            }
            
            
        }
    }
    

    
    
}
