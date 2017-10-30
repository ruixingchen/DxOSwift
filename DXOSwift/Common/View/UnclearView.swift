//
//  UnclearView.swift
//  DXOSwift
//
//  Created by ruixingchen on 30/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class UnclearView: UIView {

    override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {
            if newValue == nil || newValue?.cgColor.alpha == 0 || newValue == UIColor.clear {
                return
            }
            super.backgroundColor = newValue
        }
    }

}
