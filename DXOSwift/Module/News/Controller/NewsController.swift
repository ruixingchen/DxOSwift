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
class NewsController: RXTableViewController, SDCycleScrollViewDelegate {

    private var cycleScrollView:SDCycleScrollView?

    private var cycleScrollViewHeight:CGFloat = 250 //for 375 width(4.7 inch devices)

    private var dataSource:NSMutableArray = [] //one dimension
    private var topTopicDataSource:NSMutableArray = [] //one dimension

    var page:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cycleScrollView?.adjustWhenControllerViewWillAppera()
    }

    override func firstViewWillAppear(_ animated: Bool) {
        super.firstViewWillAppear(animated)
    }

    override func firstViewDidLayoutSubviews() {
        super.firstViewDidLayoutSubviews()

    }

    override func firstViewDidAppear(_ animated: Bool) {
        super.firstViewDidAppear(animated)
        headerRefreshAction()
    }

    override func setupTableView() {
        super.setupTableView()
        tableView.tableFooterView = UIView()
//        tableView.contentInsetAdjustmentBehavior = .always
        tableView.estimatedRowHeight = 0
        tableView.rowHeight = 100

    }

    func setupSubviews(){
        let searchButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(didTapSearchButton))
        searchButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = searchButton
        let imageView:UIImageView = UIImageView(image: UIImage(named: "dxo_logo"))
//        self.navigationItem.titleView = imageView
    }

    //MARK: - Action

    @objc func headerRefreshAction(){
        headerRefresh()
    }

    @objc func footerRefreshAction(){
        footerRefresh()
    }

    @objc func didTapSearchButton(){
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.white
        self.navigationController?.pushViewController(vc, animated: true)
    }

    //MARK: - Request

    func headerRefresh(){
        //when we do header refresh, we overwrite all the data source.
        DXOService.mainPage(completion: {[weak self] (inTopTopic, inNews, inError) in
            if inError != nil || inNews == nil {
                if inError != nil {
                    log.debug("main page with error: \(inError!.description)")
                }else if inNews == nil {
                    log.debug("main page news nil")
                }else {
                    log.debug("main page unknown error")
                }
                DispatchQueue.main.async {
                    self?.tableView.refreshControl?.endRefreshing()
                    try? self?.view.toastViewForMessage("please try again", title: "Failed", image: nil, style: ToastStyle.init())
                }
                return
            }else if self == nil {
                log.info("self deinited")
                return
            }
            DispatchQueue.main.async {
                if inTopTopic != nil {
                    self?.topTopicDataSource = NSMutableArray(array: inTopTopic!)
                    self?.cycleScrollViewHeight = self!.view.bounds.width/1.75
                    self?.cycleScrollView = SDCycleScrollView()
                    self?.cycleScrollView?.bannerImageViewContentMode = .scaleAspectFill
                    self?.cycleScrollView?.autoScrollTimeInterval = 3
                    self?.cycleScrollView?.titleLabelHeight = 60
                    self?.cycleScrollView?.delegate = self!
                    var imageArray:[String] = []
                    var titleArray:[String] = []
                    for i in inTopTopic! {
                        imageArray.append(i.coverImage ?? "")
                        titleArray.append(i.title)
                    }
                    self?.cycleScrollView?.imageURLStringsGroup = imageArray
                    self?.cycleScrollView?.titlesGroup = titleArray
                    self?.cycleScrollView?.frame = CGRect(x: 0, y: 0, width: self!.tableView.bounds.width, height: self!.cycleScrollViewHeight)
                    self?.tableView.tableHeaderView = self?.cycleScrollView
                }
                self?.page = 1
                self?.dataSource = NSMutableArray(array: inNews!)
                self?.tableView.refreshControl?.endRefreshing()
                self?.tableView.reloadData()

                if self?.tableView.refreshControl == nil {
                    let rc:UIRefreshControl = UIRefreshControl()
                    rc.addTarget(self, action: #selector(self!.headerRefreshAction), for: UIControlEvents.valueChanged)
                    self?.tableView.refreshControl = rc
                }
                if self?.tableView.mj_footer == nil {
                    self?.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self!, refreshingAction: #selector(self!.footerRefreshAction))
                }
            }
        })
    }

    func footerRefresh() {
        //we load the next page
        DXOService.news(page: page+1) {[weak self] (inReviews, inError) in
            if inError != nil || inReviews == nil {
                if inError != nil {
                    log.debug("news with error: \(inError!.description)")
                }else if inReviews == nil {
                    log.debug("news news nil")
                }else {
                    log.debug("news unknown error")
                }
                DispatchQueue.main.async {
                    try? self?.view.toastViewForMessage("please try again", title: "Failed", image: nil, style: ToastStyle.init())
                    self?.tableView.mj_footer?.endRefreshing()
                }
                return
            }else if self == nil {
                log.info("self deinited")
                return
            }
            DispatchQueue.main.async {
                if inReviews!.isEmpty {
                    self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }else{
                    self?.tableView.beginUpdates()
                    let originCount:Int = self!.dataSource.count
                    let newDataSource:NSMutableArray = NSMutableArray(array: self!.dataSource as! [Any])
                    for i in 0..<inReviews!.count {
                        newDataSource.add(inReviews![i])
                        self?.tableView.insertRows(at: [IndexPath(row: originCount+i,section:0)], with: .none)
                    }
                    self?.dataSource = newDataSource
                    self?.tableView.endUpdates()
                    self?.tableView.mj_footer?.endRefreshing()
                    self?.page += 1
                }
            }
        }
    }

    //MARK: - TableView

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
        let detail:NewsDetailController = NewsDetailController(review: review)
        detail.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(detail, animated: true)
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
        if review.targetUrl.hasSuffix("www.dxomark.com/Cameras/") || review.targetUrl.hasSuffix("www.dxomark.com/Cameras") {
            //go to camera DB
            let camerasDataBaseController:CameraDataBaseController = CameraDataBaseController()
            self.navigationController?.pushViewController(camerasDataBaseController, animated: true)
        }else if review.targetUrl.hasSuffix("www.dxomark.com/Lenses/") || review.targetUrl.hasSuffix("www.dxomark.com/Lenses") {
            //go to lenses DB
        }else {
            let detail:NewsDetailController = NewsDetailController(review: review)
            detail.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(detail, animated: true)
        }

    }

}
