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

    }

    func searchResultController(didSelect presearch:PresearchObject) {

    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.popViewController(animated: true)
    }

}

