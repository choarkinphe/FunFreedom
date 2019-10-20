//
//  DataPicker.swift
//  FunFreedom
//
//  Created by choarkinphe on 2019/10/21.
//

import Foundation

public typealias HandlerByDateStr = ((String)->Void)
public typealias HandlerByDate = ((Date)->Void)
public extension FunFreedom {
    
    private struct DatePickerConfig {
        
        var position: DatePicker.Position = .default
        
        var formatter = DateFormatter()
        
        var showDate: Date?
        
        var showAnimated: Bool = false
        
        var dateHandler: HandlerByDate?
        var dateStrHandler: HandlerByDateStr?
    }
    
    class DatePicker: UIViewController {
        
        private var iPhoneXSeries: Bool = false
        
        public enum Position : Int {
            case `default`
            
            case center
            
        }
        
        private lazy var config: DatePickerConfig = {
            let _config = DatePickerConfig()
            _config.formatter.dateFormat = "dd/MM/YYYY"
            return _config
            
        }()
        
        public static var `default`: DatePicker {
            
            var datePicker = DatePicker()
            
            datePicker = datePicker.datePickerMode(.date)
            
            return datePicker
        }
        
        private lazy var toolBar: DatePickerHeader = {
            let toolBar = DatePickerHeader.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
            
            toolBar.doneButton.setTitleColor(UIColor.orange, for: .normal)
            toolBar.doneButton.setTitle("Done", for: .normal)
            toolBar.doneButton.addTarget(self, action: #selector(selectedAction(sender:)), for: .touchUpInside)
            
            toolBar.cancelButton.setTitleColor(UIColor.orange, for: .normal)
            toolBar.cancelButton.setTitle("Cancel", for: .normal)
            toolBar.cancelButton.addTarget(self, action: #selector(tapDismissAction(_:)), for: .touchUpInside)
            
            return toolBar
        }()
        
        private lazy var datePicker = UIDatePicker()
        
        override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
            
            modalTransitionStyle = .coverVertical
            modalPresentationStyle = .overFullScreen
            view.backgroundColor = UIColor.init(white: 0, alpha: 0)
            datePicker.calendar = Calendar.current
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
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        open override func viewDidLoad() {
            super.viewDidLoad()
            
            
            
            view.addSubview(toolBar)
            
            datePicker.backgroundColor = UIColor.white
            view.addSubview(datePicker)
            
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapDismissAction(_:)))
            tapGes.delegate = self
            view.addGestureRecognizer(tapGes)
            
        }
        
        private lazy var safeBottomView: UIView = {
            let _safeBottomView = UIView.init(frame: .zero)
            _safeBottomView.backgroundColor = .white
            view.addSubview(_safeBottomView)
            return _safeBottomView
        }()
        
        open override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            let datePicker_w: CGFloat = view.bounds.size.width
            let datePicker_h: CGFloat = 216.0
            let toolBar_h: CGFloat = toolBar.frame.size.height
            var datePicker_y = view.bounds.size.height - datePicker_h
            if iPhoneXSeries {
                datePicker_y = datePicker_y - 24
                safeBottomView.frame = CGRect.init(x: 0, y: view.bounds.size.height - 24, width: datePicker_w, height: 24)
            }
            datePicker.frame = CGRect.init(x: 0, y: datePicker_y, width: datePicker_w, height: datePicker_h)
            
            if config.position == .center {
                datePicker.center = view.center
                datePicker_y = datePicker.frame.origin.y
            }
            
            toolBar.frame = CGRect.init(x: 0, y: datePicker_y - toolBar_h, width: datePicker_w, height: toolBar_h)
        }
        
        @objc private func selectedAction(sender: Any) {
            
            if let dateHandler = config.dateHandler {
                dateHandler(datePicker.date)
            }
            
            if let dateStrHandler = config.dateStrHandler {
                dateStrHandler(config.formatter.string(from: datePicker.date))
            }
            
            dismiss(animated: true, completion: nil)
            
        }
        
        
        @objc private func tapDismissAction(_ tapGes : UITapGestureRecognizer){
            self.dismiss(animated: true, completion: nil)
        }
        
        open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            let rootViewController = UIApplication.shared.keyWindow?.rootViewController
            let coverView = UIView.init(frame: UIScreen.main.bounds)
            coverView.backgroundColor = UIColor.init(white: 0, alpha: 0.35)
            
            rootViewController?.view.addSubview(coverView)
            view.backgroundColor = UIColor.init(white: 0, alpha: 0)
            UIView.animate(withDuration: 0.3) {
                coverView.alpha = 0
            }
            super.dismiss(animated: flag) {
                coverView.removeFromSuperview()
            }
            
        }
        
        
    }
    
    private class DatePickerHeader: UIView {
        
        var titleLabel = UILabel()
        var doneButton = UIButton()
        var cancelButton = UIButton()
        private let topLine = CALayer()
        private let bottomLine = CALayer()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            backgroundColor = .white
            
            titleLabel.textColor = .darkText
            titleLabel.font = UIFont.systemFont(ofSize: 16)
            addSubview(titleLabel)
            
            addSubview(doneButton)
            addSubview(cancelButton)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            cancelButton.frame = CGRect.init(x: 8, y: 0, width: 60, height: frame.size.height)
            doneButton.frame = CGRect.init(x: frame.size.width - 68, y: 0, width: 60, height: frame.size.height)
            titleLabel.center = center
            titleLabel.sizeToFit()
        }
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            
            topLine.frame = CGRect.init(x: 0, y: 0, width: rect.size.width, height: 0.5)
            topLine.backgroundColor = UIColor.lightGray.cgColor
            
            layer.addSublayer(topLine)
            
            bottomLine.frame = CGRect.init(x: 0, y: rect.size.height - 0.5, width: rect.size.width, height: 0.5)
            bottomLine.backgroundColor = UIColor.init(white: 0.87, alpha: 1).cgColor
            
            layer.addSublayer(bottomLine)
        }
    }
    
    
    
    
}

