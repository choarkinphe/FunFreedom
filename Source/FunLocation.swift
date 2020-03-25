//
//  FunLocation.swift
//  FunFreedom
//
//  Created by 肖华 on 2020/3/25.
//

import Foundation
import CoreLocation

//打开Info.plist，在<dict>节点增加NSLocationUsageDescription值：

public extension FunFreedom {
    class Location: CLLocationManager {

        public static var `default`: Location {
            let _default = Location()
            _default.delegate = _default
            return _default
        }

        
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
                        requestWhenInUseAuthorization()
                    case .authorizedAlways:
                        // 获取后台定位权限
                        requestAlwaysAuthorization()
                    default:
                        break
                    }
            }
            
            // 开启定位服务
            requestLocation()

        }

        public func updatingLocation(_ locationComplete: @escaping ((_ result: (location: CLLocation?,error: Error?))->Void)) {

            locationHandler = locationComplete

            // 开启前台定位服务
            enableLocationServices(authorizationStatus: .authorizedWhenInUse)
            
        }
        
        deinit {
            debugPrint("FunLocation: die")
        }
    }
    
    
}


extension FunFreedom.Location: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 接收AuthorizationStatus变更消息
        switch status {
        case .authorizedAlways:
            // 后台定位时打开实时更新
            allowsBackgroundLocationUpdates = true
        case .authorizedWhenInUse:
            // 前台定位时关闭实时更新
            allowsBackgroundLocationUpdates = false
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
        allowsBackgroundLocationUpdates = false
    }
}
