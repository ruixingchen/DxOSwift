//
//  SearchResultController.swift
//  DXOSwift
//
//  Created by ruixingchen on 28/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import MJRefresh
import SnapKit

protocol SearchResultControllerDelegate: class {
    func searchResultController(didSelect review:Review)
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
}

class SearchResultController: RXTableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {

    var searchDataSource:[Review] = []
    var page:Int = 1
    var lastSearchText:String = ""

    weak var delegate:SearchResultControllerDelegate?
    /// convenience way to approach searchController
    weak var searchController:UISearchController?

    var loadingIndicator:UIActivityIndicatorView?
    var nothingFoundView:SearchResultNothingFoundView?

    deinit {
        #if DEBUG || debug
            log.verbose("deinit")
        #endif
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchController?.searchBar.placeholder = LocalizedString.title_search
    }

    override func setupTableView() {
        super.setupTableView()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 100
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.isHidden = false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    //MARK: - UISearchControllerDelegate

    func willPresentSearchController(_ searchController: UISearchController) {
        self.searchController?.searchResultsController?.view.isHidden = false
    }

    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10)) {
            self.searchController?.searchResultsController?.view.isHidden = false
            //FIXME: - may out of work in the future version of iOS
            if let searchTextField:UITextField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
                searchTextField.textColor = UIColor.white
            }
            self.searchController?.searchBar.becomeFirstResponder()
        }
    }

    //MARK: - UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {
        self.searchController?.searchResultsController?.view.isHidden = false
    }

    //MARK: - UISearchBarDelegate

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.delegate?.searchBarCancelButtonClicked(searchBar)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        let searchText:String = searchBar.text ?? ""
        if searchText.isEmpty {
            return
        }
        self.lastSearchText = searchText

        self.tableView.mj_footer = nil
        self.searchDataSource = []
        self.tableView.reloadData()
        //display loading indicator
        if self.loadingIndicator == nil {
            self.loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            self.loadingIndicator?.hidesWhenStopped = true
            self.view.addSubview(loadingIndicator!)
            loadingIndicator?.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
        }
        self.loadingIndicator?.startAnimating()
        if self.nothingFoundView?.isHidden == false {
            self.nothingFoundView?.isHidden = true
        }

        DXOService.search(key: searchText, page: 1, userInfo: ["key":searchText]) {[weak self] (inObject, inUserInfo, inError) in
            if self == nil {
                return
            }
            guard let infoKey:String = inUserInfo?["key"] as? String, infoKey == self?.lastSearchText  else {
                log.verbose("search text not match")
                return
            }
            if inObject == nil || inError != nil || inUserInfo == nil {
                DispatchQueue.main.async {
                    self?.view.makeToast(LocalizedString.refresh_failed_try_again_later)
                }
                return
            }
            DispatchQueue.main.async {
                if self?.loadingIndicator?.superview != nil {
                    self?.loadingIndicator?.stopAnimating()
                }

                if inObject!.isEmpty {
                    if self?.nothingFoundView == nil {
                        self?.nothingFoundView = SearchResultNothingFoundView()
                        self?.view.addSubview(self!.nothingFoundView!)
                        self?.nothingFoundView?.snp.makeConstraints({ (make) in
                            make.center.equalToSuperview()
                            make.width.equalTo(250)
                            make.height.equalTo(80)
                        })
                    }
                    self?.nothingFoundView?.isHidden = false
                    return
                }

                self?.searchDataSource = inObject!
                self?.page = 1
                self?.tableView.reloadData()
                if self?.tableView.mj_footer == nil {
                    self?.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self!, refreshingAction: #selector(self!.footerRefreshAction))
                }
            }
        }
    }

    //MARK: - Action

    @objc func footerRefreshAction(){
        DXOService.search(key: lastSearchText, page: page+1, userInfo: ["key": lastSearchText]) {[weak self] (inObject, inUserInfo, inError) in
            if self == nil {
                return
            }
            guard let infoKey:String = inUserInfo?["key"] as? String, infoKey == self?.lastSearchText  else {
                log.verbose("search text not match")
                return
            }
            if inObject == nil || inError != nil || inUserInfo == nil {
                DispatchQueue.main.async {
                    self?.view.makeToast("request failed")
                }
                return
            }
            DispatchQueue.main.async {
                if self?.loadingIndicator?.superview != nil {
                    self?.loadingIndicator?.stopAnimating()
                }
                if inObject!.isEmpty {
                    self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                    return
                }
                self?.page += 1
                let originRow:Int = self!.searchDataSource.count
                self?.tableView.beginUpdates()
                for i in 0..<inObject!.count {
                    self?.searchDataSource.append(inObject![i])
                    self?.tableView.insertRows(at: [IndexPath.init(row: originRow+i, section: 0)], with: .none)
                }
                self?.tableView.endUpdates()
                self?.tableView.mj_footer.endRefreshing()
            }

        }
    }

    //MARK: - TableView

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchDataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let review:Review = self.searchDataSource.safeGet(at: indexPath.row) else {
            let cell:RXBlankTableViewCell = RXBlankTableViewCell(reuseIdentifier: nil)
            #if DEBUG || debug
                cell.infoLabel.text = "can not get search review"
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
        guard let review:Review = self.searchDataSource.safeGet(at: indexPath.row) else {
            return
        }
        self.delegate?.searchResultController(didSelect: review)
    }

    /// when we scrolls, we want to display more content
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            if self.searchController?.searchBar.isFirstResponder == true {
                self.searchController?.searchBar.resignFirstResponder()
            }
        }
    }
}
