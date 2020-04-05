//
//  FunTool.swift
//  FunFreedom
//
//  Created by 肖华 on 2019/10/22.
//

import Foundation

public extension UIApplication {
    
    var currentWindow: UIWindow? {
        
        if let window = UIApplication.shared.keyWindow {
            return window
        }
        
        if #available(iOS 13.0, *) {

            for windowScene:UIWindowScene in ((UIApplication.shared.connectedScenes as? Set<UIWindowScene>)!) {
                
                if windowScene.activationState == .foregroundActive {
                    
                    return windowScene.windows.first
                    
                }
                
            }
            
            
            
        }
        
        return nil
        
    }
    
}

public extension FunFreedom {
    
    class PublicTool {
        
        public static var frontController: UIViewController {
            
            let rootViewController = UIApplication.shared.currentWindow?.rootViewController
            
            return findFrontViewController(rootViewController!)
        }
        
        private static func findFrontViewController(_ currnet: UIViewController) -> UIViewController {
            
            if let presentedController = currnet.presentedViewController {
                
                return findFrontViewController(presentedController)
                
            } else if let svc = currnet as? UISplitViewController, let next = svc.viewControllers.last {
                
                    
                    return findFrontViewController(next)

            } else if let nvc = currnet as? UINavigationController, let next = nvc.topViewController {
                
                    return findFrontViewController(next)
                
            } else if let tvc = currnet as? UITabBarController, let next = tvc.selectedViewController {
                
                
                    return findFrontViewController(next)

                
            } else if currnet.children.count > 0 {
                
                for child in currnet.children {
                    
                    if currnet.view.subviews.contains(child.view) {
                        
                        return findFrontViewController(child)
                    }
                }
               
            }
            
            return currnet
            
        }
        
        
    }
    
    struct Device {
        
        public var iPhoneXSeries: Bool = false
        
        public init() {
            if UIDevice.current.userInterfaceIdiom == .phone {
                
                if let mainWindow = UIApplication.shared.delegate?.window {
                    
                    if #available(iOS 11.0, *) {
                        if mainWindow!.safeAreaInsets.bottom > CGFloat(0.0) {
                            
                            iPhoneXSeries = true
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                }
                
            }
        }

    }
}

//MARK: - findCurrentController
fileprivate extension NSObject {
    
    class func currentViewController() -> UIViewController {
        
//        let rootViewController = UIApplication.shared.currentWindow?.rootViewController
        
//        return findFrontViewController(currnetVC: rootViewController!)
        return FunFreedom.PublicTool.frontController
    }
    /*
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
*/
}

public protocol FunSwizz: class {
    static func awake()
    static func swizzlingForClass(_ forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector)
}

public extension FunSwizz {
    
    static func swizzlingForClass(_ forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        let originalMethod = class_getInstanceMethod(forClass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
        guard (originalMethod != nil && swizzledMethod != nil) else {
            return
        }
        if class_addMethod(forClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!)) {
            class_replaceMethod(forClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
}

public extension UIApplication {
    private static let runOnce: Void = {
        let typeCount = Int(objc_getClassList(nil, 0))
        let types = UnsafeMutablePointer<AnyClass>.allocate(capacity: typeCount)
        let autoreleasingTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        objc_getClassList(autoreleasingTypes, Int32(typeCount))
        for index in 0 ..< typeCount {
            (types[index] as? FunSwizz.Type)?.awake()
        }
        types.deallocate()
    }()
    override var next: UIResponder? {
        UIApplication.runOnce
        return super.next
    }
    
}




