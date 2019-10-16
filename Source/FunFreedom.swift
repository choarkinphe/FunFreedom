//
//  FunFreedom.swift
//  Alamofire
//
//  Created by 肖华 on 2019/10/15.
//

import Foundation
open class FunFreedom {
    
    private struct Static {
        
        static var instance_networkManager: FunNetworkKitManager = FunNetworkKitManager()
        
        static var instance_cache: FunCache = FunCache()
        
    }
    
    public static var netwokKit: FunNetworkKit {
        
        let _kit = FunNetworkKit()
        
        return _kit
    }
    
    public static var sheet: FunSheet {
        
        let _sheet = FunSheet()
        
        return _sheet
    }
    
    public static var networkManager: FunNetworkKitManager {
        return Static.instance_networkManager
    }
    
    public static var cache: FunCache {
        
        return Static.instance_cache
    }
    

    
    
}
