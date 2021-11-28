//
//  IMHUDActivityIndicator.swift
//  IMProgressHUD
//
//  Created by immortal on 2021/3/17.
//

import UIKit

/// 活动指示器协议
public protocol IMActivityIndicating: AnyObject {
    
    /// 活动指示器内容显示在容器视图中
    func apply(in containerView: UIView)
    
    /// 移除活动指示器
    func remove()
}

public extension IMBaseActivityIndicator {
    /// 活动指示器类型枚举
    enum IndicatorType: String {
        /// 渐变圆环样式指示器
        case `default` = "IMGradientCircleActivityIndicator"
        /// 无样式
        case none = ""
        /// 系统菊花样式指示器
        case system = "IMSystemActivityIndicator"
        /// 圆环样式指示器
        case circle = "IMCircleActivityIndicator"
        /// 半圆环样式指示器
        case halfCircle = "IMHalfCircleActivityIndicator"
        /// 脉冲样式指示器
        case pulse = "IMPulseActivityIndicator"
        /// 不对称fade圆环样式指示器
        case asymmetricFadeCircle = "IMAsymmetricFadeCircleActivityIndicator"

        func getIndicator() -> IMActivityIndicating? {
            let className = NSStringFromClass(IMBaseActivityIndicator.self).replacingOccurrences(of: "IMBaseActivityIndicator", with: rawValue)
            guard let classType = NSClassFromString(className) as? IMBaseActivityIndicator.Type else {
                return nil
            }
            return classType.init()
        }
    }
}

/// 活动指示器基类
public class IMBaseActivityIndicator: IMActivityIndicating {
    
    public required init() { }

    /// 活动指示器内容显示在容器视图中
    public func apply(in containerView: UIView) { }
    
    /// 移除活动指示器
    public func remove() { }
}

/// 系统菊花样式指示器
public class IMSystemActivityIndicator: IMBaseActivityIndicator {
    
    /// 系统菊花颜色
    public var color: UIColor = .lightGray {
        didSet {
            activityIndicatorView.color = color
        }
    }
    
    /// 系统菊花活动指示器
    public private(set) lazy var activityIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            indicatorView.style = .large
        } else {
            indicatorView.style = .whiteLarge
        }
        indicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        indicatorView.hidesWhenStopped = true
        return indicatorView
    }()
    
    /// 活动指示器内容显示在容器视图中
    public override func apply(in containerView: UIView) {
        activityIndicatorView.color = color
        activityIndicatorView.frame = containerView.bounds
        activityIndicatorView.startAnimating()
        containerView.addSubview(activityIndicatorView)
    }
    
    /// 移除活动指示器
    public override func remove() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
    }
    
    deinit {
        remove()
    }
}

/// 图层样式指示器
public class IMActivityIndicatorLayer: IMBaseActivityIndicator {
   
    /// 动画时长，默认`1.5s`
    public var duration: TimeInterval = 1.5

    /// 绘制颜色，默认`UIColor.white`
    public var color: UIColor = .white
    
    /// 绘制线宽，默认`3.0`
    public var lineWidth: CGFloat = 3.0
    
    /// 绘制图层
    public private(set) lazy var layer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.lineCap = .round
        layer.lineJoin = .round
        layer.strokeStart = 0.0
        layer.strokeEnd = 1.0
        layer.contentsScale = UIScreen.main.scale
        return layer
    }()
    
    /// 活动指示器内容显示在容器视图中
    public override func apply(in containerView: UIView) {
        let containerSize = containerView.systemLayoutSizeFitting(UIScreen.main.bounds.size)
        layer.frame = CGRect(origin: .zero, size: containerSize)
        layer.strokeColor = color.cgColor
        layer.lineWidth = lineWidth
        loadAnimations()
        containerView.layer.addSublayer(layer)
    }
    
    /// 添加动画到layer上
    func loadAnimations() { }
    
    /// 移除活动指示器
    public override func remove() {
        layer.removeFromSuperlayer()
        layer.removeAllAnimations()
        layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
    }
}

/// 圆环样式指示器
public class IMCircleActivityIndicator: IMActivityIndicatorLayer {
    
    /// 活动指示器内容显示在容器视图中
    public override func apply(in containerView: UIView) {
        super.apply(in: containerView)
        let containerSize = containerView.systemLayoutSizeFitting(UIScreen.main.bounds.size)
        let path = UIBezierPath(arcCenter: CGPoint(x: containerSize.width * 0.5, y: containerSize.height * 0.5),
                                radius: (min(containerSize.height, containerSize.width) - lineWidth) * 0.5,
                                startAngle: -0.5 * .pi,
                                endAngle: 1.5 * .pi,
                                clockwise: true)
 
        layer.path = path.cgPath
    }
    
