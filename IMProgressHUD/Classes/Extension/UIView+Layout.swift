//
//  UIView+Layout.swift
//  IMProgressHUD
//
//  Created by immortal on 2021/11/27.
//

import UIKit

extension UIView {
    
    /// A layout anchor representing the top edge of the view’s frame.
    var safeTopAnchor: NSLayoutYAxisAnchor {
        safeAreaLayoutGuide.topAnchor
    }
    
    /// A layout anchor representing the bottom edge of the view’s frame.
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        safeAreaLayoutGuide.bottomAnchor
    }
    
    /// Adds a view to the end of the receiver’s list of subviews.
    /// Activates each constraint in the specified array.
    func addSubview(_ view: UIView, constraints: NSLayoutConstraint...) {
        if view.translatesAutoresizingMaskIntoConstraints {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addSubview(view)
        NSLayoutConstraint.activate(constraints)
    }
    
    /// Adds a view to the end of the receiver’s list of subviews.
    func addSubviewLayoutEqualToEdges(_ view: UIView) {
        addSubview(
            view,
            constraints:
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
                view.topAnchor.constraint(equalTo: topAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor)
        )
    }
}
