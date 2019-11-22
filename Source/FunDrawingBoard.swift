//
//  FunDrawingBoard.swift
//  Alamofire
//
//  Created by choarkinphe on 2019/11/22.
//

import Foundation


public class FunDrawingBoard {

    private var draw_config: DrawConfig?
    private var mask_name = mask_layer_name
    private var border_name = border_layer_name
    private var target: UIView?

    public static var `default`: FunDrawingBoard {
        let drawingBoard = FunDrawingBoard()
        drawingBoard.draw_config = DrawConfig()
        return drawingBoard
    }
    
    public func target(_ a_target: UIView?) -> Self {
        target = a_target
        return self
    }
    
    public func identifier(_ identifier: String) -> Self {
        draw_config?.identifier = identifier
        
        mask_name = mask_name + identifier
        border_name = border_name + identifier
        
        return self
    }
    
    public func style(_ style: DrawType) -> Self {
        draw_config?.style = style
        
        return self
    }
    
    public func lineLength(_ lineLength: CGFloat) -> Self {
        draw_config?.lineLength = lineLength
        
        return self
    }
    
    public func lineSpacing(_ lineSpacing: CGFloat) -> Self {
        draw_config?.lineSpacing = lineSpacing
        
        return self
    }
    
    public func animation(_ animation: Bool) -> Self {
        draw_config?.animation = animation
        
        if animation {
            draw_config?.animation_config = AnimationConfig()
        }
        
        return self
    }
    
    public func animation_config(_ animation_config: AnimationConfig) -> Self {
        draw_config?.animation_config = animation_config
        
        return self
    }
    
    public func positaion(_ positaion: LinePosition) -> Self {
        draw_config?.positaion = positaion
        
        return self
    }
    
    public func borderWidth(_ borderWidth: CGFloat) -> Self {
        draw_config?.borderWidth = borderWidth
        
        return self
    }
    
    public func borderColor(_ borderColor: UIColor) -> Self {
        draw_config?.borderColor = borderColor
        
        return self
    }
    
    public func cornerRadius(_ cornerRadius: CGFloat) -> Self {
        draw_config?.cornerRadius = cornerRadius
        
        return self
    }
    
    public func rectCornerType(_ rectCornerType: UIRectCorner) -> Self {
        draw_config?.rectCornerType = rectCornerType
        
        return self
    }
    
    public func rect(_ rect: CGRect) -> Self {
        draw_config?.rect = rect
        
        return self
    }
    
    public func clearLayer(identifier: String? = nil) {
        
        if let view = target {
            
            var layer_mask: CALayer?
            var layer_border: CALayer?
            
            if let a_identifier = identifier {
                mask_name = mask_name + a_identifier
                border_name = border_name + a_identifier
            }
            
            if view.layer.sublayers != nil {
                for (_, item_layer) in view.layer.sublayers!.enumerated() {
                    
                    if item_layer.name == mask_name {
                        layer_mask = item_layer
                    }
                    
                    if item_layer.name == border_name {
                        layer_border = item_layer
                    }
                }
                
                if (layer_mask != nil) {
                    layer_mask?.removeFromSuperlayer()
                }
                
                if (layer_border != nil) {
                    layer_border?.removeFromSuperlayer()
                }
            }
        }
        
    }
    
    public func draw() {
        
        if let view = target {
            
            clearLayer(identifier: nil)
            
            view.layer.rasterizationScale = UIScreen.main.scale
            
            if let config = draw_config {
                if let style = config.style {
                    switch style {
                    case .corner:
                        draw_corner(view: view,config: config)
                    case .line:
                        draw_line(view: view,config: config)
                    }
                }
            }
        }
    }
    
