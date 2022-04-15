//
//  CAAnimation+Ext.swift
//  IMProgressHUD
//
//  Created by immortal on 2022/4/14
//
        
import QuartzCore

/// The internal implementation for `CAAnimationDelegate`.
private class CAAnimationDelegator: NSObject, CAAnimationDelegate {
    
    var completion: ((Bool) -> Void)?

    
    func animationDidStop(_ theAnimation: CAAnimation, finished: Bool) {
        completion?(finished)
    }
}

public extension CAAnimation {
    
    /// A block (closure) object to be executed when the animation ends.
    /// This block has no return value and takes a single Boolean argument that indicates whether or not the animations actually finished.
    var completion: ((Bool) -> Void)? {
        set {
            if let delegator = delegate as? CAAnimationDelegator {
                delegator.completion = newValue
            } else {
                let delegator = CAAnimationDelegator()
                delegator.completion = newValue
                delegate = delegator
            }
        }
        get {
            if let delegator = delegate as? CAAnimationDelegator {
                return delegator.completion
            }
            return nil
        }
    }
}
