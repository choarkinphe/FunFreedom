//
//  FunTool.swift
//  FunFreedom
//
//  Created by 肖华 on 2019/10/22.
//

import Foundation

public extension UIApplication {
    
    // 获取当前的window
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
        
        // 获取当前控制器
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
        
        public var screenSize: CGSize
        
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
            
            screenSize = UIScreen.main.bounds.size
        }

    }
}

//MARK: - findCurrentController
public extension NSObject {
    // 当前显示的控制器
    class var frontController: UIViewController {
        return FunFreedom.PublicTool.frontController
    }

}

public protocol FunView: class {
    
    var fitSize: CGSize { get }
    
}

extension UIButton: FunView {
    
    public var fitSize: CGSize {
        
        var size = CGSize.zero
        
        if let image = imageView?.image {
            size = image.size
        }

        if let titleLabel = titleLabel {
            
            size.width = size.width + titleLabel.fitSize.width + 8
            
            size.height = max(size.height, titleLabel.fitSize.height) + 8
        }

        return size
        
    }
    
}

extension UILabel: FunView {
    public var fitSize: CGSize {
        if let attributedText = attributedText {
            return attributedText.attributedSize(maxWidth: FunFreedom.device.screenSize.width)
            
            
            
        } else if let text = text {
            
            return text.textSize(font: font, maxWidth: FunFreedom.device.screenSize.width)
            
        }
        
        return .zero
    }
    
    
}

extension NSAttributedString {
    func attributedSize(maxWidth: CGFloat) -> CGSize {
        
        let rect = self.boundingRect(with: CGSize.init(width: maxWidth, height: CGFloat(MAXFLOAT)), options: [NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.usesFontLeading], context: nil)
        
        return rect.size
    }
    
}

public extension String {
    func textSize(font: UIFont, maxWidth: CGFloat) -> CGSize {
        return self.boundingRect(with: CGSize(width: maxWidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).size
    }
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: .main, value: "", comment: "")
    }
    
}
/*
    方法交换
 */
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
