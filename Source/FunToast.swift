//
//  FunToast.swift
//  FunFreedom
//
//  Created by 肖华 on 2019/10/22.
//

import UIKit

public extension FunFreedom {
    
    class Toast {
        
        public struct Config {
            var title: String?
            var message: String?
            var inView: UIView?
            var duration: TimeInterval = 0.5
            var point: CGPoint?
            var position: ToastPosition = .bottom
            var image: UIImage?
            var style: ToastStyle = ToastManager.shared.style
            var completion: ((_ didTap: Bool) -> Void)?
        }
        
        fileprivate var config = Config()
        
        public static var `default`: Toast {
            let toast = Toast()
            return toast
        }
        
        public init() {}
        
        public func title(_ title: String) -> Self {
            config.title = title
            
            return self
        }
        
        public func message(_ message: String) -> Self {
            config.message = message
            
            return self
        }
        
        public func inView(_ inView: UIView) -> Self {
            config.inView = inView
            
            return self
        }
        
        public func duration(_ duration: TimeInterval) -> Self {
            config.duration = duration
            
            return self
        }
        
        public func position(_ position: ToastPosition) -> Self {
            config.position = position
            
            return self
        }
        
        public func point(_ point: CGPoint) -> Self {
            config.point = point
            
            return self
        }
        
        public func image(_ image: UIImage) -> Self {
            config.image = image
            
            return self
        }
        
        public func style(_ style: ToastStyle) -> Self {
            config.style = style
            
            return self
        }
        
        public func showToast(_ completion: ((Bool)->Void)? = nil) {
            
            config.completion = completion
            
            let targetView = config.inView ?? FunFreedom.PublicTool.frontController.view ?? UIApplication.shared.keyWindow
            
            targetView?.makeToast(config: config)
            
        }
        
        public func showActivity(_ completion: ((Bool)->Void)? = nil) {
            config.completion = completion
            
            let targetView = config.inView ?? FunFreedom.PublicTool.frontController.view ?? UIApplication.shared.keyWindow
            
            targetView?.makeToastActivity(config: config)
        }
        
        public func dismiss(inView: UIView? = nil) {
            let targetView = inView ?? FunFreedom.PublicTool.frontController.view ?? UIApplication.shared.keyWindow
            
            targetView?.hideToast()
            targetView?.hideToastActivity()
        }
        
    }
    
}

import UIKit

public extension UIView {
    
    /**
     Keys used for associated objects.
     */
    private struct ToastKeys {
        static var timer        = "com.toast-swift.timer"
        static var duration     = "com.toast-swift.duration"
        static var point        = "com.toast-swift.point"
        static var completion   = "com.toast-swift.completion"
        static var activeToasts = "com.toast-swift.activeToasts"
        static var activityView = "com.toast-swift.activityView"
        static var queue        = "com.toast-swift.queue"
    }
    
    private class ToastCompletionWrapper {
        let completion: ((Bool) -> Void)?
        
        init(_ completion: ((Bool) -> Void)?) {
            self.completion = completion
        }
    }
    
    private enum ToastError: Error {
        case missingParameters
    }
    
