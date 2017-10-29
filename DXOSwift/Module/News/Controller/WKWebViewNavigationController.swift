//
//  WKWebViewNavigationController.swift
//  DXOSwift
//
//  Created by ruixingchen on 29/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class WKWebViewNavigationController: UINavigationController {

    var enableDismiss:Bool = false

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if enableDismiss || self.presentedViewController != nil {
            super.dismiss(animated: flag, completion: nil)
        }
    }
}
