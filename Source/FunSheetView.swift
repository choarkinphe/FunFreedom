//
//  FunSheetView.swift
//  Alamofire
//
//  Created by 肖华 on 2019/10/15.
//

import Foundation
extension FunFreedom {
    open class ActionSheetToolBar: UIView {
        
        public var tipLabel = UILabel()
        public var cancelButton = UIButton()
        public var doneButton = UIButton()
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            
            cancelButton.setTitleColor(UIColor.init(red: 61.0/255.0, green: 130.0/255.0, blue: 247.0/255.0, alpha: 1), for: .normal)
            cancelButton.setTitle("Cancel", for: .normal)
            addSubview(cancelButton)
            cancelButton.addTarget(self, action: #selector(cancelAction(sender:)), for: .touchUpInside)
            
            doneButton.setTitleColor(UIColor.init(red: 61.0/255.0, green: 130.0/255.0, blue: 247.0/255.0, alpha: 1), for: .normal)
            doneButton.setTitle("Done", for: .normal)
            addSubview(doneButton)
            doneButton.addTarget(self, action: #selector(doneAction(sender:)), for: .touchUpInside)
            
            tipLabel.font = UIFont.systemFont(ofSize: 14)
            tipLabel.textColor = UIColor.init(white: 0.3, alpha: 1)
            tipLabel.textAlignment = .center
            addSubview(tipLabel)
            
            
        }
        
        required public init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc func cancelAction(sender: UIButton) {
            if let handler = cancelHandler {
                handler()
            }
        }
        
        @objc func doneAction(sender: UIButton) {
            if let handler = doneHandler {
                handler()
            }
        }
        
        private var doneHandler: (()->Void)?
        public final func doneHandler(_ a_doneHandler: @escaping (()->Void)) {
            doneHandler = a_doneHandler
        }
        
        private var cancelHandler: (()->Void)?
        public final func cancelHandler(_ a_cancelHandler: @escaping (()->Void)) {
            cancelHandler = a_cancelHandler
        }
        
        open override func layoutSubviews() {
            super.layoutSubviews()
            
            cancelButton.frame = CGRect.init(x: 12, y: 4, width: 66, height: 36)
            doneButton.frame = CGRect.init(x: bounds.size.width - 78, y: 4, width: 66, height: 36)
            tipLabel.bounds = CGRect.init(x: 0, y: 0, width: bounds.size.width - 156, height: 36)
            tipLabel.center = center
        }
    }
    open class ActionSheetHeader: UIView {
        
        convenience init(title a_title: String?, detail a_detail: String? = nil) {
            
            var height: CGFloat = 49.0
            if a_detail != nil {
                height = 83.0
            }
            
            let frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height)
            
            self.init(frame: frame)
            
            self.titleLabel.text = a_title
            self.detailLabel.text = a_detail
            
        }
        
        
        public var titleLabel = UILabel()
        public var detailLabel = UILabel()
        private var bottomLine = CALayer()
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            
            backgroundColor = .white
            
            titleLabel.textColor = UIColor.darkText
            titleLabel.font = UIFont.systemFont(ofSize: 16)
            addSubview(titleLabel)
            
            detailLabel.textColor = UIColor.lightText
            detailLabel.font = UIFont.systemFont(ofSize: 14)
            addSubview(detailLabel)
        }
        
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        open override func layoutSubviews() {
            super.layoutSubviews()
            
            titleLabel.frame = CGRect.init(x: 12, y: 12, width: bounds.size.width - 24, height: 22)
            detailLabel.frame = CGRect.init(x: 12, y: 44, width: bounds.size.width - 24, height: 22)
        }
        
        open override func draw(_ rect: CGRect) {
            super.draw(rect)
            
            bottomLine.frame = CGRect.init(x: 0, y: rect.size.height - 0.5, width: rect.size.width, height: 0.5)
            bottomLine.backgroundColor = UIColor.init(white: 0.85, alpha: 1).cgColor
            
            layer.addSublayer(bottomLine)
        }
    }
}


