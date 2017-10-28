//
//  SearchResultController.swift
//  DXOSwift
//
//  Created by ruixingchen on 28/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

protocol SearchResultControllerDelegate: class {
    func searchResultController(didSelect review:Review)
    func searchResultController(didSelect presearch:PresearchObject)
}

class SearchResultController: RXTableViewController {

    var presearchDataSource:[PresearchObject] = []
    var searchDataSource:[Review] = []

    var shouldShowPresearch:Bool = false

    weak var delegate:SearchResultControllerDelegate?
    weak var searchController:UISearchController!

    override func setupTableView() {
        super.setupTableView()
        tableView.tableFooterView = UIView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.isHidden = false
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows:Int!
        if shouldShowPresearch {
            rows = presearchDataSource.count
        }else {
            rows = searchDataSource.count
        }
        return rows ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        if shouldShowPresearch {
            guard let presearchObject:PresearchObject = self.presearchDataSource.safeGet(at: indexPath.row) else {
                let cell:RXBlankTableViewCell = RXBlankTableViewCell(reuseIdentifier: nil)
                #if DEBUG || debug
                    cell.infoLabel.text = "can not get presearchObject"
                #endif
                return cell
            }
            var presearchCell:SearchPresearchTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "presearchCell") as? SearchPresearchTableViewCell
            if presearchCell == nil {
                presearchCell = SearchPresearchTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "presearchCell")
            }
            presearchCell?.updateContent(presearch: presearchObject)
            cell = presearchCell
        }else {
            
        }
        if cell == nil {
            cell = UITableViewCell()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if shouldShowPresearch {
            self.delegate?.searchResultController(didSelect: presearchDataSource[indexPath.row])
        }else{
            self.delegate?.searchResultController(didSelect: searchDataSource[indexPath.row])
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            searchController.searchBar.resignFirstResponder()
        }
    }

}
