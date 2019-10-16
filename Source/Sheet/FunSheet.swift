//
//  FunSheet.swift
//  FunFreedom
//
//  Created by 肖华 on 2019/10/15.
//

import Foundation
public typealias FunActionSheetHandler = (FunActionSheet) -> Void
public typealias FunActionSheetMultiHandler = ([FunActionSheet]) -> Void

public class FunActionSheet: NSObject {
    
    public enum Style : Int {
        case `default`
        
        case cancel
        
        case destructive
    }

    open var value: String?
    
    open var title: String?
    
    open var isSelected: Bool = false
    
    open var style: FunActionSheet.Style = .default

    open var index: Int = 0
    
    public init(title a_title: String?, value a_value: String? = nil, style a_style: FunActionSheet.Style) {
        super.init()
        
        self.title = a_title
        self.value = a_value
        self.style = a_style

    }

}

public class FunSheet {
    
    public lazy var sheetController = FunActionSheetController()
    private var _actions = [FunActionSheet]()
    
    public init() {
        sheetController.config.contentInsets = UIEdgeInsets.init(top: 170, left: 0, bottom: 0, right: 0)
        sheetController.config.cornerRadius = 8
    }
    
    
    public func addAction(title: String, value: String? = nil) -> Self {

        return addActions(FunActionSheet.init(title: title, value: value, style: .default))
    }
    
    public func addActions(titles: [String], values: [String]? = nil) -> Self {
        
        for (index,title) in titles.enumerated() {
            let action = FunActionSheet.init(title: title, style: .default)

            if let a_values = values {
                if index < a_values.count {
                    action.value = a_values[index]
                }
            }
            _actions.append(action)
        }
        
        return self
    }
    
    public func resultActions(_ actions: [FunActionSheet]) -> Self {
        
        sheetController.result = actions
        
        return self
    }
    
    public func addActions(_ action: FunActionSheet) -> Self {
        _actions.append(action)
        
        return self
    }
    
    public func addActions(_ actions: [FunActionSheet]) -> Self {
        _actions.append(contentsOf: actions)
        
        return self
    }
    
    public func setHeaderTitle(_ headerTitle: String, _ headerDetail: String? = nil) -> Self {
        
        let header = FunActionSheetHeader.init(title: headerTitle, detail: headerDetail)
        
        return setHeaderView(header)
    }
    
    public func setHeaderView(_ headerView: UIView) -> Self {
        
        sheetController.topView = headerView
        
        return self
    }
    
    
    public func handler(_ handler: @escaping FunActionSheetHandler) -> Self {
        sheetController.handler = handler
        return self
    }
    
    public func multiHandler(_ multiHandler: @escaping FunActionSheetMultiHandler) -> Self {
        sheetController.multiHandler = multiHandler
        return self
    }
    
    public func contentInsets(_ contentInsets: UIEdgeInsets) -> Self {
        sheetController.config.contentInsets = contentInsets
        return self
    }
    
    public func cornerRadius(_ cornerRadius: CGFloat) -> Self {
        
        sheetController.config.cornerRadius = cornerRadius
        
        return self
    }
    
    public func selectType(_ selectType: FunActionSheetConfig.SelectType) -> Self {
        
        sheetController.config.selectType = selectType
        
        return self
    }
    
    public func tintColor(_ tintColor: UIColor) -> Self {
        
        sheetController.config.tintColor = tintColor
        
        return self
    }
    
    public func selectImage(_ selectImage: UIImage) -> Self {
        
        sheetController.config.selectImage = selectImage
        
        return self
    }
    
    public func normalImage(_ normalImage: UIImage) -> Self {
        
        sheetController.config.normalImage = normalImage
        
        return self
    }
    
    public func present(sheetHandler a_sheetHandler: ((FunActionSheetController)->Void)?=nil) {
        
        if let handler = a_sheetHandler {
            handler(sheetController)
        }
        
        sheetController.actions = _actions

        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let presentedViewController = rootViewController?.presentedViewController {
            rootViewController = presentedViewController
        }
        let coverView = UIView.init(frame: UIScreen.main.bounds)
        coverView.backgroundColor = UIColor.init(white: 0, alpha: 0)
        
        rootViewController?.view.addSubview(coverView)
        UIView.animate(withDuration: 0.3) {
            coverView.backgroundColor = UIColor.init(white: 0, alpha: 0.35)
        }
        
        rootViewController?.present(sheetController, animated: true) {
            
            self.sheetController.view.backgroundColor = UIColor.init(white: 0, alpha: 0.35)
            coverView.removeFromSuperview()
        }
        
    }
}

private let FunActionSheetCellReuseID = "FunActionSheetCellReuseID"
private class FunActionSheetCell: UITableViewCell {
    var title: String? {
        didSet {
            if let text = title {
                textLabel?.text = text
                
            }
            
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        textLabel?.textColor = UIColor.darkText
        textLabel?.font = UIFont.systemFont(ofSize: 15)
        textLabel?.numberOfLines = 0

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}