    /// 添加动画到layer上
    override func loadAnimations() {

        let animationRotation = CABasicAnimation(keyPath: "transform.rotation")
        animationRotation.byValue = 2.0 * Float.pi
        animationRotation.timingFunction = CAMediaTimingFunction(name: .linear)

        let animationStart = CABasicAnimation(keyPath: "strokeStart")
        animationStart.duration = duration * 1.2 / 1.7
        animationStart.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        animationStart.fromValue = 0.0
        animationStart.toValue = 1.0
        animationStart.beginTime = duration * 0.5 / 1.7

        let animationStop = CABasicAnimation(keyPath: "strokeEnd")
        animationStop.duration = duration * 0.7 / 1.7
        animationStop.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        animationStop.fromValue = 0.0
        animationStop.toValue = 1.0

        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [animationRotation, animationStop, animationStart]
        groupAnimation.duration = duration
        groupAnimation.repeatCount = .infinity
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards

        layer.add(groupAnimation, forKey: "animation")
    }
}

/// 半圆环样式指示器
public class IMHalfCircleActivityIndicator: IMCircleActivityIndicator {
    /// 私有常量数据
    private struct ViewMetrics {
        static let duration: TimeInterval = 1.0
        static let minStrokeValue: Double = 0.02
        static let maxStrokeValue: Double = 0.5
    }
    
    public required init() {
        super.init()
        duration = ViewMetrics.duration
    }
    
    /// 添加动画到layer上
    override func loadAnimations() {
        let strokeStartAnimation = CAKeyframeAnimation(keyPath: "strokeStart")
        strokeStartAnimation.values = [
            NSNumber(value: 0.0),
            NSNumber(value: 0.0),
            NSNumber(value: ViewMetrics.maxStrokeValue)
        ]
        strokeStartAnimation.duration = ViewMetrics.duration
        strokeStartAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        strokeStartAnimation.isRemovedOnCompletion = false
        strokeStartAnimation.fillMode = .forwards

        let strokeEndAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.values = [
            NSNumber(value: ViewMetrics.minStrokeValue),
            NSNumber(value: ViewMetrics.maxStrokeValue),
            NSNumber(value: ViewMetrics.maxStrokeValue + ViewMetrics.minStrokeValue)
        ]
        strokeEndAnimation.duration = duration
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        strokeEndAnimation.isRemovedOnCompletion = false
        strokeEndAnimation.fillMode = .forwards

        let rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotationAnimation.values = [NSNumber(value: 0.0), NSNumber(value: Double.pi * 1.0)]
        rotationAnimation.duration = duration
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.fillMode = .forwards

        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = duration
        groupAnimation.animations = [strokeStartAnimation, strokeEndAnimation, rotationAnimation]
        groupAnimation.repeatCount = .infinity
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards
        
        layer.add(groupAnimation, forKey: "animation")
    }
}

/// 渐变圆环样式指示器
public class IMGradientCircleActivityIndicator: IMHalfCircleActivityIndicator {
    
    /// 圆环颜色渐变位置，默认`0.7`
    public var colorLocation: CGFloat = 0.7
   
    /// 活动指示器内容显示在容器视图中
    public override func apply(in containerView: UIView) {
        super.apply(in: containerView)
        let containerSize = containerView.systemLayoutSizeFitting(UIScreen.main.bounds.size)
        
        let strokeStart = lineWidth * 0.5 / (min(containerSize.height, containerSize.width) + lineWidth)
        let leftGradientLayer: CAGradientLayer = {
            let layer = CAGradientLayer()
            layer.colors = [color, color.withAlphaComponent(colorLocation - strokeStart)].map({ $0.cgColor })
            layer.startPoint = CGPoint(x: 0.0, y: 0.0)
            layer.endPoint = CGPoint(x: 0.0, y: 1.0)
            layer.frame = CGRect(x: 0, y: 0, width: (containerSize.width + lineWidth) * 0.5, height: containerSize.height)
            return layer
        }()
        
        let rightGradientLayer: CAGradientLayer = {
            let layer = CAGradientLayer()
            layer.colors = [color.withAlphaComponent(0.0), color.withAlphaComponent(colorLocation)].map({ $0.cgColor })
            layer.startPoint = CGPoint(x: 0.0, y: 0.0)
            layer.endPoint = CGPoint(x: 0.0, y: 1.0)
            layer.frame = CGRect(x: (containerSize.width + lineWidth) * 0.5, y: 0.0, width: containerSize.width * 0.5, height: containerSize.height)
            return layer
        }()
        
        let maskLayer = CALayer()
        maskLayer.frame = layer.bounds
        maskLayer.addSublayer(rightGradientLayer)
        maskLayer.addSublayer(leftGradientLayer)
        layer.mask = maskLayer
        layer.strokeStart = strokeStart
    }
    
    override func loadAnimations() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.byValue = 2.0 * Float.pi
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        layer.add(animation, forKey: "transform.rotation")
    }
}

