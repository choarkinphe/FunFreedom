//
//  FunFreedom.swift
//  Alamofire
//
//  Created by 肖华 on 2019/10/15.
//

import Foundation
public typealias FunNetworkKit = FunFreedom.NetworkKit
public typealias FunLocation = FunFreedom.Location
public typealias FunToast = FunFreedom.Toast
public typealias FunSheet = FunFreedom.Sheet
public typealias FunAlert = FunFreedom.Alert
public typealias FunDatePicker = FunFreedom.DatePicker
public typealias FunCache = FunFreedom.Cache
public typealias FunDrawingBoard = FunFreedom.DrawingBoard
open class FunFreedom {
    
    private struct Static {
        
        static var instance_networkManager: NetworkKit.Manager = NetworkKit.Manager()
        
        static var instance_device: Device = Device()
    }
    
}

// MARK: - DrawingBoard
public extension FunFreedom {
   static var drawingBoard: DrawingBoard {
        
        return DrawingBoard.default
    }
}

// MARK: - picker
public extension FunFreedom {
    
    static var datePicker: DatePicker {
        
        return DatePicker.default
    }
    
    static var sheet: Sheet {
        
        return Sheet.default
    }
    
    static var alert: Alert {
        
        return Alert.default
    }
    
    static var toast: Toast {
        return Toast.default
    }
    

}

// MARK: -Tool
public extension FunFreedom {

    static var cache: Cache {
        
        return Cache.default
    }
    
    static var device: Device {
        return Static.instance_device
    }
}

// MARK: - NetworkKit
public extension FunFreedom {

    
    static var netwokKit: NetworkKit {
        
        return NetworkKit.default
    }
    
    static var networkManager: NetworkKit.Manager {
        return Static.instance_networkManager
    }
}
