//
//  NewsController.swift
//  DXOSwift
//
//  Created by ruixingchen on 18/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import MJRefresh
import SDCycleScrollView
import SnapKit
import Toast_Swift

/// the main controller
class NewsController: GenericReviewListController, SDCycleScrollViewDelegate {

    private var cycleScrollView:SDCycleScrollView?

    private var cycleScrollViewHeight:CGFloat = 250 //for 375 width(4.7 inch devices)

    private var topTopicDataSource:NSMutableArray = [] //one dimension

    override func initFunction() {
        super.initFunction()
        self.title = LocalizedString.title_dxo
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cycleScrollView?.adjustWhenControllerViewWillAppera()
    }

    override func setupSubviews(){
        let searchButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(didTapSearchButton))
        searchButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = searchButton
//        let imageView:UIImageView = UIImageView(image: UIImage(named: "dxo_logo"))
//        self.navigationItem.titleView = imageView
    }

    //MARK: - Action

    @objc func didTapSearchButton(){
        let next = SearchContainerController()
        next.hidesBottomBarWhenPushed = true
        next.view.backgroundColor = UIColor.white
        self.navigationController?.pushViewController(next, animated: true)
    }

    //MARK: - Request

    override func headerRefresh(){
        //when we do header refresh, we overwrite all the data source.
        DXOService.mainPage(completion: {[weak self] (inTopTopic, inNews, inError) in
            if self == nil {
                log.debug("self nil")
                return
            }
            var userInfo:UserInfo = [:]
            if inTopTopic != nil {
                userInfo.updateValue(inTopTopic!, forKey: "top")
            }
            self?.headerRefreshHandle(inObject: inNews, inError: inError, userInfo: userInfo)
        })
    }

    override func footerRefresh() {
        //we load the next page
        DXOService.news(page: page+1) {[weak self] (inReviews, inError) in
            if self == nil {
                log.debug("self nil")
                return
            }
            self?.footerRefreshHanle(inObject: inReviews, inError: inError)
        }
    }

    override func headerRefreshHandle(inObject: [Review]?, inError: RXError?, userInfo: UserInfo? = nil) {
        if inError != nil || inObject == nil{
            if inError != nil {
                log.debug("error: \(inError!.description)")
            }else if inObject == nil {
                log.debug("inObject nil")
            }else {
                log.debug("unknown error")
            }
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
                    self.view.makeToast(LocalizedString.refresh_failed_try_again_later)
                }
            }
            return
        }
        DispatchQueue.main.async {

            if let inTopTopic = userInfo?["top"] as? [Review] {
                if self.cycleScrollView == nil {
                    self.cycleScrollView = SDCycleScrollView()
                    self.cycleScrollView?.bannerImageViewContentMode = .scaleAspectFill
                    self.cycleScrollView?.autoScrollTimeInterval = 3
                    self.cycleScrollView?.titleLabelHeight = 60
                    self.cycleScrollView?.delegate = self
                }
                self.topTopicDataSource = NSMutableArray(array: inTopTopic)
                self.cycleScrollViewHeight = self.view.bounds.width/1.75

                var imageArray:[String] = []
                var titleArray:[String] = []
                for i in inTopTopic {
                    imageArray.append(i.coverImage ?? "")
                    titleArray.append(i.title)
                }
                self.cycleScrollView?.imageURLStringsGroup = imageArray
                self.cycleScrollView?.titlesGroup = titleArray
                self.cycleScrollView?.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.cycleScrollViewHeight)
                self.tableView.tableHeaderView = self.cycleScrollView
            }else{
                if self.cycleScrollView != nil {
                    self.tableView.tableHeaderView = nil
                    self.cycleScrollView?.removeFromSuperview()
                    self.cycleScrollView = nil
                }
            }
            self.page = 1
            self.dataSource = NSMutableArray(array: inObject!)
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()

            if self.tableView.refreshControl == nil {
                let rc:UIRefreshControl = UIRefreshControl()
                rc.addTarget(self, action: #selector(self.headerRefreshAction), for: UIControlEvents.valueChanged)
                self.tableView.refreshControl = rc
            }
            if self.tableView.mj_footer == nil {
                self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(self.footerRefreshAction))
            }
        }
    }

    //MARK: - ScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != tableView {
            return
        }
    }

    //MARK: - SDCycleScrollViewDelegate

    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        guard let review:Review = self.topTopicDataSource.safeGet(at: index) as? Review else {
            log.error("can not get top topic for index \(index), data source count:\(self.topTopicDataSource.count)")
            return
        }
        var nextController:UIViewController?
        if review.targetUrl.hasSuffix("www.dxomark.com/Cameras/") || review.targetUrl.hasSuffix("www.dxomark.com/Cameras") {
            //go to camera DB
            nextController = DeviceDatabaseController(deviceType: DeviceDatabaseController.DeviceType.camera)
        }else if review.targetUrl.hasSuffix("www.dxomark.com/Lenses/") || review.targetUrl.hasSuffix("www.dxomark.com/Lenses") {
            //go to lenses DB
            nextController = DeviceDatabaseController(deviceType: DeviceDatabaseController.DeviceType.lens)
        }else {
            nextController = NewsDetailController(review: review)
        }
        if nextController == nil {
            return
        }
        nextController?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(nextController!, animated: true)
    }

}
