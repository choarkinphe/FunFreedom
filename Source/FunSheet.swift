//
//  FunSheet.swift
//  FunFreedom
//
//  Created by 肖华 on 2019/10/15.
//

import Foundation
public typealias FunActionSheetHandler = (FunFreedom.ActionSheet) -> Void
public typealias FunActionSheetMultiHandler = ([FunFreedom.ActionSheet]) -> Void
public extension FunFreedom {
    class ActionSheet: NSObject {
        
        public enum Style : Int {
            case `default`
            
            case cancel
            
            case destructive
        }
        
        open var value: String?
        
        open var title: String?
        
        open var isSelected: Bool = false
        
        open var style: ActionSheet.Style = .default
        
        open var index: Int = 0
        
        public init(title a_title: String?, value a_value: String? = nil, style a_style: ActionSheet.Style) {
            super.init()
            
            self.title = a_title
            self.value = a_value
            self.style = a_style
            
        }
        
    }
    
    class Sheet {
        
        public static var `default`: Sheet {
            
            let sheet = Sheet()
            return sheet
        }
        
        public lazy var sheetController = FunFreedom.Sheet.ActionController()
        private var _actions = [FunFreedom.ActionSheet]()
        
        public init() {
            sheetController.config.contentInsets = UIEdgeInsets.init(top: 170, left: 0, bottom: 0, right: 0)
            sheetController.config.cornerRadius = 8
        }
        
        
        public func addAction(title: String, value: String? = nil) -> Self {
            
            return addActions(FunFreedom.ActionSheet.init(title: title, value: value, style: .default))
        }
        
        public func addActions(titles: [String], values: [String]? = nil) -> Self {
            
            for (index,title) in titles.enumerated() {
                let action = FunFreedom.ActionSheet.init(title: title, style: .default)
                
                if let a_values = values {
                    if index < a_values.count {
                        action.value = a_values[index]
                    }
                }
                _actions.append(action)
            }
            
            return self
        }
        
        public func resultActions(_ actions: [FunFreedom.ActionSheet]?) -> Self {
            if let actions = actions {
                sheetController.resultActions = actions
            }
            
            return self
        }
        public func resultTitles(_ resultTitles: String?) -> Self {
            if let resultTitles = resultTitles {
                sheetController.resultTitles = resultTitles
            }
            
            return self
        }
        public func resultValues(_ resultValues: String?) -> Self {
            if let resultValues = resultValues {
                sheetController.resultValues = resultValues
            }
            
            return self
        }
        
        public func addActions(_ action: FunFreedom.ActionSheet) -> Self {
            _actions.append(action)
            
            return self
        }
        
        public func addActions(_ actions: [FunFreedom.ActionSheet]) -> Self {
            _actions.append(contentsOf: actions)
            
            return self
        }
        
