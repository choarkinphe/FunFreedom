//
//  FunAlert.swift
//  FunFreedom
//
//  Created by choarkinphe on 2019/10/21.
//

import Foundation


public extension FunFreedom {
    private struct AlertConfig {
        
        var titleColor: UIColor?
        
        var titleFont: UIFont?
        
        var title: String?
        
        var messageColor: UIColor?
        
        var messageFont: UIFont?
        
        var message: String?
        
        var attributedTitle: NSMutableAttributedString?
        
        var attributedMessage: NSMutableAttributedString?
        
        var actions: [UIAlertAction]?
        
    }
    
    
    
    class Alert {
        
        private var style: UIAlertController.Style = .alert
        
        private lazy var config: AlertConfig = {
            var _config = AlertConfig()
            _config.titleColor = .darkText
            _config.messageColor = .darkGray
            _config.titleFont = UIFont.systemFont(ofSize: 16)
            _config.messageFont = UIFont.systemFont(ofSize: 15)
            return _config
        }()
        
        public static var `default`: Alert {
            
            let alert = Alert()
            alert.config.titleFont = UIFont.systemFont(ofSize: 17)
            
            return alert.style(.alert)
        }
        
        public func style(_ a_style: UIAlertController.Style) -> Self {
            style = a_style
            
            return self
        }
        
        public func titleColor(titleColor: UIColor) -> Self {
            
            config.titleColor = titleColor
            
            return self
        }
        
        public func titleFont(titleFont: UIFont) -> Self {
            
            config.titleFont = titleFont
            
            return self
        }
        
        public func title(title: String, titleFont: UIFont? = nil, titleColor: UIColor? = nil) -> Self {
            
            config.title = title
            
            config.titleFont = titleFont
            
            config.titleColor = titleColor
            
            return self
        }
        
        public func messageColor(messageColor: UIColor) -> Self {
            config.messageColor = messageColor
            
            return self
        }
        
        public func messageFont(messageFont: UIFont) -> Self {
            
            config.messageFont = messageFont
            
            return self
        }
        
        public func message(message: String?, messageFont: UIFont? = nil, messageColor: UIColor? = nil) -> Self {
            
            config.message = message
            
            config.messageFont = messageFont
            
            config.messageColor = messageColor
            
            return self
        }
        
        public func addActionTitles(titles: [String], titleColor: UIColor? = nil, handler: @escaping ((UIAlertAction) -> Void)) -> Self {
            
            if config.actions == nil {
                config.actions = [UIAlertAction]()
            }
            
            for title in titles {
                let action = UIAlertAction.init(title: title, style: .default, handler: handler)
                if let titleTextColor = titleColor {
                    action.setValue(titleTextColor, forKey: "titleTextColor")
                }
                config.actions?.append(action)
            }
            
            return self
        }
        
        public func addAction(title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil) -> Self {
            
            return addAction(title: title, style: style, color: nil, handler: handler)
        }
        
        public func addAction(title: String?, style: UIAlertAction.Style, color: UIColor? = nil, handler: ((UIAlertAction) -> Void)? = nil) -> Self {
            
            if config.actions == nil {
                config.actions = [UIAlertAction]()
            }
            
            let action = UIAlertAction.init(title: title, style: style, handler: handler)
            
            if let titleTextColor = color {
                action.setValue(titleTextColor, forKey: "titleTextColor")
            }
            
            config.actions?.append(action)
            
            return self
        }
        
        public func show(from: UIViewController? = nil) {
            
            let alertController = UIAlertController.init(title: config.title, message: config.message, preferredStyle: self.style)
            
            if var title = config.title {
                if style == .actionSheet {
                    title = "\n\(title)"
                }
                let attributedTitle = NSMutableAttributedString.init(string: title)
                
                attributedTitle.addAttribute(NSAttributedString.Key.font, value: config.titleFont ?? UIFont.systemFont(ofSize: 15), range: NSRange.init(location: 0, length: attributedTitle.length))
                attributedTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: config.titleColor ?? UIColor.darkText, range: NSRange.init(location: 0, length: attributedTitle.length))
                alertController.setValue(attributedTitle, forKey: "attributedTitle")
                
            }
            
            if let attributedTitle = config.attributedTitle {
                alertController.setValue(attributedTitle, forKey: "attributedTitle")
            }
            
            if var message = config.message {
                if style == .actionSheet {
                    message = "\n\(message)"
                }
                let attributedMessage = NSMutableAttributedString.init(string: message)
                
                attributedMessage.addAttribute(NSAttributedString.Key.font, value: config.messageFont ?? UIFont.systemFont(ofSize: 15), range: NSRange.init(location: 0, length: attributedMessage.length))
                attributedMessage.addAttribute(NSAttributedString.Key.foregroundColor, value: config.messageColor ?? UIColor.darkText, range: NSRange.init(location: 0, length: attributedMessage.length))
                
                alertController.setValue(attributedMessage, forKey: "attributedMessage")
            }
            
            if let attributedMessage = config.attributedMessage {
                alertController.setValue(attributedMessage, forKey: "attributedMessage")
            }
            
            if let actions = config.actions {
                for (index,action) in actions.enumerated() {
                    alertController.addAction(action)
                    action.index = index
                    
                }
            }
            
            
            var rootViewController = from ?? UIApplication.shared.keyWindow?.rootViewController
            
            if let presentedViewController = rootViewController?.presentedViewController {
                rootViewController = presentedViewController
            }
            
            rootViewController?.present(alertController, animated: true) {
                
            }
        }
        
        deinit {
            print("alert config die")
        }
        
        
        
    }
}

private var FunAlertActionTagKey = "FunAlertActionTag_Key"
public extension UIAlertAction {
    var index: Int {
        set {
            objc_setAssociatedObject(self, &FunAlertActionTagKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
        
        get {
            if let rs = objc_getAssociatedObject(self, &FunAlertActionTagKey) {
                return rs as! Int
            }
            return 0
        }
    }
}

