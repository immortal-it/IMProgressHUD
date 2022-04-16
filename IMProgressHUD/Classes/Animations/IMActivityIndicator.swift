//
//  IMHUDActivityIndicator.swift
//  IMProgressHUD
//
//  Created by immortal on 2021/3/17.
//

import UIKit

/// A protocol for activity indicator that shows that a task is in progress HUD.
public protocol IMActivityIndicating: AnyObject {
    
    /// Add this indicator attach to the container view.
    func apply(in containerView: UIView)
    
    /// Remove this indicator attached to the container view.
    func remove()
}

/// A base activity indicator that shows that a task is in progress HUD.
class BaseActivityIndicator: IMActivityIndicating {
    
    /// The indicator's color.
    var color: UIColor = .white
    
    /// The indicator's line width.
    var lineWidth: CGFloat = 3.0
    
    /// The indicator's animation duration.
    var duration: TimeInterval = 1.5
    
    required init() { }
    
    static func asIndicator(_ classString: String) -> BaseActivityIndicator? {
        let className = NSStringFromClass(BaseActivityIndicator.self)
            .replacingOccurrences(of: "BaseActivityIndicator", with: classString)
        guard let classType = NSClassFromString(className) as? BaseActivityIndicator.Type else {
            return nil
        }
        return classType.init()
    }

    
    
    // MARK: - IMActivityIndicating
    
    public func apply(in containerView: UIView) { }
    
    public func remove() { }
    
    deinit {
        remove()
    }
}

/// A system activity indicator that shows that a task is in progress HUD.
class SystemActivityIndicator: BaseActivityIndicator {
    
    /// A system activity indicator that shows that a task is in progress.
    private let activityIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            indicatorView.style = .large
        } else {
            indicatorView.style = .whiteLarge
        }
        indicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        indicatorView.hidesWhenStopped = false
        return indicatorView
    }()
    
    override var color: UIColor {
        didSet {
            activityIndicatorView.color = color
        }
    }
    
    override func apply(in containerView: UIView) {
        activityIndicatorView.color = color
        activityIndicatorView.frame = containerView.bounds
        activityIndicatorView.startAnimating()
        containerView.addSubview(activityIndicatorView)
    }
    
    override func remove() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
    }
}

/// A activity indicator layer.
class ActivityIndicatorLayer: BaseActivityIndicator {
  
    /// The indicator’s Core Animation layer used for rendering.
    let layer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.lineCap = .round
        layer.lineJoin = .round
        layer.strokeStart = 0.0
        layer.strokeEnd = 1.0
        layer.contentsScale = UIScreen.main.scale
        return layer
    }()
    
    override var lineWidth: CGFloat {
        didSet {
            layer.lineWidth = lineWidth
        }
    }
    
    override var color: UIColor {
        didSet {
            layer.strokeColor = color.cgColor
        }
    }
    
    override func apply(in containerView: UIView) {
        let containerSize = containerView.systemLayoutSizeFitting(UIScreen.main.bounds.size)
        layer.frame = CGRect(origin: .zero, size: containerSize)
        layer.strokeColor = color.cgColor
        layer.lineWidth = lineWidth
        loadAnimations()
        containerView.layer.addSublayer(layer)
    }

    override func remove() {
        layer.removeFromSuperlayer()
        layer.removeAllAnimations()
        layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
    }
    
    /// Add the specified animation objects to the layer’s render tree.
     func loadAnimations() { }
}



// MARK: - Circle

/// A circle style activity indicator that shows that a task is in progress HUD.
class CircleActivityIndicator: ActivityIndicatorLayer {

    override func apply(in containerView: UIView) {
        super.apply(in: containerView)
        let containerSize = containerView.systemLayoutSizeFitting(UIScreen.main.bounds.size)
        let path = UIBezierPath(
            arcCenter: CGPoint(x: containerSize.width * 0.5, y: containerSize.height * 0.5),
            radius: (min(containerSize.height, containerSize.width) - lineWidth) * 0.5,
            startAngle: -0.5 * .pi,
            endAngle: 1.5 * .pi,
            clockwise: true
        )
        layer.path = path.cgPath
    }

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

/// A imperfect circle style activity indicator that shows that a task is in progress HUD.
class ImperfectCircleActivityIndicator: ActivityIndicatorLayer {

    required init() {
        super.init()
        duration = 1.0
    }
    
    override func apply(in containerView: UIView) {
        super.apply(in: containerView)
        let containerSize = containerView.systemLayoutSizeFitting(UIScreen.main.bounds.size)
        let path = UIBezierPath(
            arcCenter: CGPoint(x: containerSize.width * 0.5, y: containerSize.height * 0.5),
            radius: (min(containerSize.height, containerSize.width) - lineWidth) * 0.5,
            startAngle: -0.5 * .pi,
            endAngle: 1.5 * .pi,
            clockwise: true
        )
        layer.path = path.cgPath
        
        layer.strokeStart = 0
        layer.strokeEnd = 0.82
    }

    override func loadAnimations() {
        let animationRotation = CABasicAnimation(keyPath: "transform.rotation")
        animationRotation.byValue = 2.0 * Float.pi
        animationRotation.timingFunction = CAMediaTimingFunction(name: .linear)

        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [animationRotation]
        groupAnimation.duration = duration
        groupAnimation.repeatCount = .infinity
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards

        layer.add(groupAnimation, forKey: "animation")
    }
}

/// A half circle style activity indicator that shows that a task is in progress HUD.
class HalfCircleActivityIndicator: CircleActivityIndicator {
    
