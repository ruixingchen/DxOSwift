//
//  ArticlesController.swift
//  DXOSwift
//
//  Created by ruixingchen on 23/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class ArticlesController: RXTableViewController {

    var dataSource:NSMutableArray = NSMutableArray()
    var page:Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Articles"
        self.tableView.refreshControl?.beginRefreshing()
        headerRefreshAction()
    }

    override func setupTableView() {
        super.setupTableView()
        let rc:UIRefreshControl = UIRefreshControl()
        rc.addTarget(self, action: #selector(self.headerRefreshAction), for: UIControlEvents.valueChanged)
        self.tableView.refreshControl = rc

        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 0
        tableView.rowHeight = 100
    }

    @objc func headerRefreshAction(){
        headerRefresh()
    }

    func headerRefresh(){
        DXOService.articles(completion: {[weak self] (inObject, inError) in
            if inError != nil || inObject == nil {
                DispatchQueue.main.async {
                    self?.tableView.refreshControl?.endRefreshing()
                    self?.view.makeToast("request failed, pull to refresh again", duration: 3, position: self!.view.center)
                }
                return
            }else if self == nil {
                log.info("self is nil")
                return
            }

            DispatchQueue.main.async {
                self?.dataSource = NSMutableArray(array: inObject!)
                self?.page = 1
                self?.tableView.refreshControl?.endRefreshing()
                self?.tableView.reloadData()
            }
        })
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
        let detail:NewsDetailController = NewsDetailController(review: review)
        detail.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(detail, animated: true)
    }

}
