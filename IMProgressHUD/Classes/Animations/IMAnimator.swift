//
//  IMAnimator.swift
//  IMProgressHUD
//
//  Created by immortal on 2022/4/14
//
        
import UIKit

/// A protocol for progress HUD's transition.
public protocol IMAnimatorTransitioning {
        
    /// Presenting a progress HUD.
    func isAppearing(hud: IMProgressHUD) -> Bool

    /// Hiding a progress HUD.
    func isDisappearing(hud: IMProgressHUD) -> Bool

    /// Presents a progress HUD.
    func show(hud: IMProgressHUD)
    
    /// Hides a progress HUD.
    func hide(hud: IMProgressHUD)
    
    /// Cancel the animation.
    func cancel(hud: IMProgressHUD)
}

public extension IMAnimatorTransitioning {
    
    func isAppearing(hud: IMProgressHUD) -> Bool {
        hud.layer.animation(forKey: ViewMetrics.showAnimationKey) != nil
    }

    func isDisappearing(hud: IMProgressHUD) -> Bool {
        hud.layer.animation(forKey: ViewMetrics.hideAnimationKey) != nil
    }
}


private struct ViewMetrics {

    static var showAnimationKey: String { "com.immortal.IMProgressHUD.Animator.show" }

    static var hideAnimationKey: String { "com.immortal.IMProgressHUD.Animator.hide" }

    static var duration: TimeInterval { 0.15 }
}



class FadeAnimator: IMAnimatorTransitioning {

    func show(hud: IMProgressHUD) {
        guard !isAppearing(hud: hud) else {
            return
        }
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = ViewMetrics.duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.isRemovedOnCompletion = true
        hud.layer.add(animation, forKey: ViewMetrics.showAnimationKey)
    }

    func hide(hud: IMProgressHUD) {
        guard !isDisappearing(hud: hud) else {
            return
        }
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = ViewMetrics.duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.completion = { [weak hud] _ in
            guard let hud = hud else {
                return
            }
            hud.removeFromSuperview()
            hud.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        }
        hud.layer.add(animation, forKey: ViewMetrics.hideAnimationKey)
    }

    func cancel(hud: IMProgressHUD) {
        hud.layer.removeAnimation(forKey: ViewMetrics.showAnimationKey)
        if let animation = hud.layer.animation(forKey: ViewMetrics.hideAnimationKey) {
            animation.completion = nil
            hud.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        }
        hud.layer.opacity = 1.0
    }
}

class ZoomAnimator: IMAnimatorTransitioning {
    
    func show(hud: IMProgressHUD) {
        guard !isAppearing(hud: hud) else {
            return
        }
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.0
        opacityAnimation.toValue = 1.0
        opacityAnimation.duration = ViewMetrics.duration
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        opacityAnimation.isRemovedOnCompletion = true

        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [0.6, 1.0]
        scaleAnimation.duration = ViewMetrics.duration
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        scaleAnimation.isRemovedOnCompletion = true

        hud.layer.add(opacityAnimation, forKey: ViewMetrics.showAnimationKey)
        hud.containerView.layer.add(scaleAnimation, forKey: ViewMetrics.showAnimationKey)
    }

    func hide(hud: IMProgressHUD) {
        guard !isDisappearing(hud: hud) else {
            return
        }
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        opacityAnimation.duration = ViewMetrics.duration
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        opacityAnimation.isRemovedOnCompletion = false
        opacityAnimation.fillMode = .forwards
        opacityAnimation.completion = { [weak hud] _ in
            guard let hud = hud else {
                return
            }
            hud.removeFromSuperview()
            hud.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
            hud.containerView.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        }
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 0.6]
        scaleAnimation.duration = ViewMetrics.duration
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        scaleAnimation.isRemovedOnCompletion = false
        scaleAnimation.fillMode = .forwards
         
        hud.containerView.layer.add(scaleAnimation, forKey: ViewMetrics.hideAnimationKey)
        hud.layer.add(opacityAnimation, forKey: ViewMetrics.hideAnimationKey)
    }
    
    func cancel(hud: IMProgressHUD) {
        hud.layer.removeAnimation(forKey: ViewMetrics.showAnimationKey)
        if let animation = hud.layer.animation(forKey: ViewMetrics.hideAnimationKey) {
            animation.completion = nil
            hud.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        }
        hud.layer.opacity = 1.0
        
        hud.containerView.layer.removeAnimation(forKey: ViewMetrics.showAnimationKey)
        hud.containerView.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        hud.containerView.layer.setAffineTransform(.identity)
    }
}

class TranslationZoomAnimator: IMAnimatorTransitioning {
    
    let translation: CGPoint
    
    init(translation: CGPoint) {
        self.translation = translation
    }
     
    func show(hud: IMProgressHUD) {
        guard !isAppearing(hud: hud) else {
            return
        }
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.0
        opacityAnimation.toValue = 1.0
        opacityAnimation.duration = ViewMetrics.duration
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        opacityAnimation.isRemovedOnCompletion = true

        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [0.6, 1.0]
        scaleAnimation.duration = ViewMetrics.duration
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        scaleAnimation.isRemovedOnCompletion = true
        
        let translationAnimation = CAKeyframeAnimation(keyPath: "transform.translation")
        translationAnimation.values = [translation, CGPoint.zero]
        translationAnimation.duration = ViewMetrics.duration
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = true
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = ViewMetrics.duration
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animationGroup.isRemovedOnCompletion = true
        animationGroup.animations = [scaleAnimation, translationAnimation]

        hud.layer.add(opacityAnimation, forKey: ViewMetrics.showAnimationKey)
        hud.containerView.layer.add(animationGroup, forKey: ViewMetrics.showAnimationKey)
    }

