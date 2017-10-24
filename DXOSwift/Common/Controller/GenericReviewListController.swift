//
//  GenericReviewListController.swift
//  DXOSwift
//
//  Created by ruixingchen on 24/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import MJRefresh
import Toast_Swift

class GenericReviewListController: RXTableViewController, RetryLoadingViewDelegate {
    
    var retryLoadingView:RetryLoadingView?

    var dataSource:NSMutableArray = NSMutableArray()
    var page:Int = 1

    override func setupTableView() {
        super.setupTableView()
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 0
        tableView.rowHeight = 100

        installHeaderRefreshControl()
    }

    func setupSubviews(){

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        self.tableView.refreshControl?.refreshManually()
    }

    func installHeaderRefreshControl(userInfo:UserInfo? = nil){
        if self.tableView.refreshControl == nil {
            let rc:UIRefreshControl = UIRefreshControl()
            rc.addTarget(self, action: #selector(self.headerRefreshAction), for: UIControlEvents.valueChanged)
            self.tableView.refreshControl = rc
        }
    }

    func installFooterRefreshControl(userInfo:UserInfo? = nil){
        if self.tableView.mj_footer == nil {
            self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(self.footerRefreshAction))
        }
    }

    @objc func headerRefreshAction(){
        retryLoadingView?.removeFromSuperview()
        headerRefresh()
    }

    @objc func footerRefreshAction(){
        footerRefresh()
    }

    func headerRefresh(){
        DXOService.cameraReview(page: 1) {[weak self] (inObject, inError) in
            if self == nil {
                return
            }
            self?.headerRefreshHandle(inObject: inObject, inError: inError)
        }
    }

    func headerRefreshHandle(inObject:[Review]?, inError:RXError?, userInfo:UserInfo? = nil) {
        if inError != nil || inObject == nil {
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                if self.dataSource.count == 0 {
                    //show loading failed view
                    self.retryLoadingView?.removeFromSuperview()
                    self.retryLoadingView = nil
                    self.retryLoadingView = RetryLoadingView()
                    self.retryLoadingView?.delegate = self
                    self.tableView.addSubview(self.retryLoadingView!)
                    self.retryLoadingView?.snp.makeConstraints({ (make) in
                        make.center.equalToSuperview()
                        make.size.equalToSuperview()
                    })
                }else{
                    self.view.makeToast("refresh_failed_try_again_later".localized())
                }
            }
            return
        }

        DispatchQueue.main.async {
            self.dataSource = NSMutableArray(array: inObject!)
            self.page = 1
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
            self.installHeaderRefreshControl()
            self.installFooterRefreshControl()
        }
    }

    func footerRefresh(){
        DXOService.cameraReview(page: page+1) {[weak self] (inObject, inError) in
            if self == nil {
                return
            }
            self?.footerRefreshHanle(inObject: inObject, inError: inError)
        }
    }

    func footerRefreshHanle(inObject:[Review]?, inError:RXError?, userInfo:UserInfo? = nil){
        if inError != nil || inObject == nil {
            DispatchQueue.main.async {
                self.tableView.mj_footer?.endRefreshing()
                self.view.makeToast("refresh_failed_try_again_later".localized())
            }
            return
        }
        DispatchQueue.main.async {
            if inObject!.isEmpty {
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }else{
                self.tableView.beginUpdates()
                let originCount:Int = self.dataSource.count
                let newDataSource:NSMutableArray = NSMutableArray(array: self.dataSource as! [Any])
                for i in 0..<inObject!.count {
                    newDataSource.add(inObject![i])
                    self.tableView.insertRows(at: [IndexPath(row: originCount+i,section:0)], with: .none)
                }
                self.dataSource = newDataSource
                self.tableView.endUpdates()
                self.tableView.mj_footer?.endRefreshing()
                self.page += 1
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let review:Review = dataSource.safeGet(at: indexPath.row) as? Review else {
            let cell = RXBlankTableViewCell(reuseIdentifier: String.init(describing: RXBlankTableViewCell.self))
            #if DEBUG || debug
                cell.infoLabel.text = "ERROR - can not get review object from dataSource"
            #endif
            return cell
        }
        var cell:NewsTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell") as? NewsTableViewCell
        if cell == nil {
            cell = NewsTableViewCell(reuseIdentifier: "cell")
        }
        cell?.updateContent(review: review)
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let review:Review = self.dataSource.safeGet(at: indexPath.row) as? Review else {
            return
        }
        log.debug("tap review: \(review.description)")
        let detail:NewsDetailController = NewsDetailController(review: review)
        detail.hidesBottomBarWhenPushed = true
        if let nav:UINavigationController = self.navigationController {
            nav.pushViewController(detail, animated: true)
        }else{
            self.present(detail, animated: true, completion: nil)
        }
    }

    //MARK: - RetryLoadingViewDelegate

    func retryLoadingViewDidTapRetryButton(retryLoadingView: RetryLoadingView) {
        self.tableView.refreshControl?.refreshManually()
    }
}
