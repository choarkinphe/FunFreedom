//
//  FunSheetController.swift
//  FunFreedom
//
//  Created by 肖华 on 2019/10/15.
//

import Foundation
public struct FunActionSheetConfig {
    public enum Position : Int {
        case `default`
        
        case center
        
    }
    public var contentInsets: UIEdgeInsets = .zero
    public var cornerRadius: CGFloat?
    public var position: FunActionSheetConfig.Position = .default
}


open class FunActionSheetController: UIViewController {
    open lazy var config = FunActionSheetConfig()
    
    open var handler: FunActionSheetHandler?
    
    convenience init(handler a_handler: FunActionSheetHandler?) {
        self.init(nibName: nil, bundle: nil)
        
        handler = a_handler
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        modalTransitionStyle = .coverVertical
        modalPresentationStyle = .overFullScreen
        view.backgroundColor = UIColor.init(white: 0, alpha: 0)
    }
    

    lazy var toolBar: FunActionSheetToolBar = {
        let _toolBar = FunActionSheetToolBar.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        
        _toolBar.doneHandler {
            
        }
        
        _toolBar.cancelHandler {
            self.dismiss(animated: true, completion: nil)
        }
        
        return _toolBar
    }()

    open func handler(_ a_handler: @escaping FunActionSheetHandler) {
        handler = a_handler
        
    }

    open var actions: [FunActionSheet]? {
        didSet {
            
            tableView.reloadData()
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
        let min_Height = contentW
        let actionHeight: CGFloat = CGFloat(49 * (actions?.count ?? 0))
        var contentH = min_Height

        if actionHeight > min_Height {
            contentH = actionHeight
        }
        
        if actionHeight > max_Height {
            contentH = max_Height
        }
        
        let contentY = view.bounds.size.height - contentH - config.contentInsets.bottom

        tableView.frame = CGRect.init(x: config.contentInsets.left, y: contentY, width: contentW, height: contentH)
        
        if config.position == .center {
            tableView.center = view.center
        }
        
        if let a_topView = topView {

            a_topView.frame = CGRect.init(x: config.contentInsets.left, y: tableView.frame.origin.y, width: contentW, height: a_topView.bounds.size.height)
            
        }
        
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
                
                if newValue == nil {
                    
                    topView.frame = .zero
                    topView.removeFromSuperview()
                }
            }
            
            if let a_topView = newValue {
                a_topView.frame = CGRect.init(x: config.contentInsets.left, y: config.contentInsets.top, width: tableView.frame.size.width, height: a_topView.bounds.size.height)
                tableView.contentInset = UIEdgeInsets.init(top: a_topView.bounds.size.height, left: 0, bottom: 0, right: 0)
                view.addSubview(a_topView)
                
            }
        }
        
    }
    
    open lazy var tableView: UITableView = {
        let _tableView = UITableView.init(frame: UIScreen.main.bounds, style: .plain)
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.rowHeight = UITableView.automaticDimension
        _tableView.estimatedRowHeight = 49
        _tableView.register(FunActionSheetCell.self, forCellReuseIdentifier: FunActionSheetCellReuseID)
        view.addSubview(_tableView)
        return _tableView
    }()
    
}

extension FunActionSheetController: UIGestureRecognizerDelegate {
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
}

extension FunActionSheetController :UITableViewDelegate,UITableViewDataSource {
    // MARK: - DataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FunActionSheetCell = tableView.dequeueReusableCell(withIdentifier: FunActionSheetCellReuseID) as! FunActionSheetCell
        if let action = actions?[indexPath.row] {
            
            cell.title = action.title
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let action = actions?[indexPath.row] {
            
            action.index = indexPath.row
            
            if let actionHandler = handler {
                
                actionHandler(action)
            }
            
        }
        
        dismiss(animated: true, completion: nil)
        
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



