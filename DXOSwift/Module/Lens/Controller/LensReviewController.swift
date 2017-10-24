//
//  LensReviewController.swift
//  DXOSwift
//
//  Created by ruixingchen on 20/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import Toast_Swift
import MJRefresh

class LensReviewController: GenericReviewListController {

    override func initFunction() {
        super.initFunction()
        self.title = "title_lens_review".localized()
    }

    override func headerRefresh() {
        DXOService.lensReview(page: 1) {[weak self] (inObject, inError) in
            if self == nil {
                return
            }
            self?.headerRefreshHandle(inObject: inObject, inError: inError)
        }
    }

    override func footerRefresh() {
        DXOService.lensReview(page: page+1) {[weak self] (inObject, inError) in
            if self == nil {
                return
            }
            self?.footerRefreshHanle(inObject: inObject, inError: inError)
        }
    }

}
