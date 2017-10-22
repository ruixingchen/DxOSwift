//
//  MoreController.swift
//  DXOSwift
//
//  Created by ruixingchen on 22/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class MoreController: RXTableViewController {

    override func initTableView() -> UITableView {
        let tableView:UITableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
        return tableView
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

}