        public func setHeaderTips(_ tips: String?) -> Self {
            
//            let header = FunFreedom.ActionSheetHeader.init(title: headerTitle, detail: headerDetail)
            sheetController.toolBar.tipLabel.text = tips
            
            return self
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
        
        public func selectType(_ selectType: FunFreedom.Sheet.ActionConfig.SelectType) -> Self {
            
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
        
        public func present(sheetHandler a_sheetHandler: ((FunFreedom.Sheet.ActionController)->Void)?=nil) {
            
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
}




public extension FunFreedom.Sheet {
    struct ActionConfig {
        public enum Position : Int {
            case `default`
            
            case center
            
        }
        
        public enum SelectType: Int {
            case single
            case multi
        }
        public var contentInsets: UIEdgeInsets = .zero
        public var cornerRadius: CGFloat?
        public var position: FunFreedom.Sheet.ActionConfig.Position = .default
        public var selectType: FunFreedom.Sheet.ActionConfig.SelectType = .single
        public var tintColor: UIColor?
        public var selectImage: UIImage?
        public var normalImage: UIImage?
    }
    
    class ActionController: UIViewController,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource {
        open lazy var config = FunFreedom.Sheet.ActionConfig()
        
        open var handler: FunActionSheetHandler? {
            didSet {
                toolBar.isMultiSelector = false
            }
        }
        open var multiHandler: FunActionSheetMultiHandler? {
            didSet {
                toolBar.isMultiSelector = true
            }
        }
        
        public lazy var resultActions = [FunFreedom.ActionSheet]()
        public var resultValues: String?
        public var resultTitles: String?

        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
            
            modalTransitionStyle = .coverVertical
            modalPresentationStyle = .overFullScreen
            view.backgroundColor = UIColor.init(white: 0, alpha: 0)
        }
        
        
        lazy var toolBar: FunFreedom.Sheet.ToolBar = {
            let _toolBar = FunFreedom.Sheet.ToolBar.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
            
            weak var weakSelf = self
            
            _toolBar.doneHandler {
                if let actions = weakSelf?.actions {
                    for action in actions {
                        if action.isSelected {
                            weakSelf?.resultActions.append(action)
                        }
                        
                    }
                    if let handler = weakSelf?.multiHandler, let result = weakSelf?.resultActions {
                        handler(result)
                    }
                }
                
                weakSelf?.dismiss(animated: true, completion: nil)
            }
            
            _toolBar.cancelHandler {
                weakSelf?.dismiss(animated: true, completion: nil)
            }
            
            return _toolBar
        }()
        
        open func handler(_ a_handler: @escaping FunActionSheetHandler) {
            handler = a_handler
            
        }
        
        open var actions: [FunFreedom.ActionSheet]? {
            didSet {
                
                guard let actions = actions else {return}
                var resultValues_array = self.resultValues?.components(separatedBy: ",") ?? [String]()
                var resultTitles_array = self.resultTitles?.components(separatedBy: ",") ?? [String]()
                
                if resultActions.count > 0 {

                    for result_action in resultActions {
                        if let title = result_action.title {
                            resultTitles_array.append(title)
                        }
                        if let value = result_action.value {
                            resultValues_array.append(value)
                        }
                    }
                    
                    resultActions.removeAll()
                }
                
                for action in actions {
                    if let value = action.value, resultValues_array.contains(value) {
                        action.isSelected = true
                    } else if let title = action.title, resultTitles_array.contains(title) {
                        action.isSelected = true
                    }
                }
                
                tableView.reloadData()
                view.setNeedsLayout()
            }
        }
        
        
        open override func viewDidLoad() {
            super.viewDidLoad()
            
            
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapDismissAction(_:)))
            tapGes.delegate = self
            view.addGestureRecognizer(tapGes)
            
            
            topView = toolBar
        }
        
        open override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            let contentW = view.bounds.size.width - config.contentInsets.left - config.contentInsets.right
            let max_Height = view.bounds.size.height - config.contentInsets.top - config.contentInsets.bottom
            //            let min_Height = contentW
            let actionHeight: CGFloat = CGFloat(49 * (actions?.count ?? 0))
            let contentH = max(contentW, min(max_Height, actionHeight))
            
            let contentY = view.bounds.size.height - contentH - config.contentInsets.bottom
            
            var rect_topView = CGRect.zero
            var rect_tableView = CGRect.init(x: config.contentInsets.left, y: contentY, width: contentW, height: contentH)
            
            if config.position == .center {
                rect_tableView = CGRect.init(x: (view.bounds.size.width - contentW) / 2.0, y: (view.bounds.size.height - contentH) / 2.0, width: contentW, height: contentH)
                //                tableView.center = view.center
            }
            
            
            
            if let a_topView = topView {
                rect_topView = CGRect.init(x: config.contentInsets.left, y: rect_tableView.origin.y, width: contentW, height: a_topView.bounds.size.height)
                if a_topView == toolBar {
                    a_topView.backgroundColor = .white
                    if !toolBar.isMultiSelector, toolBar.tipLabel.text == nil {
                        rect_topView = CGRect.init(x: config.contentInsets.left, y: rect_tableView.origin.y, width: contentW, height: 8)
                        a_topView.backgroundColor = .clear
                    }
                }
                
                tableView.contentInset = UIEdgeInsets.init(top: rect_topView.size.height, left: 0, bottom: 0, right: 0)
                
            }
            
            //            UIView.animate(withDuration: 0.25, animations: {
            self.tableView.frame = rect_tableView
            if let a_topView = self.topView {
                a_topView.frame = rect_topView
            }
            //            }) { (complete) in
            
            //            }
            
            if let a_cornerRadius = config.cornerRadius {
                tableView.layer.cornerRadius = a_cornerRadius
                tableView.layer.masksToBounds = true
                if let a_topView = topView {
                    a_topView.layer.cornerRadius = a_cornerRadius
                    a_topView.layer.masksToBounds = true
                }
            }
            
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
        
        open var topView: UIView? {
            willSet {
                if topView == newValue {
                    
                    return
                }
                

                if let topView = topView {

                    topView.frame = .zero
                    topView.removeFromSuperview()

                }
                
                if let a_topView = newValue {
                    a_topView.frame = CGRect.init(x: config.contentInsets.left, y: config.contentInsets.top, width: tableView.frame.size.width, height: a_topView.bounds.size.height)
                    
                    view.addSubview(a_topView)
                    
                    tableView.scrollsToTop = true
                }
            }
            
        }
        
        open lazy var tableView: UITableView = {
            let _tableView = UITableView.init(frame: UIScreen.main.bounds, style: .plain)
            _tableView.delegate = self
            _tableView.dataSource = self
            _tableView.rowHeight = UITableView.automaticDimension
            _tableView.estimatedRowHeight = 49
            _tableView.register(ActionCell.self, forCellReuseIdentifier: ActionCell.reuseID)
            view.addSubview(_tableView)
            return _tableView
        }()
        
        
        // MARK: TapAction
        public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            print(NSStringFromClass((touch.view?.classForCoder)!))  // touch.view  就是你想要的对象
            
            if NSStringFromClass((touch.view?.classForCoder)!) == "UITableViewCellContentView" {
                return false
            } else if touch.view == self.topView {
                return false
            } else {
                return true
            }
        }
        
        
        // MARK: - DataSource
        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            if let actions = actions {
                
                
                return actions.count
            }
            return 0
        }
        
