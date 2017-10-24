//
//  LensReviewController.swift
//  DXOSwift
//
//  Created by ruixingchen on 20/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class LensReviewController: RXTableViewController {

    override init() {
        super.init()
        self.title = "title_lens_review".localized()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = "title_lens_review".localized()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    //MARK: - RetryLoadingViewDelegate

    func retryLoadingViewDidTapRetryButton(retryLoadingView: RetryLoadingView) {
        self.tableView.refreshControl?.refreshManually()
    }

}