    private func draw_line(view: UIView, config: DrawConfig) {
        let rect = draw_config?.rect ?? view.bounds
        let lineWith = config.borderWidth ?? 0
        
        let borderLayer = CAShapeLayer()
        borderLayer.frame = rect
        borderLayer.name = border_name
        borderLayer.fillColor = UIColor.clear.cgColor
        if let borderColor = config.borderColor {
            borderLayer.strokeColor = borderColor.cgColor
        }
        
        borderLayer.lineWidth = lineWith
        borderLayer.lineJoin = CAShapeLayerLineJoin.round
        
        //每一段虚线长度 和 每两段虚线之间的间隔
        borderLayer.lineDashPattern = [NSNumber.init(value: Double(config.lineLength)), NSNumber.init(value: Double(config.lineSpacing))]
        
        let path = CGMutablePath()
        
        var x_start: CGFloat = 0.0
        var y_start: CGFloat = 0.0
        
        var x_end: CGFloat = 0.0
        var y_end: CGFloat = 0.0
        
        switch config.positaion {
        case .top:
            x_start = 0.0
            y_start = 0.0
            x_end = rect.size.width
            y_end = 0.0
        case .left:
            x_start = 0.0
            y_start = 0.0
            x_end = rect.size.width
            y_end = rect.size.height
        case .bottom:
            x_start = 0.0
            y_start = rect.size.height - lineWith
            x_end = rect.size.width
            y_end = rect.size.height - lineWith
        case .right:
            x_start = rect.size.width - lineWith
            y_start = 0.0
            x_end = rect.size.width - lineWith
            y_end = rect.size.height
            
        }
        
        path.move(to: CGPoint(x: x_start, y: y_start))
        path.addLine(to: CGPoint(x: x_end, y: y_end))
        borderLayer.path = path
        
        if config.animation {
            add_animation(shapeLayer: borderLayer, config: config.animation_config)
        }
        
        view.layer.insertSublayer(borderLayer, at: 0)
    }
    
    private func draw_corner(view: UIView, config: DrawConfig) {
        let rect = config.rect ?? view.bounds
        let cornerRadius = config.cornerRadius ?? 0
        let rectCornerType = config.rectCornerType ?? .allCorners
        
        let maskLayer = CAShapeLayer()
        
        maskLayer.frame = rect
        maskLayer.name = mask_name
        
        let borderLayer = CAShapeLayer()
        borderLayer.frame = rect
        borderLayer.name = border_name
        
        if let borderColor = config.borderColor {
            borderLayer.strokeColor = borderColor.cgColor
        }
        
        borderLayer.lineWidth = config.borderWidth ?? 0
        
        borderLayer.fillColor = UIColor.clear.cgColor
        
        let bezierPath = UIBezierPath.init(roundedRect: rect, byRoundingCorners: rectCornerType, cornerRadii: CGSize.init(width: cornerRadius, height: cornerRadius))
        
        maskLayer.path = bezierPath.cgPath
        borderLayer.path = bezierPath.cgPath
        
        view.layer.insertSublayer(borderLayer, at: 0)
        view.layer.mask = maskLayer
    }
    
    private func add_animation(shapeLayer: CAShapeLayer, config: AnimationConfig?) {
        if let a_config = config {
            let baseAnimation = CABasicAnimation(keyPath: a_config.name)
            baseAnimation.duration = a_config.duration   //持续时间
            baseAnimation.fromValue = a_config.fromValue  //开始值
            baseAnimation.toValue = a_config.toValue    //结束值
            baseAnimation.repeatDuration = a_config.repeatDuration  //重复次数
        }
        
    }
    
    deinit {
        print("die")
    }
}

public extension UIView {
    
    var funDrawingBoard: FunDrawingBoard {
        
        return FunDrawingBoard.default.target(self)
    }
}

private let mask_layer_name = "fun.border.maskLayer"
private let border_layer_name = "fun.border.maskLayer"

public extension FunDrawingBoard {
    
    enum DrawType: String {
        case corner = "corner"
        case line = "line"
    }
    
    enum LinePosition: String {
        case top
        case left
        case bottom
        case right
    }
    
    struct DrawConfig {
        
        public var borderWidth: CGFloat?
        
        public var borderColor: UIColor?
        
        public var cornerRadius: CGFloat?
        
        public var rectCornerType: UIRectCorner?
        
        public var rect: CGRect?
        
        public var style: DrawType?
        
        public var lineLength: CGFloat = 10.0
        
        public var lineSpacing: CGFloat = 5.0
        
        public var positaion: LinePosition = .bottom
        
        public var animation: Bool = false
        
        public var animation_config: AnimationConfig?
        
        public var identifier: String?
    }

    struct AnimationConfig {
        public var duration: Double = 0.5
        public var fromValue: Double = 0.0
        public var toValue: Double = 0.5
        public var repeatDuration: Double = 1.0
        public var name: String = "strokeEnd"
        
        public static func building(duration: Double? = nil, fromValue: Double? = nil, toValue: Double? = nil, repeatDuration: Double? = nil, name: String? = nil) -> AnimationConfig {
            var config = AnimationConfig()
            
            if let a_duration = duration {
                config.duration = a_duration
            }
            
            if let a_fromValue = fromValue {
                config.fromValue = a_fromValue
            }
            
            if let a_toValue = toValue {
                config.toValue = a_toValue
            }
            
            if let a_repeatDuration = repeatDuration {
                config.repeatDuration = a_repeatDuration
            }
            
            if let a_name = name {
                config.name = a_name
            }
            
            return config
        }
    }
}