public extension FunFreedom.DatePicker {
    func present(from: UIViewController? = nil) {
        
        var rootViewController = from ?? UIApplication.shared.keyWindow?.rootViewController
        
        if let presentedViewController = rootViewController?.presentedViewController {
            rootViewController = presentedViewController
        }
        
        let coverView = UIView.init(frame: UIScreen.main.bounds)
        coverView.backgroundColor = UIColor.init(white: 0, alpha: 0)
        
        rootViewController?.view.addSubview(coverView)
        UIView.animate(withDuration: 0.3) {
            coverView.backgroundColor = UIColor.init(white: 0, alpha: 0.35)
        }
        
        rootViewController?.present(self, animated: true) {
            
            self.view.backgroundColor = UIColor.init(white: 0, alpha: 0.35)
            coverView.removeFromSuperview()
            
            if let show_date = self.config.showDate {
                self.datePicker.setDate(show_date, animated: self.config.showAnimated)
            }
        }
        
    }
    
    func handlerByDate(_ handlerByDate: @escaping HandlerByDate) -> Self {
        config.dateHandler = handlerByDate
        
        return self
    }
    
    func handlerByDateStr(_ handlerByDateStr: @escaping HandlerByDateStr) -> Self {
        config.dateStrHandler = handlerByDateStr
        
        return self
    }
    
    func title(_ title: String) -> Self {
        toolBar.titleLabel.text = title
        
        return self
    }
    
    func doneButton(title a_title: String? = nil, titleColor a_titleColor: UIColor? = nil) -> Self {
        toolBar.doneButton.setTitle(a_title, for: .normal)
        if let color = a_titleColor {
            toolBar.doneButton.setTitleColor(color, for: .normal)
        }
        return self
    }
    
    func cancelButton(title a_title: String? = nil, titleColor a_titleColor: UIColor? = nil) -> Self {
        toolBar.cancelButton.setTitle(a_title, for: .normal)
        if let color = a_titleColor {
            toolBar.cancelButton.setTitleColor(color, for: .normal)
        }
        return self
    }
    
    func setDate(dateStr a_dateStr: String?, animated a_animated: Bool? = nil) -> Self {
        
        if let dateStr = a_dateStr {
            guard let date = config.formatter.date(from: dateStr) else { return self }
            
            return setDate(date: date, animated: a_animated)
        }
        
        return self
    }
    
    func setDate(date a_date: Date?, animated a_animated: Bool? = nil) -> Self {
        
        config.showDate = a_date
        if let animated = a_animated {
            config.showAnimated = animated
        }
        
        return self
    }
    
    func dateFormatter(_ formatterStr: String) -> Self {
        
        config.formatter.dateFormat = formatterStr
        
        return self
    }
    
    func datePickerMode(_ datePickerMode: UIDatePicker.Mode) -> Self {
        
        datePicker.datePickerMode = datePickerMode
        
        return self
    }
    
    func minuteInterval(_ minuteInterval: Int) -> Self {
        datePicker.minuteInterval = minuteInterval
        return self
    }
    
    func minimumDate(_ minimumDateStr: String) -> Self {
        guard let date = config.formatter.date(from: minimumDateStr) else { return self }
        return minimumDate(date)
    }
    
    func minimumDate(_ minimumDate: Date) -> Self {
        datePicker.minimumDate = minimumDate
        
        return self
    }
    
    func maximumDate(_ maximumDateStr: String) -> Self {
        guard let date = config.formatter.date(from: maximumDateStr) else { return self }
        return maximumDate(date)
    }
    
    func maximumDate(_ maximumDate: Date) -> Self {
        datePicker.maximumDate = maximumDate
        
        return self
    }
    
}

extension FunFreedom.DatePicker: UIGestureRecognizerDelegate {
    // MARK: TapAction
    private func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if touch.view == self.datePicker || touch.view == self.toolBar {
            return false
        } else {
            return true
        }
    }
}

public extension UIDatePicker {
    // 去掉中间 row 上的分割线
    private func sepearatorLineHidden(_ isHidden: Bool) {
        for subView in self.subviews {
            if subView.isKind(of: UIPickerView.self) {
                for sub in subView.subviews {
                    if sub.frame.size.height < 1 {
                        sub.isHidden = isHidden
                    }
                }
            }
        }
    }
    
    // 设置中间 row 上的背景颜色
    private func selectBackgroundColor(_ backgroundColor: UIColor, _ alpha: CGFloat? = nil) {
        let selectView = self.subviews[0]
        let colorView = UIView.init(frame: selectView.bounds)
        colorView.backgroundColor = backgroundColor
        let a_alpha = alpha ?? 0.2
        colorView.alpha = a_alpha
        colorView.center = selectView.center
        selectView.addSubview(colorView)
    }
    
    private func selectTextColor(_ textColor: UIColor) {
        setValue(textColor, forKey: "textColor")
    }
    
}