    private var activeToasts: NSMutableArray {
        get {
            if let activeToasts = objc_getAssociatedObject(self, &ToastKeys.activeToasts) as? NSMutableArray {
                return activeToasts
            } else {
                let activeToasts = NSMutableArray()
                objc_setAssociatedObject(self, &ToastKeys.activeToasts, activeToasts, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return activeToasts
            }
        }
    }
    
    private var queue: NSMutableArray {
        get {
            if let queue = objc_getAssociatedObject(self, &ToastKeys.queue) as? NSMutableArray {
                return queue
            } else {
                let queue = NSMutableArray()
                objc_setAssociatedObject(self, &ToastKeys.queue, queue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return queue
            }
        }
    }
    
    // MARK: - Make Toast Methods
    
    func makeToast(config: FunFreedom.Toast.Config) {
        do {
            let toast = try toastViewForMessage(config.message, title: config.title, image: config.image, style: config.style)
            
            var point = config.position.centerPoint(forToast: toast, inSuperview: self)
            if let a_point = config.point {
                point = a_point
            }
            showToast(toast, duration: config.duration, point: point, completion: config.completion)
        } catch ToastError.missingParameters {
            print("Error: message, title, and image are all nil")
        } catch {}
    }
    
    func showToast(_ toast: UIView, duration: TimeInterval = ToastManager.shared.duration, point: CGPoint, completion: ((_ didTap: Bool) -> Void)? = nil) {
        objc_setAssociatedObject(toast, &ToastKeys.completion, ToastCompletionWrapper(completion), .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if ToastManager.shared.isQueueEnabled, activeToasts.count > 0 {
            objc_setAssociatedObject(toast, &ToastKeys.duration, NSNumber(value: duration), .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(toast, &ToastKeys.point, NSValue(cgPoint: point), .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            queue.add(toast)
        } else {
            showToast(toast, duration: duration, point: point)
        }
    }
    
    // MARK: - Hide Toast Methods
    
    func hideToast() {
        guard let activeToast = activeToasts.firstObject as? UIView else { return }
        hideToast(activeToast)
    }
    
    func hideToast(_ toast: UIView) {
        guard activeToasts.contains(toast) else { return }
        hideToast(toast, fromTap: false)
    }
    
    func hideAllToasts(includeActivity: Bool = false, clearQueue: Bool = true) {
        if clearQueue {
            clearToastQueue()
        }
        
        activeToasts.compactMap { $0 as? UIView }
            .forEach { hideToast($0) }
        
        if includeActivity {
            hideToastActivity()
        }
    }
    
    func clearToastQueue() {
        queue.removeAllObjects()
    }
    
    // MARK: - Activity Methods
    func makeToastActivity(config: FunFreedom.Toast.Config) {
        // sanity
        guard objc_getAssociatedObject(self, &ToastKeys.activityView) as? UIView == nil else { return }
        
        let hasToast = config.title != nil || config.message != nil
        
        ToastManager.shared.style.activitySize = CGSize.init(width: 100, height: 100)
        
        var toast_config = config
        
        if hasToast {
            
            ToastManager.shared.style.activitySize = CGSize.init(width: 135, height: 135)
            
            toast_config.position = .top
            toast_config.completion = nil
            toast_config.duration = 500
            toast_config.style.backgroundColor = .clear
            toast_config.style.verticalPadding = 0
            
        }
        
        let toast = createToastActivityView()
        
        var point = config.position.centerPoint(forToast: toast, inSuperview: self)
        
        if let a_point = config.point {
            point = a_point
        }
        
        makeToastActivity(toast, point: point)
        if hasToast {
            toast.makeToast(config: toast_config)
        }
        
    }
    
    func hideToastActivity() {
        if let toast = objc_getAssociatedObject(self, &ToastKeys.activityView) as? UIView {
            UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
                toast.alpha = 0.0
            }) { _ in
                toast.removeFromSuperview()
                objc_setAssociatedObject(self, &ToastKeys.activityView, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    // MARK: - Private Activity Methods
    
    private func makeToastActivity(_ toast: UIView, point: CGPoint) {
        toast.alpha = 0.0
        toast.center = point
        
        objc_setAssociatedObject(self, &ToastKeys.activityView, toast, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        self.addSubview(toast)
        
        UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: .curveEaseOut, animations: {
            toast.alpha = 1.0
        })
    }
    
    private func createToastActivityView() -> UIView {
        let style = ToastManager.shared.style
        
        let activityView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: style.activitySize.width, height: style.activitySize.height))
        activityView.backgroundColor = style.activityBackgroundColor
        activityView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        activityView.layer.cornerRadius = style.cornerRadius
        
        if style.displayShadow {
            activityView.layer.shadowColor = style.shadowColor.cgColor
            activityView.layer.shadowOpacity = style.shadowOpacity
            activityView.layer.shadowRadius = style.shadowRadius
            activityView.layer.shadowOffset = style.shadowOffset
        }
        
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicatorView.center = CGPoint(x: activityView.bounds.size.width / 2.0, y: activityView.bounds.size.height / 2.0)
        activityView.addSubview(activityIndicatorView)
        activityIndicatorView.color = style.activityIndicatorColor
        activityIndicatorView.startAnimating()
        
        return activityView
    }
    
    // MARK: - Private Show/Hide Methods
    
    private func showToast(_ toast: UIView, duration: TimeInterval, point: CGPoint) {
        toast.center = point
        toast.alpha = 0.0
        
        if ToastManager.shared.isTapToDismissEnabled {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(UIView.handleToastTapped(_:)))
            toast.addGestureRecognizer(recognizer)
            toast.isUserInteractionEnabled = true
            toast.isExclusiveTouch = true
        }
        
        activeToasts.add(toast)
        self.addSubview(toast)
        
        UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            toast.alpha = 1.0
        }) { _ in
            let timer = Timer(timeInterval: duration, target: self, selector: #selector(UIView.toastTimerDidFinish(_:)), userInfo: toast, repeats: false)
            RunLoop.main.add(timer, forMode: .common)
            objc_setAssociatedObject(toast, &ToastKeys.timer, timer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func hideToast(_ toast: UIView, fromTap: Bool) {
        if let timer = objc_getAssociatedObject(toast, &ToastKeys.timer) as? Timer {
            timer.invalidate()
        }
        
        UIView.animate(withDuration: ToastManager.shared.style.fadeDuration, delay: 0.0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
            toast.alpha = 0.0
        }) { _ in
            toast.removeFromSuperview()
            self.activeToasts.remove(toast)
            
            if let wrapper = objc_getAssociatedObject(toast, &ToastKeys.completion) as? ToastCompletionWrapper, let completion = wrapper.completion {
                completion(fromTap)
            }
            
            if let nextToast = self.queue.firstObject as? UIView, let duration = objc_getAssociatedObject(nextToast, &ToastKeys.duration) as? NSNumber, let point = objc_getAssociatedObject(nextToast, &ToastKeys.point) as? NSValue {
                self.queue.removeObject(at: 0)
                self.showToast(nextToast, duration: duration.doubleValue, point: point.cgPointValue)
            }
        }
    }
    
    // MARK: - Events
    
    @objc private func handleToastTapped(_ recognizer: UITapGestureRecognizer) {
        guard let toast = recognizer.view else { return }
        hideToast(toast, fromTap: true)
    }
    
    @objc private func toastTimerDidFinish(_ timer: Timer) {
        guard let toast = timer.userInfo as? UIView else { return }
        hideToast(toast)
    }
    
    // MARK: - Toast Construction
    
    func toastViewForMessage(_ message: String?, title: String?, image: UIImage?, style: ToastStyle) throws -> UIView {
        // sanity
        guard message != nil || title != nil || image != nil else {
            throw ToastError.missingParameters
        }
        
        var messageLabel: UILabel?
        var titleLabel: UILabel?
        var imageView: UIImageView?
        
        let wrapperView = UIView()
        wrapperView.backgroundColor = style.backgroundColor
        wrapperView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        wrapperView.layer.cornerRadius = style.cornerRadius
        
        if style.displayShadow {
            wrapperView.layer.shadowColor = UIColor.black.cgColor
            wrapperView.layer.shadowOpacity = style.shadowOpacity
            wrapperView.layer.shadowRadius = style.shadowRadius
            wrapperView.layer.shadowOffset = style.shadowOffset
        }
        
        if let image = image {
            imageView = UIImageView(image: image)
            imageView?.contentMode = .scaleAspectFit
            imageView?.frame = CGRect(x: style.horizontalPadding, y: style.verticalPadding, width: style.imageSize.width, height: style.imageSize.height)
        }
        
        var imageRect = CGRect.zero
        
        if let imageView = imageView {
            imageRect.origin.x = style.horizontalPadding
            imageRect.origin.y = style.verticalPadding
            imageRect.size.width = imageView.bounds.size.width
            imageRect.size.height = imageView.bounds.size.height
        }
        
        if let title = title {
            titleLabel = UILabel()
            titleLabel?.numberOfLines = style.titleNumberOfLines
            titleLabel?.font = style.titleFont
            titleLabel?.textAlignment = style.titleAlignment
            titleLabel?.lineBreakMode = .byTruncatingTail
            titleLabel?.textColor = style.titleColor
            titleLabel?.backgroundColor = UIColor.clear
            titleLabel?.text = title;
            
            let maxTitleSize = CGSize(width: (self.bounds.size.width * style.maxWidthPercentage) - imageRect.size.width, height: self.bounds.size.height * style.maxHeightPercentage)
            let titleSize = titleLabel?.sizeThatFits(maxTitleSize)
            if let titleSize = titleSize {
                titleLabel?.frame = CGRect(x: 0.0, y: 0.0, width: titleSize.width, height: titleSize.height)
            }
        }
        
        if let message = message {
            messageLabel = UILabel()
            messageLabel?.text = message
            messageLabel?.numberOfLines = style.messageNumberOfLines
            messageLabel?.font = style.messageFont
            messageLabel?.textAlignment = style.messageAlignment
            messageLabel?.lineBreakMode = .byTruncatingTail;
            messageLabel?.textColor = style.messageColor
            messageLabel?.backgroundColor = UIColor.clear
            
            let maxMessageSize = CGSize(width: (self.bounds.size.width * style.maxWidthPercentage) - imageRect.size.width, height: self.bounds.size.height * style.maxHeightPercentage)
            let messageSize = messageLabel?.sizeThatFits(maxMessageSize)
            if let messageSize = messageSize {
                let actualWidth = min(messageSize.width, maxMessageSize.width)
                let actualHeight = min(messageSize.height, maxMessageSize.height)
                messageLabel?.frame = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
            }
        }
        
        var titleRect = CGRect.zero
        
        if let titleLabel = titleLabel {
            titleRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding
            titleRect.origin.y = style.verticalPadding
            titleRect.size.width = titleLabel.bounds.size.width
            titleRect.size.height = titleLabel.bounds.size.height
        }
        
        var messageRect = CGRect.zero
        
        if let messageLabel = messageLabel {
            messageRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding
            messageRect.origin.y = titleRect.origin.y + titleRect.size.height + style.verticalPadding
            messageRect.size.width = messageLabel.bounds.size.width
            messageRect.size.height = messageLabel.bounds.size.height
        }
        
        let longerWidth = max(titleRect.size.width, messageRect.size.width)
        let longerX = max(titleRect.origin.x, messageRect.origin.x)
        let wrapperWidth = max((imageRect.size.width + (style.horizontalPadding * 2.0)), (longerX + longerWidth + style.horizontalPadding))
        let wrapperHeight = max((messageRect.origin.y + messageRect.size.height + style.verticalPadding), (imageRect.size.height + (style.verticalPadding * 2.0)))
        
        wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)
        
        if let titleLabel = titleLabel {
            titleRect.size.width = longerWidth
            titleLabel.frame = titleRect
            wrapperView.addSubview(titleLabel)
        }
        
        if let messageLabel = messageLabel {
            messageRect.size.width = longerWidth
            messageLabel.frame = messageRect
            wrapperView.addSubview(messageLabel)
        }
        
        if let imageView = imageView {
            wrapperView.addSubview(imageView)
        }
        
        return wrapperView
    }
    
}

// MARK: - Toast Style

public struct ToastStyle {
    
    public init() {}
    
    /**
     The background color. Default is `.black` at 80% opacity.
     */
    public var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)
    
    /**
     The title color. Default is `UIColor.whiteColor()`.
     */
    public var titleColor: UIColor = .white
    
    /**
     The message color. Default is `.white`.
     */
    public var messageColor: UIColor = .white
    
    /**
     A percentage value from 0.0 to 1.0, representing the maximum width of the toast
     view relative to it's superview. Default is 0.8 (80% of the superview's width).
     */
    public var maxWidthPercentage: CGFloat = 0.8 {
        didSet {
            maxWidthPercentage = max(min(maxWidthPercentage, 1.0), 0.0)
        }
    }
    
    /**
     A percentage value from 0.0 to 1.0, representing the maximum height of the toast
     view relative to it's superview. Default is 0.8 (80% of the superview's height).
     */
    public var maxHeightPercentage: CGFloat = 0.8 {
        didSet {
            maxHeightPercentage = max(min(maxHeightPercentage, 1.0), 0.0)
        }
    }
    
    /**
     The spacing from the horizontal edge of the toast view to the content. When an image
     is present, this is also used as the padding between the image and the text.
     Default is 10.0.
     
     */
    public var horizontalPadding: CGFloat = 10.0
    
    /**
     The spacing from the vertical edge of the toast view to the content. When a title
     is present, this is also used as the padding between the title and the message.
     Default is 10.0. On iOS11+, this value is added added to the `safeAreaInset.top`
     and `safeAreaInsets.bottom`.
     */
    public var verticalPadding: CGFloat = 10.0
    
    /**
     The corner radius. Default is 10.0.
     */
    public var cornerRadius: CGFloat = 10.0;
    
    /**
     The title font. Default is `.boldSystemFont(16.0)`.
     */
    public var titleFont: UIFont = .boldSystemFont(ofSize: 16.0)
    
    /**
     The message font. Default is `.systemFont(ofSize: 16.0)`.
     */
    public var messageFont: UIFont = .systemFont(ofSize: 16.0)
    
    /**
     The title text alignment. Default is `NSTextAlignment.Left`.
     */
    public var titleAlignment: NSTextAlignment = .left
    
    /**
     The message text alignment. Default is `NSTextAlignment.Left`.
     */
    public var messageAlignment: NSTextAlignment = .left
    
    /**
     The maximum number of lines for the title. The default is 0 (no limit).
     */
    public var titleNumberOfLines = 0
    
    /**
     The maximum number of lines for the message. The default is 0 (no limit).
     */
    public var messageNumberOfLines = 0
    
    /**
     Enable or disable a shadow on the toast view. Default is `false`.
     */
    public var displayShadow = false
    
    /**
     The shadow color. Default is `.black`.
     */
    public var shadowColor: UIColor = .black
    
    /**
     A value from 0.0 to 1.0, representing the opacity of the shadow.
     Default is 0.8 (80% opacity).
     */
    public var shadowOpacity: Float = 0.8 {
        didSet {
            shadowOpacity = max(min(shadowOpacity, 1.0), 0.0)
        }
    }
    
    /**
     The shadow radius. Default is 6.0.
     */
    public var shadowRadius: CGFloat = 6.0
    
    /**
     The shadow offset. The default is 4 x 4.
     */
    public var shadowOffset = CGSize(width: 4.0, height: 4.0)
    
    /**
     The image size. The default is 80 x 80.
     */
    public var imageSize = CGSize(width: 80.0, height: 80.0)
    
    /**
     The size of the toast activity view when `makeToastActivity(position:)` is called.
     Default is 100 x 100.
     */
    public var activitySize = CGSize(width: 100.0, height: 100.0)
    
    /**
     The fade in/out animation duration. Default is 0.2.
     */
    public var fadeDuration: TimeInterval = 0.2
    
    /**
     Activity indicator color. Default is `.white`.
     */
    public var activityIndicatorColor: UIColor = .white
    
    /**
     Activity background color. Default is `.black` at 80% opacity.
     */
    public var activityBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)
    
}

// MARK: - Toast Manager

public class ToastManager {
    
    /**
     The `ToastManager` singleton instance.
     
     */
    public static let shared = ToastManager()
    
    /**
     The shared style. Used whenever toastViewForMessage(message:title:image:style:) is called
     with with a nil style.
     
     */
    public var style = ToastStyle()
    
    /**
     Enables or disables tap to dismiss on toast views. Default is `true`.
     
     */
    public var isTapToDismissEnabled = true
    
    /**
     Enables or disables queueing behavior for toast views. When `true`,
     toast views will appear one after the other. When `false`, multiple toast
     views will appear at the same time (potentially overlapping depending
     on their positions). This has no effect on the toast activity view,
     which operates independently of normal toast views. Default is `false`.
     
     */
    public var isQueueEnabled = false
    
    /**
     The default duration. Used for the `makeToast` and
     `showToast` methods that don't require an explicit duration.
     Default is 3.0.
     
     */
    public var duration: TimeInterval = 3.0
    
    /**
     Sets the default position. Used for the `makeToast` and
     `showToast` methods that don't require an explicit position.
     Default is `ToastPosition.Bottom`.
     
     */
    public var position: ToastPosition = .bottom
    
}

// MARK: - ToastPosition

public enum ToastPosition {
    case top
    case center
    case bottom
    
    fileprivate func centerPoint(forToast toast: UIView, inSuperview superview: UIView) -> CGPoint {
        let topPadding: CGFloat = ToastManager.shared.style.verticalPadding + superview.csSafeAreaInsets.top
        let bottomPadding: CGFloat = ToastManager.shared.style.verticalPadding + superview.csSafeAreaInsets.bottom
        
        switch self {
        case .top:
            return CGPoint(x: superview.bounds.size.width / 2.0, y: (toast.frame.size.height / 2.0) + topPadding)
        case .center:
            return CGPoint(x: superview.bounds.size.width / 2.0, y: superview.bounds.size.height / 2.0)
        case .bottom:
            return CGPoint(x: superview.bounds.size.width / 2.0, y: (superview.bounds.size.height - (toast.frame.size.height / 2.0)) - bottomPadding)
        }
    }
}

// MARK: - Private UIView Extensions

private extension UIView {
    
    var csSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets
        } else {
            return .zero
        }
    }
    
}

