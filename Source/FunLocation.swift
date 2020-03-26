//
//  FunLocation.swift
//  FunFreedom
//
//  Created by 肖华 on 2020/3/25.
//

import Foundation
import CoreLocation

/*
 在Info.plist节点增加
 Privacy - Location When In Use Usage Description
 Privacy - Location Always and When In Use Usage Description
 提示语，根据自己的具体请求需求来
 */

public extension FunFreedom {
    class Location: NSObject {
        
        struct Static {
            static var instance_location: Location = Location()
        }
        
        public static var `default`: Location {
            
            return Static.instance_location
        }
        
        // 创建单利工具类
        private lazy var manager: CLLocationManager = {
            let manager = CLLocationManager()
            manager.delegate = self
            return manager
        }()
        
        lazy var geocoder = CLGeocoder()
        
        // 暂存回调
        fileprivate var locationHandler: ((_ result: (location: CLLocation?,error: Error?))->Void)?
        
        // 打开定位服务
        func enableLocationServices(authorizationStatus: CLAuthorizationStatus) {
            if !CLLocationManager.locationServicesEnabled() {
                // 定位服务未打开
                // 直接抛出异常
                if let handler = locationHandler {
                    handler((nil,FunError.init(desc: "location services is not enabled")))
                }
                return
            }
            
            if CLLocationManager.authorizationStatus() == .notDetermined {
                
                //如果没有授权会请求用户授权
                switch authorizationStatus {
                case .authorizedWhenInUse:
                    //获取前台定位权限
                    manager.requestWhenInUseAuthorization()
                case .authorizedAlways:
                    // 获取后台定位权限
                    manager.requestAlwaysAuthorization()
                default:
                    break
                }
            }
            
            // 开启定位服务
            manager.requestLocation()
            
        }
        
        
    }
    
    
}

// MARK： - 对外方法
public extension FunFreedom.Location {
    
    /// 更新当前经纬度信息
    /// - Parameter locationComplete: 回调地址信息
    func updatingLocation(_ locationComplete: @escaping ((_ result: (location: CLLocation?, error: Error?))->Void)) {
        
        locationHandler = locationComplete
        
        // 开启前台定位服务
        enableLocationServices(authorizationStatus: .authorizedWhenInUse)
        
    }
    
    /// 根据经纬度获取地址对象
    /// - Parameters:
    ///   - location: 经纬度
    ///   - complete: 回调信息
    func reverseGeocodeLocation(_ location: CLLocation, complete: @escaping ((_ result: (address: CLPlacemark?, error: Error?))->Void)) {
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            
            
            complete((placemarks?.first,error))
            
        }
    }
}


extension FunFreedom.Location: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 接收AuthorizationStatus变更消息
        switch status {
        case .authorizedAlways:
            // 后台定位时打开实时更新
            manager.allowsBackgroundLocationUpdates = true
        case .authorizedWhenInUse:
            // 前台定位时关闭实时更新
            manager.allowsBackgroundLocationUpdates = false
        default:
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 获取定位失败
        if let handler = locationHandler {
            handler((nil,error))
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // 获取定位
        let location = locations.first
        
        if let handler = locationHandler {
            handler((location,nil))
        }
        
        // 定位完成时，关闭师生更新
        manager.allowsBackgroundLocationUpdates = false
    }
}
