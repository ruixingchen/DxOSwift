//
//  SearchContainerController.swift
//  DXOSwift
//
//  Created by ruixingchen on 27/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class SearchContainerController: RXViewController, SearchResultControllerDelegate {

    var searchController:UISearchController!
    let searchResultController: SearchResultController = SearchResultController()

    deinit {
        #if DEBUG || debug
            log.verbose("deinit")
        #endif
    }

    override func initFunction() {
        super.initFunction()
        self.title = LocalizedString.title_search
        searchController = UISearchController(searchResultsController: searchResultController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.delegate = searchResultController
        searchController.searchResultsUpdater = searchResultController

        searchController.searchBar.delegate = searchResultController
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.barTintColor = UIColor.white

        searchResultController.delegate = self
        searchResultController.searchController = searchController

        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
    }

    func searchResultController(didSelect review:Review) {
        let detailVC:NewsDetailController = NewsDetailController(review: review)
        let nav:WKWebViewNavigationController = WKWebViewNavigationController(rootViewController: detailVC)
        nav.navigationBar.isTranslucent = false
        nav.navigationBar.barTintColor = UIColor.dxoBlue
        nav.navigationBar.tintColor = UIColor.white
        nav.navigationBar.barStyle = .black
        nav.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        nav.navigationBar.shadowImage = UIImage()
        nav.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        if self.presentedViewController != nil {
            self.presentedViewController?.present(nav, animated: true, completion: nil)
        }else{
            self.present(nav, animated: true, completion: nil)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.popViewController(animated: true)
    }

}

