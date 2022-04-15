//
//  StateIndicator.swift
//  IMProgressHUD
//
//  Created by immortal on 2021/3/18.
//

import UIKit

class StateIndicator: CircleActivityIndicator {
    
    private struct ViewMetrics {
        static let duration: TimeInterval = 0.35
        static let failPercentage: CGFloat = 0.8
    }
    
    typealias State = IMProgressHUD.State
    
    let state: State
  
    init(state: State) {
        self.state = state
        super.init()
        duration = ViewMetrics.duration
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func apply(in containerView: UIView) {
        let containerSize = containerView.systemLayoutSizeFitting(UIScreen.main.bounds.size)
        let path = UIBezierPath()
        switch state {
            case .success:
                path.move(to: CGPoint(x: lineWidth * 0.5, y: containerSize.height * 0.55))
                path.addLine(to: CGPoint(x: containerSize.width * 0.39, y: containerSize.height * 0.9 - lineWidth * 0.5))
                path.addLine(to: CGPoint(x: containerSize.width - lineWidth * 0.5, y: containerSize.height * 0.1 + lineWidth * 0.5))
            
            case .fail:
                path.move(to: CGPoint(x: containerSize.width * (1.0 - ViewMetrics.failPercentage) + lineWidth * 0.5, y: containerSize.height * 0.2 + lineWidth * 0.5))
                path.addLine(to: CGPoint(x: containerSize.width * ViewMetrics.failPercentage - lineWidth * 0.5, y: containerSize.height * ViewMetrics.failPercentage - lineWidth * 0.5))
                path.move(to: CGPoint(x: containerSize.width * (1.0 - ViewMetrics.failPercentage) + lineWidth * 0.5, y: containerSize.height * ViewMetrics.failPercentage - lineWidth * 0.5))
                path.addLine(to: CGPoint(x: containerSize.width * ViewMetrics.failPercentage - lineWidth * 0.5, y: containerSize.height * (1.0 - ViewMetrics.failPercentage) + lineWidth * 0.5))
        }
        layer.frame = CGRect(origin: .zero, size: containerSize)
        layer.strokeColor = color.cgColor
        layer.lineWidth = lineWidth
        loadAnimations()
        layer.path = path.cgPath
        containerView.layer.addSublayer(layer)
    }
    
    override func loadAnimations() {
        switch state {
            case .success:
                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.duration = duration
                animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                animation.fromValue = 0.0
                animation.toValue = 1.0
                animation.isRemovedOnCompletion = false
                animation.fillMode = .forwards
                layer.strokeEnd = 0.0
                layer.add(animation, forKey: "animation")
            
            case .fail:
                let animation = CABasicAnimation(keyPath: "opacity")
                animation.duration = duration
                animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                animation.fromValue = 0.0
                animation.toValue = 1.0
                animation.isRemovedOnCompletion = false
                animation.fillMode = .forwards
                layer.opacity = 0.0
                layer.add(animation, forKey: "animation")
        }
    }
}
