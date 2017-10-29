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
        self.title = LocalizedString.title_camera_review
    }

    deinit {
        #if DEBUG || debug
            log.verbose("deinit")
        #endif
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let dbItem:UIBarButtonItem = UIBarButtonItem(title: "DB", style: UIBarButtonItemStyle.plain, target: self, action: #selector(didTapDBButton))
        self.navigationItem.rightBarButtonItem = dbItem
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    }

    @objc func didTapDBButton(){
        let next:DeviceDatabaseController = DeviceDatabaseController(deviceType: .camera)
        next.view.backgroundColor = UIColor.white
        next.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(next, animated: true)
    }

    override func headerRefresh() {
        super.headerRefresh()
    }

    override func footerRefresh() {
        super.footerRefresh()
    }

    override func headerRefreshHandle(inObject: [Review]?, inError: RXError?, userInfo: UserInfo?) {
        super.headerRefreshHandle(inObject: inObject, inError: inError, userInfo: userInfo)
    }

    override func footerRefreshHanle(inObject: [Review]?, inError: RXError?, userInfo: UserInfo?) {
        super.footerRefreshHanle(inObject: inObject, inError: inError, userInfo: userInfo)
    }

}