        public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell: ActionCell = tableView.dequeueReusableCell(withIdentifier: ActionCell.reuseID) as! ActionCell
            if let action = actions?[indexPath.row] {
                action.index = indexPath.row
                cell.title = action.title
                
                if config.selectType == .multi {
                    cell.selectionStyle = .none
                }
                
                if let color = config.tintColor {
                    cell.selectedBackgroundView?.backgroundColor = color
                    cell.tintColor = color
                }
                
                cell.img_normal = config.normalImage
                cell.img_selected = config.selectImage
                cell.accessoryType = action.isSelected ? .checkmark : .none
                
            }
            return cell
        }
        
        public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            if config.selectType == .single {
                if let action = actions?[indexPath.row] {
                    
                    
                    
                    if let actionHandler = handler {
                        
                        actionHandler(action)
                    }
                    
                }
                
                dismiss(animated: true, completion: nil)
            } else if config.selectType == .multi {
                
                if let action = actions?[indexPath.row] {
                    
                    if action.isSelected {
                        action.isSelected = false
                    } else {
                        action.isSelected = true
                    }

                }
                
                tableView.reloadData()
            }
            
        }
        
//        private let FunActionSheetCellReuseID = "FunActionSheetCellReuseID"
//        private class FunActionSheetCell: UITableViewCell {
//            var title: String? {
//                didSet {
//                    if let text = title {
//                        textLabel?.text = text
//
//                    }
//
//                }
//            }
//
//            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//                super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
//
//                textLabel?.textColor = UIColor.darkText
//                textLabel?.font = UIFont.systemFont(ofSize: 15)
//                textLabel?.numberOfLines = 0
//
//            }
//
//            required init?(coder aDecoder: NSCoder) {
//                fatalError("init(coder:) has not been implemented")
//            }
//
//        }
        
        private class ActionCell: UITableViewCell {
            
            static let reuseID = "FunAction.ActionCell.ReuseID"
            var title: String? {
                didSet {
                    if let text = title {
                        textLabel?.text = text
                        
                    }
                    
                }
            }
            
            var img_selected: UIImage?
            var img_normal: UIImage?
            
            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
                selectedBackgroundView = UIView()
                selectedBackgroundView?.backgroundColor = .clear
                textLabel?.textColor = UIColor.darkText
                textLabel?.font = UIFont.systemFont(ofSize: 15)
                textLabel?.numberOfLines = 0
                
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func layoutSubviews() {
                super.layoutSubviews()
                
                selectedBackgroundView?.frame = frame
                
            }
            
        }
        
    }
    
    
    
}

extension FunFreedom.Sheet {
    class ToolBar: UIView {
        
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

