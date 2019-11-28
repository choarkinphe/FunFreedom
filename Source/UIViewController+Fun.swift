//
//  UIViewController+CKAdd.swift
//  SelfService
//
//  Created by Choarkinphe on 2019/6/28.
//  Copyright © 2019 whyq_dxj. All rights reserved.
//

import UIKit
private var funControllerKey = "funControllerKey"
extension UIViewController: FunSwizz {
    
    public static func awake() {
        swizzleMethod
    }
    
    private static let swizzleMethod: Void = {
        
        swizzlingForClass(UIViewController.self, originalSelector: #selector(viewDidLoad), swizzledSelector: #selector(swizzled_viewDidLoad))
        swizzlingForClass(UIViewController.self, originalSelector: #selector(viewDidAppear(_:)), swizzledSelector: #selector(swizzled_viewDidAppear(animated:)))
        swizzlingForClass(UIViewController.self, originalSelector: #selector(viewDidDisappear(_:)), swizzledSelector: #selector(swizzled_viewDidDisappear(animated:)))
        swizzlingForClass(UIViewController.self, originalSelector: #selector(viewDidLayoutSubviews), swizzledSelector: #selector(swizzled_viewDidLayoutSubviews))
        
    }()
    
    @objc func swizzled_viewDidLoad() {
        swizzled_viewDidLoad()
        
        
    }
    
    
    @objc func swizzled_viewDidAppear(animated: Bool) {
        swizzled_viewDidAppear(animated: animated)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
    }
    
    
    @objc func swizzled_viewDidDisappear(animated: Bool) {
        swizzled_viewDidDisappear(animated: animated)
        
        
    }
    
    @objc func swizzled_viewDidLayoutSubviews() {
        swizzled_viewDidLayoutSubviews()
        
        guard let contentView = fun.contentView else { return }
        
        let content_x: CGFloat = 0.0
        var content_y: CGFloat = 0.0
        let content_w: CGFloat = view.frame.size.width
        var content_h: CGFloat = view.frame.size.height
        if edgesForExtendedLayout.rawValue != 0 {
            content_h = view.frame.size.height - fun.safeAeraInsets.bottom
        }
        
        if let navigationBar = fun.navigationBar {
            if !navigationBar.isHidden {
                navigationBar.frame = CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: navigationBar.bounds.size.height)
                content_y = navigationBar.frame.origin.y + navigationBar.frame.size.height
                content_h = content_h - navigationBar.frame.size.height
            }
        }

        if let topView = fun.topView {
            if !topView.isHidden {
                var topView_y: CGFloat = fun.safeAeraInsets.top
                if let navigationBar = fun.navigationBar {
                    topView_y = navigationBar.frame.origin.y + navigationBar.frame.size.height
                }
                topView.frame = CGRect.init(x: 0, y: topView_y, width: view.frame.size.width, height: topView.bounds.size.height)
                content_y = topView.frame.origin.y + topView.frame.size.height
                content_h = content_h - topView.frame.size.height
            }
            
        }

        if let bottomView = fun.bottomView {
            if !bottomView.isHidden {
                bottomView.frame = CGRect.init(x: 0, y: view.frame.size.height - bottomView.frame.size.height - fun.safeAeraInsets.bottom, width: view.frame.size.width, height: bottomView.frame.size.height)
                content_h = content_h - bottomView.frame.size.height - fun.safeAeraInsets.bottom
            }
        }
        
        contentView.frame = CGRect.init(x: content_x, y: content_y, width: content_w, height: content_h)
        
    }
    
    var fun: FunController {
        set {
            
            objc_setAssociatedObject(self, &funControllerKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        }
        
        get {
            
            if let observations = objc_getAssociatedObject(self, &funControllerKey) {
                return observations as! FunController
            } else {
                objc_setAssociatedObject(self, &funControllerKey, FunController(target: self), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return self.fun
        }
    }
    
}

class FunController {
    private weak var observation_navigationBar: NSKeyValueObservation?
    private weak var observation_topView: NSKeyValueObservation?
    private weak var observation_bottomView: NSKeyValueObservation?
    private weak var viewController: UIViewController?
    
    init(target: UIViewController?) {
        
        if let target = target {
            viewController = target
            
        }
    }
    
    var safeAeraInsets: UIEdgeInsets {
        var safeAeraInsets = UIEdgeInsets.zero
        if FunFreedom.device.iPhoneXSeries {
            safeAeraInsets.top = 24
            
            if viewController?.hidesBottomBarWhenPushed == true || viewController?.parent?.hidesBottomBarWhenPushed == true {
                safeAeraInsets.bottom = 34
            }
        }
        return safeAeraInsets
    }
    
    var navigationBar: UIView? {
        willSet {
            if navigationBar == newValue {
                
                return
            }
            
            if let navigationBar = navigationBar {
                
                navigationBar.frame = CGRect.init(x: 0, y: -navigationBar.frame.size.height, width: navigationBar.frame.size.width, height: navigationBar.frame.size.height)
                navigationBar.removeFromSuperview()
                
            }
        }
        didSet {
            if let navigationBar = navigationBar, let viewController = viewController {
                viewController.navigationController?.setNavigationBarHidden(true, animated: false)
                navigationBar.frame = CGRect.init(x: 0, y: 0, width: viewController.view.frame.size.width, height: navigationBar.bounds.size.height)
                viewController.view.addSubview(navigationBar)
                observation_navigationBar = navigationBar.observe(\UIView.isHidden) { (_, change) in
                    viewController.view.setNeedsLayout()
                    
                }
                
            }
        }
    }
    
    var topView: UIView? {
        willSet {
            if topView == newValue {
                
                return
            }
            
            if let topView = topView {
                
                topView.frame = CGRect.init(x: 0, y: -topView.frame.size.height, width: topView.frame.size.width, height: topView.frame.size.height)
                topView.removeFromSuperview()
                
            }
        }
        didSet {
            if let topView = topView, let viewController = viewController {
                var topView_y: CGFloat = 0.0
                if let navigationBar = navigationBar {
                    topView_y = navigationBar.frame.origin.y + navigationBar.frame.size.height
                }
                topView.frame = CGRect.init(x: 0.0, y: topView_y, width: viewController.view.frame.size.width, height: topView.bounds.size.height)
                viewController.view.addSubview(topView)
                observation_topView = topView.observe(\UIView.isHidden) { (_, change) in
                    viewController.view.setNeedsLayout()
                    
                }
                
            }
        }
    }
    var contentView: UIView? {
        willSet {
            
            if contentView == newValue {
                
                return
            }
            
            if let contentView = contentView {
                
                contentView.removeFromSuperview()
                
            }
            
        }
        didSet {
            if let contentView = contentView, let viewController = viewController {
                
                contentView.frame = viewController.view.bounds
                
                viewController.view.addSubview(contentView)
                
            }
        }
        
    }
    var bottomView: UIView? {
        willSet {
            if bottomView == newValue {
                
                return
            }
            
            if let bottomView = bottomView, let viewController = viewController {
                
                bottomView.frame = CGRect.init(x: 0, y: viewController.view.frame.size.height, width: viewController.view.frame.size.width, height: bottomView.frame.size.height)
                bottomView.removeFromSuperview()
                
            }
            
        }
        
        didSet {
            if let bottomView = bottomView, let viewController = viewController {

                bottomView.frame = CGRect.init(x: 0, y: viewController.view.frame.size.height - bottomView.frame.size.height - safeAeraInsets.bottom, width: viewController.view.frame.size.width, height: bottomView.frame.size.height)
                
                viewController.view.addSubview(bottomView)
                
                observation_bottomView = bottomView.observe(\UIView.isHidden) { (_, change) in
                    viewController.view.setNeedsLayout()
                }
                
            }
        }
    }
    
    deinit {
        debugPrint("fun die")
        
        bottomView = nil
        contentView = nil
        topView = nil
    }
}
