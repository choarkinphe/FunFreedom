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
        
        if let navigationController = navigationController {
            /*
             None     不做任何扩展,如果有navigationBar和tabBar时,self.view显示区域在二者之间
             Top      扩展顶部,self.view显示区域是从navigationBar顶部计算面开始计算一直到屏幕tabBar上部
             Left     扩展左边,上下都不扩展,显示区域和UIRectEdgeNone是一样的
             Bottom   扩展底部,self.view显示区域是从navigationBar底部到tabBar底部
             Right    扩展右边,上下都不扩展,显示区域和UIRectEdgeNone是一样的
             All      上下左右都扩展,及暂满全屏,是默认选项
             */
            
            // edgesForExtendedLayout == UIRectEdgeNone || UIRectEdgeBottom时，view本身就是从navigationBar的下面开始计算坐标的
            // 导航栏半透明的时候，才需要把contentView向下偏移
            if !navigationController.isNavigationBarHidden && edgesForExtendedLayout.rawValue != 0 && edgesForExtendedLayout != .bottom && navigationController.navigationBar.isTranslucent {
                // 系统导航栏未隐藏，从导航栏地步开始计算坐标
                content_y = navigationController.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.size.height;
                
            }
        }
        
        if let tabBarController = tabBarController {
            if (tabBarController.tabBar.isHidden && tabBarController.tabBar.isTranslucent) {
                // tabBar没有隐藏，且tabBar是半透明状态
                content_h = content_h - tabBarController.tabBar.frame.size.height;
            }
        }
        
        // 获取当前可用的content高度
        content_h = content_h - content_y;
        
        if let navigationBar = fun.navigationBar {
            if !navigationBar.isHidden {
                navigationBar.frame = CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: navigationBar.bounds.size.height)
                content_y = navigationBar.frame.origin.y + navigationBar.frame.size.height
                content_h = content_h - navigationBar.frame.size.height
            }
        }
        
        if let topView = fun.topView {
            if !topView.isHidden {
                if let navigationBar = fun.navigationBar, navigationBar.isHidden {
                    content_y = self.fun.safeAeraInsets.top
                }
                
                // 利用上面改过的content_y（content顶部的实际可布局位置）
                topView.frame = CGRect.init(x: 0, y: content_y, width: view.frame.size.width, height: topView.bounds.size.height)
                // 再次调整contentView的位置
                content_y = topView.frame.origin.y + topView.frame.size.height
                content_h = content_h - topView.frame.size.height
            }
            
        }
        
        if let bottomView = fun.bottomView {
            if !bottomView.isHidden {
                
                content_h = content_h - bottomView.frame.size.height - fun.safeAeraInsets.bottom;
                
                bottomView.frame = CGRect.init(x: 0, y: content_h, width: view.frame.size.width, height: bottomView.frame.size.height)
            }
        }
        
        contentView.frame = CGRect.init(x: content_x, y: content_y, width: content_w, height: content_h)
        
    }
    
    
    
    public var fun: FunFreedom.FunController {
        set {
            
            objc_setAssociatedObject(self, &funControllerKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        }
        
        get {
            
            if let observations = objc_getAssociatedObject(self, &funControllerKey) {
                return observations as! FunFreedom.FunController
            } else {
                objc_setAssociatedObject(self, &funControllerKey, FunFreedom.FunController(target: self), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return self.fun
        }
    }
    
}

public extension FunFreedom {
    class FunController {
//        private weak var observation_navigationBar: NSKeyValueObservation?
//        private weak var observation_topView: NSKeyValueObservation?
//        private weak var observation_bottomView: NSKeyValueObservation?
//        lazy var observations = [NSKeyValueObservation]
        
        lazy var observations: [NSKeyValueObservation] = {
            let observations = [NSKeyValueObservation]()
            
            return observations
        }()
        private weak var viewController: UIViewController?
        
        init(target: UIViewController?) {
            
            if let target = target {
                viewController = target
                
            }
        }
        
        public var safeAeraInsets: UIEdgeInsets {
            var safeAeraInsets = UIEdgeInsets.zero
            if FunFreedom.device.iPhoneXSeries {
                safeAeraInsets.top = 24
                
                if viewController?.hidesBottomBarWhenPushed == true || viewController?.parent?.hidesBottomBarWhenPushed == true {
                    safeAeraInsets.bottom = 34
                }
            }
            return safeAeraInsets
        }
        
        public var navigationBar: UIView? {
            willSet {
                if navigationBar == newValue {
                    // 输入相同对象时直接忽略
                    return
                }
                
                if let navigationBar = navigationBar {
                    // 存在旧对象时，先移除
                    navigationBar.frame = CGRect.init(x: 0, y: -navigationBar.frame.size.height, width: navigationBar.frame.size.width, height: navigationBar.frame.size.height)
                    navigationBar.removeFromSuperview()
                    
                }
            }
            didSet {
                if let navigationBar = navigationBar, let viewController = viewController {
                    //用了自定义的navigationBar就隐藏系统的导航栏
                    viewController.navigationController?.setNavigationBarHidden(true, animated: false)
                    navigationBar.frame = CGRect.init(x: 0, y: 0, width: viewController.view.frame.size.width, height: navigationBar.bounds.size.height)
                    viewController.view.addSubview(navigationBar)
                    // 监听hidden，方便后面调整frame
//                    observation_navigationBar = navigationBar.observe(\UIView.isHidden) { (_, change) in
//                        viewController.view.setNeedsLayout()
//
//                    }
                    
                    observations.append(navigationBar.observe(\UIView.isHidden) { (_, change) in
                        viewController.view.setNeedsLayout()
                        
                    })
                    
                }
            }
        }
        
        public var topView: UIView? {
            willSet {
                if topView == newValue {
                    // 输入相同对象时直接忽略
                    return
                }
                
                if let topView = topView {
                    // 存在旧对象时，先移除
                    topView.frame = CGRect.init(x: 0, y: -topView.frame.size.height, width: topView.frame.size.width, height: topView.frame.size.height)
                    topView.removeFromSuperview()
                    
                }
            }
            didSet {
                if let topView = topView, let viewController = viewController {
                    var topView_y: CGFloat = 0.0
                    // 有navigationBar时，调整topView的frame
                    if let navigationBar = navigationBar {
                        topView_y = navigationBar.frame.origin.y + navigationBar.frame.size.height
                    }
                    topView.frame = CGRect.init(x: 0.0, y: topView_y, width: viewController.view.frame.size.width, height: topView.bounds.size.height)
                    viewController.view.addSubview(topView)
                    // 监听hidden，方便后面调整frame
//                    observation_topView = topView.observe(\UIView.isHidden) { (_, change) in
//                        viewController.view.setNeedsLayout()
//
//                    }
                    
                    observations.append(topView.observe(\UIView.isHidden) { (_, change) in
                        viewController.view.setNeedsLayout()
                        
                    })
                    
                }
            }
        }
        
        // 原理与topView相同
        public var contentView: UIView? {
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
        
        // 原理与topView相同
        public var bottomView: UIView? {
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
                    
//                    observation_bottomView = bottomView.observe(\UIView.isHidden) { (_, change) in
//                        viewController.view.setNeedsLayout()
//                    }
                    
                    observations.append(bottomView.observe(\UIView.isHidden) { (_, change) in
                        viewController.view.setNeedsLayout()
                        
                    })
                    
                }
            }
        }
        
        fileprivate func resetBackgrounerColor() {
            if let viewController = viewController {
                var fromColor = UIColor.white
                var toColor = UIColor.white
                
                if let topColor = topView?.backgroundColor {
                    fromColor = topColor
                }
                
                if let bottomColor = bottomView?.backgroundColor {
                    toColor = bottomColor
                }
                //CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = viewController.view.bounds
                
                //  创建渐变色数组，需要转换为CGColor颜色
                gradientLayer.colors = [fromColor.cgColor,toColor.cgColor]
                
                //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
                gradientLayer.startPoint = CGPoint.init(x: 1, y: 0)
                gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
                
                // 确定渐变的起点和终点
                let topPosition = Double(safeAeraInsets.top / viewController.view.frame.size.height)
                let bottomPosition = Double(1.0 - safeAeraInsets.bottom / viewController.view.frame.size.height)
                
                //  设置颜色变化点，取值范围 0.0~1.0
                gradientLayer.locations = [NSNumber(floatLiteral: topPosition),NSNumber(floatLiteral: bottomPosition)]
                
                // 将渐变色图层压倒最下
                viewController.view.layer.insertSublayer(gradientLayer, at: 0)
            }
        }
        
        deinit {
            debugPrint("fun die")
            
            bottomView = nil
            contentView = nil
            topView = nil
        }
    }
    
    
}
