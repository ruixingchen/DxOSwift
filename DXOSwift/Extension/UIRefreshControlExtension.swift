//
//  UIRefreshControlExtension.swift
//  DXOSwift
//
//  Created by ruixingchen on 24/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

extension UIRefreshControl {
    func refreshManually() {
        beginRefreshing()
        sendActions(for: UIControlEvents.valueChanged)
        if let scrollView:UIScrollView = self.superview as? UIScrollView {
            var offset:CGPoint = scrollView.contentOffset
            offset.y = offset.y-bounds.height
            scrollView.setContentOffset(offset, animated: true)
        }
    }
}
