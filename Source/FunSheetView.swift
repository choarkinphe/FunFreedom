//
//  FunSheetView.swift
//  Alamofire
//
//  Created by 肖华 on 2019/10/15.
//

import Foundation
extension FunFreedom {
    class ActionSheetToolBar: UIView {
        
        public var isMultiSelector = false
        public var tipLabel = UILabel()
        public var cancelButton = UIButton()
        public var doneButton = UIButton()
        
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            
            backgroundColor = .white
            
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
            cancelButton.isHidden = !isMultiSelector
            doneButton.frame = CGRect.init(x: bounds.size.width - 78, y: 4, width: 66, height: 36)
            doneButton.isHidden = !isMultiSelector
            tipLabel.bounds = CGRect.init(x: 0, y: 0, width: bounds.size.width - 156, height: 36)
            tipLabel.center = center
        }
    }

}


