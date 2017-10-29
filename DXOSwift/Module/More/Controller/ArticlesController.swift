//
//  ArticlesController.swift
//  DXOSwift
//
//  Created by ruixingchen on 23/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class ArticlesController: GenericReviewListController {

    override func initFunction() {
        super.initFunction()
        self.title = LocalizedString.title_articles
    }

    override func installFooterRefreshControl(userInfo: UserInfo?) {
        return
    }

    override func headerRefresh() {
        DXOService.articles {[weak self] (inObject, inError) in
            if self == nil {
                return
            }
            self?.headerRefreshHandle(inObject: inObject, inError: inError)
        }
    }

}
