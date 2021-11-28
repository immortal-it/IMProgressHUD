//
//  UIApplication+Window.swift
//  IMProgressHUD
//
//  Created by immortal on 2021/11/27.
//

import UIKit

extension UIApplication {
    
    /// The app's key window.
    ///
    /// This property holds the UIWindow object in the windows array that is most recently sent the makeKeyAndVisible() message.
    var compatibleKeyWindow: UIWindow? {
        if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            return keyWindow
        }
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .first(where: { $0 is UIWindowScene })
                .flatMap({ $0 as? UIWindowScene })?.windows
                .first(where: \.isKeyWindow)
        } else {
            return nil
        }
    }
}
