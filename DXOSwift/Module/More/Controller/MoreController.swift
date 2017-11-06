//
//  MoreController.swift
//  DXOSwift
//
//  Created by ruixingchen on 22/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class MoreController: RXTableViewController {

    var sectionTitles:[String] = []
    var rowTitles:NSMutableArray = NSMutableArray()

    override func initFunction() {
        super.initFunction()
        self.title = LocalizedString.title_more
        setupDataSource()
    }

    override func initTableView() -> UITableView {
        let tableView:UITableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
        return tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func setupDataSource(){
        var sectionTitles:[String] = []
        let rowTitles:NSMutableArray = NSMutableArray()

        sectionTitles.append(Define.section_mobile)
        sectionTitles.append(Define.section_articles)
        //sectionTitles.append(Define.section_about)
        sectionTitles.append(Define.section_open_source)
        sectionTitles.append(Define.section_setting)
        #if DEBUG || debug
            sectionTitles.append(Define.section_debug)
        #endif

        for i in sectionTitles {
            let rows:NSMutableArray = NSMutableArray()
            if i == Define.section_mobile {
                rows.add(Define.row_mobile_review)
                rows.add(Define.row_mobile_rank)
            }else if i == Define.section_articles {
                rows.add(Define.row_articles)
            }else if i == Define.section_about {
                rows.add(Define.row_about)
                rows.add(Define.row_about_dxo)
            }else if i == Define.section_setting {
                rows.add(Define.row_setting)
            }else if i == Define.section_open_source {
                rows.add(Define.row_open_source)
            }else{
                #if DEBUG || debug
                    if i == Define.section_debug {
                        rows.add(Define.row_test)
                    }
                #endif
            }

            rowTitles.add(rows)
        }
        self.sectionTitles = sectionTitles
        self.rowTitles = rowTitles
    }

    override func setupTableView() {
        super.setupTableView()
        tableView.tableFooterView = MoreFooterView(frame: CGRect(x: 0, y: 0, width: 300, height: 45))
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.rowTitles.safeGet(at: section) as? NSArray)?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let rowTitle:String = (self.rowTitles[indexPath.section] as! NSArray)[indexPath.row] as! String
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = rowTitle.localized()
        cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let rowTitle:String = (self.rowTitles[indexPath.section] as! NSArray)[indexPath.row] as! String

        var nextViewController:UIViewController?

        switch rowTitle {
        case Define.row_mobile_review:
            nextViewController = MobileReviewController()
        case Define.row_mobile_rank:
            nextViewController = MobileChartController()
        case Define.row_articles:
            nextViewController = ArticlesController()
        case Define.row_open_source:
            nextViewController = OpenSourceController()
        case Define.row_setting:
            nextViewController = SettingsController()
        case Define.row_test:
        #if DEBUG || debug
            nextViewController = TestController()
        #else
            break
        #endif
        default:
            break
        }

        if nextViewController != nil {
            nextViewController?.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(nextViewController!, animated: true)
        }
    }

}

extension MoreController {
    struct Define {
        static let section_mobile:String = "section_mobile"
        static let row_mobile_review:String = "title_mobile_review"
        static let row_mobile_rank:String = "title_mobile_chart"

        static let section_articles:String = "section_articles"
        static let row_articles:String = "title_articles"

        static let section_about:String = "section_about"
        static let row_about:String = "title_about"
        static let row_about_dxo:String = "title_about_dxo"

        static let section_open_source:String = "section_open_source"
        static let row_open_source:String = "title_open_source"

        static let section_setting:String = "section_settings"
        static let row_setting:String = "title_settings"

        static let section_debug:String = "section_debug"
        static let row_test:String = "title_test"
    }
}
