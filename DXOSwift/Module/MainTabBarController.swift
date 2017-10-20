//
//  MainTabBarController.swift
//  DXOSwift
//
//  Created by ruixingchen on 18/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    init(){
        super.init(nibName: nil, bundle: nil)
        initViewControllers()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViewControllers()
    }

    private func initViewControllers(){
        let newsNav:UINavigationController = UINavigationController(rootViewController: NewsController())
        newsNav.title = "DXO"
        let viewControllers:[UINavigationController] = [newsNav]
        for i in viewControllers {
            i.navigationBar.isTranslucent = false
            i.navigationBar.barTintColor = UIColor.dxoBlue
            i.navigationBar.tintColor = UIColor.white
        }
        self.setViewControllers(viewControllers, animated: false)
    }

}
