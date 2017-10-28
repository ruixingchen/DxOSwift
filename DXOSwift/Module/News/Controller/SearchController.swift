//
//  SearchController.swift
//  DXOSwift
//
//  Created by ruixingchen on 27/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class SearchController: RXViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    /// we should delay the presearch action, to save data
    static let presearchDelay:TimeInterval = 0.75

    var searchController:UISearchController!
    let searchResultController:SearchResultController = SearchResultController()
    let searchingIndicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    var presearchOperationQueue:OperationQueue = OperationQueue()

    /// tag the presearch action for organize the request and response,
    /// if the response does not match the request, we should not display it
    var currentPresearchIdentifier:String = ""

    var currentSearchIdentifier:String = ""
    var page:Int = 1

    override func initFunction() {
        super.initFunction()
        searchController = UISearchController(searchResultsController: searchResultController)
        searchResultController.delegate = self
        searchResultController.searchController = searchController
        self.title = "title_search".localized()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.delegate = self
        searchController.searchResultsUpdater = self

        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchBar.placeholder = "title_search".localized()
        searchController.searchBar.delegate = self

        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
    }

//MARK: - UISearchControllerDelegate

    func willPresentSearchController(_ searchController: UISearchController) {
        self.searchController.searchResultsController?.view.isHidden = false
    }

    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(10)) {
            //FIXME: - may out of work in the future version of iOS
            if let searchTextField:UITextField = self.searchController.searchBar.value(forKey: "searchField") as? UITextField {
                searchTextField.textColor = UIColor.white
            }
            self.searchController.searchBar.becomeFirstResponder()
            self.searchController.searchResultsController?.view.isHidden = false
        }
    }

//MARK: - UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {
        if self.searchController.searchResultsController?.view.isHidden ?? false {
            self.searchController.searchResultsController?.view.isHidden = false
        }
        //for now we only do search, update presearch in the future
        return
        /*
        guard let searchText:String = searchController.searchBar.text, !searchText.isEmpty else {
            log.debug("search controller go to empty")
            self.currentPresearchIdentifier = ""
            presearchOperationQueue.cancelAllOperations()
            searchResultController.presearchDataSource = []
            searchResultController.shouldShowPresearch = false
            searchResultController.tableView.reloadData()
            return
        }
        if searchText == currentPresearchIdentifier {
            presearchOperationQueue.cancelAllOperations()
            return
        }
        log.debug("search text updated with text :\(searchText)")
        presearchOperationQueue.cancelAllOperations()
        let delayedOperation:BlockOperation = BlockOperation()
        delayedOperation.addExecutionBlock { [weak self, weak delayedOperation] () in
            Thread.sleep(forTimeInterval: SearchController.presearchDelay)
            if self == nil {
                return
            }
            guard !(delayedOperation?.isCancelled ?? true) else {
                log.verbose("presearch cancelled")
                return
            }
            log.verbose("start to presearch with text: \(searchText)")
            self?.currentPresearchIdentifier = searchText

            self?.searchResultController.tableView.mj_footer = nil

            DXOService.presearch(key: searchText, userInfo: ["identifier": self!.currentPresearchIdentifier], completion: { (inObject, inUserInfo, inError) in
                if inObject == nil || inError != nil {
                    return
                }
                guard let inIdentifier:String = inUserInfo?["identifier"] as? String else {
                    log.error("can not get identifier")
                    return
                }
                if inIdentifier != self?.currentPresearchIdentifier {
                    log.debug("does not match the current presearch identifier")
                    return
                }else{
                    log.verbose("match the identifier, current:\(self!.currentPresearchIdentifier), response:\(inIdentifier)")
                }
                OperationQueue.main.addOperation {
                    self?.searchResultController.presearchDataSource = inObject!
                    self?.searchResultController.shouldShowPresearch = true
                    self?.searchResultController.tableView.rowHeight = 100
                    self?.searchResultController.tableView.reloadData()
                }
            })
        }
        presearchOperationQueue.addOperation(delayedOperation)
 */
    }

//MARK: - UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.popViewController(animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchResultController.shouldShowPresearch = false
        self.searchResultController.searchDataSource = []
        self.searchResultController.tableView.reloadData()
        guard let searchText:String = searchBar.text, !searchText.isEmpty else {
            return
        }
        if searchText == self.currentSearchIdentifier {
            return
        }
        DXOService.search(key: searchText, page: 1, userInfo: ["identifier": searchText]) {[weak self] (inObject, inUserInfo, inError) in
            if inObject == nil || inError != nil {
                return
            }
            guard let inIdentifier:String = inUserInfo?["identifier"] as? String else {
                log.error("can not get identifier")
                return
            }
            if inIdentifier != self?.currentPresearchIdentifier {
                log.debug("does not match the current presearch identifier")
                return
            }else{
                log.verbose("match the identifier, current:\(self!.currentPresearchIdentifier), response:\(inIdentifier)")
            }
            OperationQueue.main.addOperation {
                self?.searchResultController.searchDataSource = inObject!
                self?.searchResultController.shouldShowPresearch = false
                self?.searchResultController.tableView.rowHeight = 100
                self?.searchResultController.tableView.reloadData()
            }
        }
    }
}

extension SearchController: SearchResultControllerDelegate {
    func searchResultController(didSelect presearch: PresearchObject) {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.white
        searchController.present(vc, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(3)) {
            vc.dismiss(animated: true, completion: nil)
        }
    }

    func searchResultController(didSelect review: Review) {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.white
        searchController.present(vc, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(3)) {
            vc.dismiss(animated: true, completion: nil)
        }
    }


}
