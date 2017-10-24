//
//  CameraReviewController.swift
//  DXOSwift
//
//  Created by ruixingchen on 20/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import MJRefresh
import Toast_Swift

class CameraReviewController: GenericReviewListController {

    override func initFunction() {
        super.initFunction()
        self.title = "title_camera_review".localized()
    }

}
