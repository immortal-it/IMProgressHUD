//
//  IMProgressIndicator.swift
//  IMProgressHUD
//
//  Created by xys on 2021/3/23.
//

import UIKit

/// 进度指示器协议
public protocol IMProgressIndicating: IMActivityIndicating {
    
    var progress: CGFloat { get set }
}

public extension IMProgressIndicator {
    /// 进度指示器类型枚举
    enum IndicatorType: String {
        /// 渐变圆环样式指示器
        case `default` = "IMProgressIndicator"
        /// 半圆环样式指示器
        case halfCircle = "IMHalfCircleProgressIndicator"

        func getIndicator() -> IMActivityIndicating? {
            let className = NSStringFromClass(IMProgressIndicator.self).replacingOccurrences(of: "IMProgressIndicator", with: rawValue)
            guard let classType = NSClassFromString(className) as? IMBaseActivityIndicator.Type else {
                return nil
            }
            return classType.init()
        }
    }
}

public class IMProgressIndicator: IMActivityIndicatorLayer, IMProgressIndicating {
    
    public private(set) lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 11.0, weight: .bold)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    /// 踪迹图层
    private lazy var trackLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.lineCap = .round
        layer.lineJoin = .round
        layer.strokeStart = 0.0
        layer.strokeEnd = 1.0
        layer.contentsScale = UIScreen.main.scale
        return layer
    }()
        
    public override func apply(in containerView: UIView) {
        super.apply(in: containerView)

        let containerSize = containerView.systemLayoutSizeFitting(UIScreen.main.bounds.size)
        let radius = min(containerSize.width, containerSize.height) * 0.5 - lineWidth * 0.5
        let path = UIBezierPath(arcCenter: CGPoint(x: containerSize.width * 0.5, y: containerSize.height * 0.5),
                                radius: radius,
                                startAngle: -0.5 * .pi,
                                endAngle: 1.5 * .pi,
                                clockwise: true)
        layer.path = path.cgPath
        
        trackLayer.frame = layer.frame
        trackLayer.lineWidth = layer.lineWidth
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.path = path.cgPath
        containerView.layer.insertSublayer(trackLayer, below: layer)

        containerView.addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            textLabel.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor, multiplier: 1.0, constant: -lineWidth * 4.0)
        ])
        
        updateProgressValue()
    }
    
    public override func remove() {
        super.remove()
        trackLayer.removeFromSuperlayer()
        textLabel.removeFromSuperview()
    }
    
    
    /// 是否隐藏进度文本, 默认`false`
    public var isProgressTextHidden: Bool {
        get { textLabel.isHidden }
        set { textLabel.isHidden = newValue }
    }
    
    /// 踪迹颜色
    public var trackColor: UIColor = #colorLiteral(red: 0.231372549, green: 0.231372549, blue: 0.231372549, alpha: 1)
    
    // MARK: - IMProgressIndicating
    
    private func updateProgressValue() {
        textLabel.text = "\(Int(progress * 100))%"
        layer.strokeEnd = progress
    }
    
    public var progress: CGFloat = .zero {
        didSet {
            updateProgressValue()
        }
    }
}

public class IMHalfCircleProgressIndicator: IMHalfCircleActivityIndicator, IMProgressIndicating {

    public lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 11.0, weight: .bold)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    public override func apply(in containerView: UIView) {
        super.apply(in: containerView)
        containerView.addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            textLabel.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor, multiplier: 1.0, constant: -lineWidth * 4.0)
        ])
        updateProgressValue()
    }

    public override func remove() {
        super.remove()
        textLabel.removeFromSuperview()
    }
    
    // MARK: - IMProgressIndicating
    
    private func updateProgressValue() {
        textLabel.text = "\(Int(progress * 100))%"
    }
    
    public var progress: CGFloat = .zero {
        didSet {
            updateProgressValue()
        }
    }
}
