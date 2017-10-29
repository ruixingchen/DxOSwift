//
//  MobileChartController.swift
//  DXOSwift
//
//  Created by ruixingchen on 23/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class MobileChartController: GenericReviewListController {

    override func initFunction() {
        super.initFunction()
        self.title = LocalizedString.title_mobile_chart
    }

    override func setupTableView() {
        super.setupTableView()
        tableView.rowHeight = 80
    }

    override func installFooterRefreshControl(userInfo: UserInfo? = nil) {
        //don't need install footer refresh
        return
    }

    override func headerRefresh() {
        DXOService.mobileChart {[weak self] (inObject, inError) in
            if self == nil {
                return
            }
            self?.headerRefreshHandle(inObject: inObject, inError: inError)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let review:Review = dataSource.safeGet(at: indexPath.row) as? Review else {
            let cell = RXBlankTableViewCell(reuseIdentifier: String.init(describing: RXBlankTableViewCell.self))
            #if DEBUG || debug
                cell.infoLabel.text = "ERROR - can not get review object from dataSource"
            #endif
            return cell
        }
        var cell:MobileChartTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell") as? MobileChartTableViewCell
        if cell == nil {
            cell = MobileChartTableViewCell(reuseIdentifier: "cell")
        }
        cell?.updateContent(review: review)
        return cell!
    }

}