    private struct ViewMetrics {
        static let minStrokeValue: Double = 0.02
        static let maxStrokeValue: Double = 0.5
    }
    
    required init() {
        super.init()
        duration = 1.0
    }
    
    override func loadAnimations() {
        let strokeStartAnimation = CAKeyframeAnimation(keyPath: "strokeStart")
        strokeStartAnimation.values = [
            NSNumber(value: 0.0),
            NSNumber(value: 0.0),
            NSNumber(value: ViewMetrics.maxStrokeValue)
        ]
        strokeStartAnimation.duration = duration
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

/// A gradient circle style activity indicator that shows that a task is in progress HUD.
class GradientCircleActivityIndicator: HalfCircleActivityIndicator {
    
    /// The gradient's color  location.
    var colorLocation: CGFloat = 0.7
    
    let leftGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.0, y: 0.0)
        layer.endPoint = CGPoint(x: 0.0, y: 1.0)
        return layer
    }()
    
    let rightGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.0, y: 0.0)
        layer.endPoint = CGPoint(x: 0.0, y: 1.0)
        return layer
    }()
    
    let maskLayer = CALayer()

    required init() {
        super.init()
        maskLayer.addSublayer(rightGradientLayer)
        maskLayer.addSublayer(leftGradientLayer)
        layer.mask = maskLayer
    }
   
    override func apply(in containerView: UIView) {
        super.apply(in: containerView)
        let containerSize = containerView.systemLayoutSizeFitting(UIScreen.main.bounds.size)
        
        let strokeStart = lineWidth * 0.5 / (min(containerSize.height, containerSize.width) + lineWidth)
        leftGradientLayer.colors = [color, color.withAlphaComponent(colorLocation - strokeStart)]
                                   .map({ $0.cgColor })
        leftGradientLayer.frame = CGRect(
            x: 0, y: 0,
            width: (containerSize.width + lineWidth) * 0.5,
            height: containerSize.height
        )
        rightGradientLayer.colors = [color.withAlphaComponent(0.0), color.withAlphaComponent(colorLocation)]
                                    .map({ $0.cgColor })
        rightGradientLayer.frame = CGRect(
            x: (containerSize.width + lineWidth) * 0.5,
            y: 0.0,
            width: containerSize.width * 0.5,
            height: containerSize.height
        )
        maskLayer.frame = layer.bounds
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

/// An asymmetric fade style activity indicator that shows that a task is in progress HUD.
class AsymmetricFadeCircleActivityIndicator: PulseActivityIndicator {
     
    required init() {
        super.init()
        spacing = 3.0
    }
   
    override func apply(in containerView: UIView) {
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
        let path = UIBezierPath(
            arcCenter: CGPoint(x: radius * 0.5, y: radius * 0.5),
            radius: radius * 0.5,
            startAngle: 0, endAngle: 2 * .pi,
            clockwise: false
        )
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
}



// MARK: - Other

/// A pulse style activity indicator that shows that a task is in progress HUD.
class PulseActivityIndicator: BaseActivityIndicator {
    
    private struct ViewMetrics {
        
        static var count: Int {
            3
        }
    }
        
    /// The point spacing
    var spacing: CGFloat = 6.0
    
    var layers: [CAShapeLayer] = []
    
    required init() {
        super.init()
        duration = 1.25
    }
    
    override var color: UIColor {
        didSet {
            layers.forEach({
                $0.fillColor = color.cgColor
            })
        }
    }
    
    override func apply(in containerView: UIView) {
        let containerSize = containerView.systemLayoutSizeFitting(UIScreen.main.bounds.size)
        let radius = (containerSize.width - spacing * CGFloat(ViewMetrics.count - 1)) / CGFloat(ViewMetrics.count)
        let path = UIBezierPath(
            arcCenter: CGPoint(x: radius * 0.5, y: radius * 0.5),
            radius: radius * 0.5,
            startAngle: -0.5 * .pi,
            endAngle: 1.5 * .pi,
            clockwise: true
        )
 
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.keyTimes = [0.0, 0.5, 1.0]
        animation.timingFunctions = [
            CAMediaTimingFunction(controlPoints: 0.2, 0.68, 0.18, 1.08),
            CAMediaTimingFunction(controlPoints: 0.2, 0.68, 0.18, 1.08)
        ]
        animation.values = [1.0, 0.45, 1.0]
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false

        let beginTime = CACurrentMediaTime()
        let beginTimes = [0.36, 0.24, 0.12]
        for index in 0..<ViewMetrics.count {
            let layer = CAShapeLayer()
            layer.frame = CGRect(
                x: (radius + spacing) * CGFloat(index),
                y: (containerSize.height - radius) * 0.5,
                width: radius,
                height: radius
            )
            layer.path = path.cgPath
            layer.fillColor = color.cgColor
            animation.beginTime = beginTime - beginTimes[index]
            layer.add(animation, forKey: "animation")
            containerView.layer.addSublayer(layer)
            layers.append(layer)
        }
    }
    
    override func remove() {
        layers.forEach({
            $0.removeFromSuperlayer()
        })
        layers.removeAll()
    }
}