/// 脉冲样式指示器
public class IMPulseActivityIndicator: IMBaseActivityIndicator {
    
    /// 私有常量数据
    private struct ViewMetrics {
        static let count: Int = 3
    }
    
    /// 动画时长，默认`1.25s`
    public var duration: TimeInterval = 1.25

    /// 绘制颜色，默认`UIColor.white`
    public var color: UIColor = .white
    
    /// 点间距，默认`5.0`
    public var spacing: CGFloat = 5.0
    
    private var layers: [CAShapeLayer] = []
    
    /// 活动指示器内容显示在容器视图中
    public override func apply(in containerView: UIView) {
        let containerSize = containerView.systemLayoutSizeFitting(UIScreen.main.bounds.size)
        let radius = (containerSize.width - spacing * CGFloat(ViewMetrics.count - 1)) / CGFloat(ViewMetrics.count)
        let path = UIBezierPath(arcCenter: CGPoint(x: radius * 0.5, y: radius * 0.5),
                                radius: radius * 0.5,
                                startAngle: -0.5 * .pi,
                                endAngle: 1.5 * .pi,
                                clockwise: true)
 
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.keyTimes = [0.0, 0.5, 1.0]
        animation.timingFunctions = [CAMediaTimingFunction(controlPoints: 0.2, 0.68, 0.18, 1.08), CAMediaTimingFunction(controlPoints: 0.2, 0.68, 0.18, 1.08)]
        animation.values = [1.0, 0.45, 1.0]
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false

        let beginTime = CACurrentMediaTime()
        let beginTimes = [0.36, 0.24, 0.12]
        for index in 0..<ViewMetrics.count {
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: (radius + spacing) * CGFloat(index), y: (containerSize.height - radius) * 0.5, width: radius, height: radius)
            layer.path = path.cgPath
            layer.fillColor = color.cgColor
            animation.beginTime = beginTime - beginTimes[index]
            layer.add(animation, forKey: "animation")
            containerView.layer.addSublayer(layer)
            layers.append(layer)
        }
    }
    
    /// 移除活动指示器
    public override func remove() {
        layers.forEach({
            $0.removeFromSuperlayer()
        })
        layers.removeAll()
    }
}

/// 不对称fade圆环样式指示器
public class IMAsymmetricFadeCircleActivityIndicator: IMBaseActivityIndicator {
    
    /// 动画时长，默认`1.25s`
    public var duration: TimeInterval = 1.25

    /// 绘制颜色，默认`UIColor.white`
    public var color: UIColor = .white
    
    /// 点间距，默认`3.0`
    public var spacing: CGFloat = 3.0
    
    private var layers: [CAShapeLayer] = []
   
    /// 活动指示器内容显示在容器视图中
    public override func apply(in containerView: UIView) {
        super.apply(in: containerView)
        let containerSize = containerView.systemLayoutSizeFitting(UIScreen.main.bounds.size)

        let animation = CAAnimationGroup()
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        animation.animations = [{
            let animationScale = CAKeyframeAnimation(keyPath: "transform.scale")
            animationScale.keyTimes = [0, 0.5, 1]
            animationScale.values = [1, 0.4, 1]
            animationScale.duration = duration
            return animationScale
        }(), {
            let animationOpacity = CAKeyframeAnimation(keyPath: "opacity")
            animationOpacity.keyTimes = [0, 0.5, 1]
            animationOpacity.values = [1, 0.3, 1]
            animationOpacity.duration = duration
            return animationOpacity
        }()]

        let radius = (containerSize.width - 4 * spacing) / 3.5
        let path = UIBezierPath(arcCenter: CGPoint(x: radius * 0.5, y: radius * 0.5),
                                radius: radius * 0.5,
                                startAngle: 0, endAngle: 2 * .pi,
                                clockwise: false)
        let beginTime = CACurrentMediaTime()
        let beginTimes: [CFTimeInterval] = [0.84, 0.72, 0.6, 0.48, 0.36, 0.24, 0.12, 0]
        let radiusX = (containerSize.width - radius) * 0.5
        for index in 0..<8 {
            let angle = CGFloat.pi / 4 * CGFloat(index)
            let layer = CAShapeLayer()
            layer.path = path.cgPath
            layer.fillColor = color.cgColor
            layer.backgroundColor = nil
            layer.frame = CGRect(x: radiusX * (cos(angle) + 1), y: radiusX * (sin(angle) + 1), width: radius, height: radius)
            animation.beginTime = beginTime - beginTimes[index]
            layer.add(animation, forKey: "animation")
            containerView.layer.addSublayer(layer)
            layers.append(layer)
        }
    }
    
    /// 移除活动指示器
    public override func remove() {
        layers.forEach({
            $0.removeFromSuperlayer()
        })
        layers.removeAll()
    }
}
