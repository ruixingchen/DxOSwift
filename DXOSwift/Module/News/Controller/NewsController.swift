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

/// the main controller
class NewsController: RXTableViewController {

    private var cycleScrollView:SDCycleScrollView?

    private var cycleScrollViewHeight:CGFloat = 250 //for 375 width(4.7 inch devices)

    private var dataSource:NSMutableArray = [] //one dimension
    private var topTopicDataSource:NSMutableArray = [] //one dimension

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }

    override func firstViewWillAppear(_ animated: Bool) {
        super.firstViewWillAppear(animated)
        cycleScrollView?.adjustWhenControllerViewWillAppera()
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
        tableView.contentInsetAdjustmentBehavior = .always
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
        headerRefresh()
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
    }

    //MARK: - ScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != tableView {
            return
        }


    }

}
