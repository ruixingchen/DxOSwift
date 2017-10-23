//
//  LensReviewController.swift
//  DXOSwift
//
//  Created by ruixingchen on 20/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class LensReviewController: RXTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Lens Review"
        let tabBarItem:UITabBarItem = UITabBarItem(title: "Lens", image: nil, selectedImage: nil)
        self.tabBarItem = tabBarItem
        self.navigationController?.tabBarItem = tabBarItem
    }

}
