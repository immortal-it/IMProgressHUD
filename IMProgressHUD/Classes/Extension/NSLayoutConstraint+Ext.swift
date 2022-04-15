//
//  NSLayoutConstraint+Ext.swift
//  IMProgressHUD
//
//  Created by immortal on 2021/11/28.
//

import UIKit

extension NSLayoutConstraint {
    
    func priority(_ layoutPriority: UILayoutPriority) -> Self {
        priority = layoutPriority
        return self
    }
}
