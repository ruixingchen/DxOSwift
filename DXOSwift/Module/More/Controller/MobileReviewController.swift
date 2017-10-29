//
//  MobileReviewController.swift
//  DXOSwift
//
//  Created by ruixingchen on 23/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import MJRefresh
import Toast_Swift

class MobileReviewController: GenericReviewListController {

    override func initFunction() {
        super.initFunction()
        self.title = LocalizedString.title_mobile_review
    }

    override func headerRefresh() {
        DXOService.mobileReview(page: 1) {[weak self] (inObject, inError) in
            if self == nil {
                return
            }
            self?.headerRefreshHandle(inObject: inObject, inError: inError)
        }
    }

    override func footerRefresh() {
        DXOService.mobileReview(page: page+1) {[weak self] (inObject, inError) in
            if self == nil {
                return
            }
            self?.footerRefreshHanle(inObject: inObject, inError: inError)
        }
    }

}