    func hide(hud: IMProgressHUD) {
        guard !isDisappearing(hud: hud) else {
            return
        }
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        opacityAnimation.duration = ViewMetrics.duration
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        opacityAnimation.isRemovedOnCompletion = false
        opacityAnimation.fillMode = .forwards
        opacityAnimation.completion = { [weak hud] _ in
            guard let hud = hud else {
                return
            }
            hud.removeFromSuperview()
            hud.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
            hud.containerView.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        }
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 0.6]
        scaleAnimation.duration = ViewMetrics.duration
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        scaleAnimation.isRemovedOnCompletion = false
        scaleAnimation.fillMode = .forwards
        
        let translationAnimation = CAKeyframeAnimation(keyPath: "transform.translation")
        translationAnimation.values = [CGPoint.zero, translation]
        translationAnimation.duration = ViewMetrics.duration
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = true
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = ViewMetrics.duration
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animationGroup.isRemovedOnCompletion = true
        animationGroup.animations = [scaleAnimation, translationAnimation]

        hud.containerView.layer.add(animationGroup, forKey: ViewMetrics.hideAnimationKey)
        hud.layer.add(opacityAnimation, forKey: ViewMetrics.hideAnimationKey)
    }
    
    func cancel(hud: IMProgressHUD) {
        hud.layer.removeAnimation(forKey: ViewMetrics.showAnimationKey)
        if let animation = hud.layer.animation(forKey: ViewMetrics.hideAnimationKey) {
            animation.completion = nil
            hud.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        }
        hud.layer.opacity = 1.0
        
        hud.containerView.layer.removeAnimation(forKey: ViewMetrics.showAnimationKey)
        hud.containerView.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        hud.containerView.layer.setAffineTransform(.identity)
    }
}

class PopoverAnimator: IMAnimatorTransitioning {
    
    func show(hud: IMProgressHUD) {
        guard !isAppearing(hud: hud) else {
            return
        }
        hud.layoutIfNeeded()

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.0
        opacityAnimation.toValue = 1.0
        opacityAnimation.duration = ViewMetrics.duration
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        opacityAnimation.isRemovedOnCompletion = true
        
        let translationAnimation = CAKeyframeAnimation(keyPath: "transform.translation")
        translationAnimation.duration = ViewMetrics.duration
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = true
        switch hud.location {
            case .top:
                translationAnimation.values = [CGPoint(x: 0, y: -hud.containerView.frame.maxY), CGPoint.zero]
            case .bottom:
                translationAnimation.values = [CGPoint(x: 0, y: hud.frame.height - hud.containerView.frame.minY), CGPoint.zero]
            case .center:
                break
        }
        
        hud.layer.add(opacityAnimation, forKey: ViewMetrics.showAnimationKey)
        hud.containerView.layer.add(translationAnimation, forKey: ViewMetrics.showAnimationKey)
    }

    func hide(hud: IMProgressHUD) {
        guard !isDisappearing(hud: hud) else {
            return
        }
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        opacityAnimation.duration = ViewMetrics.duration
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        opacityAnimation.isRemovedOnCompletion = false
        opacityAnimation.fillMode = .forwards
        opacityAnimation.completion = { [weak hud] _ in
            guard let hud = hud else {
                return
            }
            hud.removeFromSuperview()
            hud.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
            hud.containerView.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        }
        
        let translationAnimation = CAKeyframeAnimation(keyPath: "transform.translation")
        translationAnimation.duration = ViewMetrics.duration
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        translationAnimation.isRemovedOnCompletion = false
        translationAnimation.fillMode = .forwards
        switch hud.location {
            case .top:
                translationAnimation.values = [CGPoint.zero, CGPoint(x: 0, y: -hud.containerView.frame.maxY)]
            case .bottom:
                translationAnimation.values = [CGPoint.zero, CGPoint(x: 0, y: hud.frame.height - hud.containerView.frame.minY)]
            case .center:
                break
        }
         
        hud.containerView.layer.add(translationAnimation, forKey: ViewMetrics.hideAnimationKey)
        hud.layer.add(opacityAnimation, forKey: ViewMetrics.hideAnimationKey)
    }
    
    func cancel(hud: IMProgressHUD) {
        hud.layer.removeAnimation(forKey: ViewMetrics.showAnimationKey)
        if let animation = hud.layer.animation(forKey: ViewMetrics.hideAnimationKey) {
            animation.completion = nil
            hud.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        }
        hud.layer.opacity = 1.0

        hud.containerView.layer.removeAnimation(forKey: ViewMetrics.showAnimationKey)
        hud.containerView.layer.removeAnimation(forKey: ViewMetrics.hideAnimationKey)
        hud.containerView.layer.setAffineTransform(.identity)
    }
}
