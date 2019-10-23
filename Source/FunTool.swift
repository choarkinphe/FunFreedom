//
//  FunTool.swift
//  FunFreedom
//
//  Created by 肖华 on 2019/10/22.
//

import Foundation

extension FunFreedom {
    class PublicTool {
        
        static var frontController: UIViewController {
            
            return NSObject.currentViewController()
        }
        
    }
}

//MARK: - findCurrentController
extension NSObject {
    
    class func currentViewController() -> UIViewController {
        
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        
        return findFrontViewController(currnetVC: rootViewController!)
    }
    
    private class func findFrontViewController(currnetVC : UIViewController) -> UIViewController {
        
        if currnetVC.presentedViewController != nil {
            
            return findFrontViewController(currnetVC: currnetVC.presentedViewController!)
            
        } else if currnetVC.isKind(of:UISplitViewController.self) {
            
            let svc = currnetVC as! UISplitViewController
            
            if svc.viewControllers.count > 0 {
                
                return findFrontViewController(currnetVC: svc.viewControllers.last!)
                
            }
            
        } else if currnetVC.isKind(of: UINavigationController.self) {
            
            let nvc = currnetVC as! UINavigationController
            
            if nvc.viewControllers.count > 0 {
                
                return findFrontViewController(currnetVC: nvc.topViewController!)
                
            }
            
        } else if currnetVC.isKind(of: UITabBarController.self) {
            
            let tvc = currnetVC as! UITabBarController
            
            if (tvc.viewControllers?.count)! > 0 {
                
                return findFrontViewController(currnetVC: tvc.selectedViewController!)
                
            }
            
        } else if currnetVC.children.count > 0 {
            
            for childVC in currnetVC.children {
                
                if currnetVC.view.subviews.contains(childVC.view) {
                    
                    return findFrontViewController(currnetVC: childVC)
                }
            }
           
        }
        
        return currnetVC
        
    }

}

struct CKDevice {
    
    var iPhoneXSeries: Bool = false
    
    private struct Static {
        
        static var instance: CKDevice = CKDevice()
        
    }
    
    static var shared: CKDevice {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            
            if let mainWindow = UIApplication.shared.delegate?.window {
                
                if #available(iOS 11.0, *) {
                    if mainWindow!.safeAreaInsets.bottom > CGFloat(0.0) {
                        
                        Static.instance.iPhoneXSeries = true
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
            
        }
        
        return Static.instance
    }

}

