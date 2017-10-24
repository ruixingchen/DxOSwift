//
//  OpenSourceController.swift
//  DXOSwift
//
//  Created by ruixingchen on 24/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class OpenSourceController: RXTableViewController {

    override init() {
        super.init()
        self.title = "title_open_source".localized()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = "title_open_source".localized()
    }

}
