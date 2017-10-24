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

}
