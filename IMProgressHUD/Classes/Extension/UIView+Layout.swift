//
//  UIView+Layout.swift
//  IMProgressHUD
//
//  Created by immortal on 2021/11/27.
//

import UIKit

extension UIView {
    
    /// A layout anchor representing the top edge of the view’s frame.
    var compatibleSafeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.topAnchor
        } else {
            return topAnchor
        }
    }
    
    /// A layout anchor representing the bottom edge of the view’s frame.
    var compatibleSafeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.bottomAnchor
        } else {
            return bottomAnchor
        }
    }
    
    func addSubview(_ view: UIView, constraints: NSLayoutConstraint...) {
        if view.translatesAutoresizingMaskIntoConstraints {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addSubview(view)
        NSLayoutConstraint.activate(constraints)
    }
}
