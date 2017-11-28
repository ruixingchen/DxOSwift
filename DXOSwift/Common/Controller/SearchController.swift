//
//  SearchController.swift
//  DXOSwift
//
//  Created by ruixingchen on 27/11/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class SearchController: UISearchController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

}
