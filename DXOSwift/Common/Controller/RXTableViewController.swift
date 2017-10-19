//
//  RXTableViewController.swift
//  SampleProject
//
//  Created by ruixingchen on 18/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import SnapKit

class RXTableViewController: RXViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK: - Property

    var tableView:UITableView!

    init() {
        super.init(nibName: nil, bundle: nil)
        tableView = initTableView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tableView = initTableView()
    }

    /// use a function to init tableview, override it if you want to use a custom tableview
    func initTableView()->UITableView {
        let tableView:UITableView = UITableView(frame: CGRect.zero, style: .plain)
        return tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    //MARK: - Setup

    /// the tableview is setted before and separated from other subviews
    func setupTableView(){
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        tableView.snp.makeConstraints { (make) in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
