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
        
        static var instance_device: Device = Device()
    }
    
    public static var netwokKit: NetworkKit {
        
        return NetworkKit.default
    }
    
    public static var sheet: Sheet {
        
        return Sheet.default
    }
    
    public static var alert: Alert {
        
        return Alert.default
    }
    
    public static var toast: Toast {
        return Toast.default
    }
    
    public static var datePicker: DatePicker {
        
        return DatePicker.default
    }
    
    public static var networkManager: NetworkKitManager {
        return Static.instance_networkManager
    }
    
    public static var cache: Cache {
        
        return Static.instance_cache
    }
    
    public static var drawingBoard: DrawingBoard {
        
        return DrawingBoard.default
    }
    
    public static var device: Device {
        return Static.instance_device
    }
    
    
    
}
