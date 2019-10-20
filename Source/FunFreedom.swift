//
//  FunFreedom.swift
//  Alamofire
//
//  Created by 肖华 on 2019/10/15.
//

import Foundation
open class FunFreedom {
    
    private struct Static {
        
        static var instance_networkManager: NetworkKitManager = NetworkKitManager()
        
        static var instance_cache: Cache = Cache()
        
    }
    
    public static var netwokKit: NetworkKit {
        
        let _kit = NetworkKit()
        
        return _kit
    }
    
    public static var sheet: Sheet {
        
        let _sheet = Sheet()
        
        return _sheet
    }
    
    public static var networkManager: NetworkKitManager {
        return Static.instance_networkManager
    }
    
    public static var cache: Cache {
        
        return Static.instance_cache
    }
    
    
    
    
}
