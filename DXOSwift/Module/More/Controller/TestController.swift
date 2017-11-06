//
//  TestController.swift
//  DXOSwift
//
//  Created by ruixingchen on 24/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import SnapKit
import Toast_Swift

#if DEBUG || debug
class TestController: RXTableViewController, RetryLoadingViewDelegate {

    var retryLoadingView:RetryLoadingView?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()

        self.tableView.refreshControl?.beginRefreshing()
        self.tableView.refreshControl?.sendActions(for: UIControlEvents.valueChanged)

    }

    override func setupTableView() {
        super.setupTableView()
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(headerRefresh), for: UIControlEvents.valueChanged)
    }

    @objc func headerRefresh(){
        if self.retryLoadingView != nil {
            self.retryLoadingView?.removeFromSuperview()
            self.retryLoadingView = RetryLoadingView()
        }
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(3)) {[weak self]()in
            DispatchQueue.main.async {
                self?.tableView.refreshControl?.endRefreshing()

                self?.retryLoadingView?.removeFromSuperview()
                self?.retryLoadingView = RetryLoadingView()
                self?.retryLoadingView?.delegate = self
                self?.tableView.addSubview(self!.retryLoadingView!)
                self?.retryLoadingView?.snp.makeConstraints({ (make) in
                    make.center.equalToSuperview()
                    make.width.equalToSuperview()
                    make.height.equalToSuperview()
                })
            }
        }
    }

    func retryLoadingViewDidTapRetryButton(retryLoadingView: RetryLoadingView) {
        self.tableView.refreshControl?.refreshManually()
    }

}
#endif
