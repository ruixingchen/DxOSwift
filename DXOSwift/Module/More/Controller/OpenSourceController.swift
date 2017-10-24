//
//  OpenSourceController.swift
//  DXOSwift
//
//  Created by ruixingchen on 24/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class OpenSourceController: RXTableViewController {

    var sectionTitles:[String] = []
    var rowTitles:NSMutableArray = []

    override func initFunction() {
        super.initFunction()
        self.title = "title_open_source".localized()
    }

    override func initTableView() -> UITableView {
        return UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        sectionTitles.append(Define.section_this_project)
        sectionTitles.append(Define.section_other_project)

        for i in sectionTitles {
            let row:NSMutableArray = []
            if i == Define.section_this_project {
                row.add(Define.row_DXOSwift)
            }else if i == Define.section_other_project {
                row.add(Define.row_XCGLogger)
                row.add(Define.row_SnapKit)
                row.add(Define.row_Kingfisher)
                row.add(Define.row_Toast_Swift)
                //row.add(Define.row_StatefulViewController)
                row.add(Define.row_Kanna)
                //row.add(Define.row_SwiftyJSON)
                row.add(Define.row_GDPerformanceView_Swift)
                //row.add(Define.row_UITableView_FDTemplateLayoutCell)
                //row.add(Define.row_FMDB)
                row.add(Define.row_MJRefresh)
                row.add(Define.row_SDCycleScrollView)
            }
            rowTitles.add(row)
        }
        tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return rowTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (rowTitles[section] as? NSArray)?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionTitle:String = self.sectionTitles.safeGet(at: section) else {
            return nil
        }
        return sectionTitle.localized()
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let sectionTitle:String = self.sectionTitles.safeGet(at: section) else {
            return nil
        }
        var key:String?
        switch sectionTitle {
        case Define.section_this_project:
            key = "your_star_the_best_motivation"
        case Define.section_other_project:
            key = "thanks_open_source_thanks_github"
        default:
            break
        }
        return key?.localized()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        }
        guard let rowTitle:String = (rowTitles.safeGet(at: indexPath.section) as? NSArray)?.safeGet(at: indexPath.row) as? String else {
            cell?.textLabel?.text = nil
            return cell!
        }
        cell?.textLabel?.text = rowTitle.localized()
        cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell!
    }
}

extension OpenSourceController {

    struct Define {
        static let section_this_project:String = "section_this_project"
        static let section_other_project:String = "section_other_project"

        static let row_DXOSwift:String = "row_DXOSwift"
        static let row_XCGLogger:String = "row_XCGLogger"
        static let row_SnapKit:String = "row_SnapKit"
        static let row_Kingfisher:String = "row_Kingfisher"
        static let row_Toast_Swift:String = "row_Toast_Swift"
        static let row_StatefulViewController:String = "row_StatefulViewController"
        static let row_Kanna:String = "row_Kanna"
        static let row_SwiftyJSON:String = "row_SwiftyJSON"
        static let row_GDPerformanceView_Swift:String = "row_GDPerformanceView_Swift"
        static let row_UITableView_FDTemplateLayoutCell:String = "row_UITableView_FDTemplateLayoutCell"
        static let row_FMDB:String = "row_FMDB"
        static let row_MJRefresh:String = "row_MJRefresh"
        static let row_SDCycleScrollView:String = "row_SDCycleScrollView"
    }

}
