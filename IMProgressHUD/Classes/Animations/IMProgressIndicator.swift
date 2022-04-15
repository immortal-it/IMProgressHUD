//
//  ProgressIndicator.swift
//  IMProgressHUD
//
//  Created by immortal on 2021/3/23.
//

import UIKit

/// A protocol for progress indicator that shows that a task is in progress HUD.
public protocol IMProgressIndicating: IMActivityIndicating {
    
    /// The indicator's progress value.
    var progress: CGFloat { get set }
}

class DefaultProgressIndicator: ActivityIndicatorLayer, IMProgressIndicating {
    
    private(set) lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11.0, weight: .bold)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let trackLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.lineCap = .round
        layer.lineJoin = .round
        layer.strokeStart = 0.0
        layer.strokeEnd = 1.0
        layer.contentsScale = UIScreen.main.scale
        return layer
    }()
    
    /// The track color.
    var trackColor: UIColor = #colorLiteral(red: 0.231372549, green: 0.231372549, blue: 0.231372549, alpha: 1) {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    override var color: UIColor {
        didSet {
            textLabel.textColor = color
        }
    }
    
    /// A Boolean value that determines whether the progress's text view is hidden.
    var isProgressTextHidden: Bool {
        get {
            textLabel.isHidden
        }
        set {
            textLabel.isHidden = newValue
        }
    }
    
        
    override func apply(in containerView: UIView) {
        super.apply(in: containerView)

        let containerSize = containerView.systemLayoutSizeFitting(UIScreen.main.bounds.size)
        let radius = min(containerSize.width, containerSize.height) * 0.5 - lineWidth * 0.5
        let path = UIBezierPath(
            arcCenter: CGPoint(x: containerSize.width * 0.5, y: containerSize.height * 0.5),
            radius: radius,
            startAngle: -0.5 * .pi,
            endAngle: 1.5 * .pi,
            clockwise: true
        )
        layer.path = path.cgPath
        
        trackLayer.frame = layer.frame
        trackLayer.lineWidth = layer.lineWidth
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.path = path.cgPath
        containerView.layer.insertSublayer(trackLayer, below: layer)

        containerView.addSubview(
            textLabel,
            constraints:
                textLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                textLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                textLabel.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor, multiplier: 1.0, constant: -lineWidth * 4.0)
        )
        
        textLabel.textColor = color
        updateProgressValue()
    }
    
    override func remove() {
        super.remove()
        trackLayer.removeFromSuperlayer()
        textLabel.removeFromSuperview()
    }
    
    
    
    // MARK: - IMProgressIndicating
    
    private func updateProgressValue() {
        textLabel.text = "\(Int(progress * 100))%"
        layer.strokeEnd = progress
    }
    
    var progress: CGFloat = .zero {
        didSet {
            updateProgressValue()
        }
    }
}

class HalfCircleProgressIndicator: HalfCircleActivityIndicator, IMProgressIndicating {

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11.0, weight: .bold)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override var color: UIColor {
        didSet {
            textLabel.textColor = color
        }
    }

    override func apply(in containerView: UIView) {
        super.apply(in: containerView)
        containerView.addSubview(
            textLabel,
            constraints:
                textLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                textLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                textLabel.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor, multiplier: 1.0, constant: -lineWidth * 4.0)
        )
        textLabel.textColor = color

        updateProgressValue()
    }

    override func remove() {
        super.remove()
        textLabel.removeFromSuperview()
    }
    
    
    
    // MARK: - IMProgressIndicating
    
    private func updateProgressValue() {
        textLabel.text = "\(Int(progress * 100))%"
    }
    
    var progress: CGFloat = .zero {
        didSet {
            updateProgressValue()
        }
    }
}
