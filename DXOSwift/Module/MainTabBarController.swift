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
        var viewControllers:[UINavigationController] = []

        let newsNav:UINavigationController = UINavigationController(rootViewController: NewsController())
        newsNav.title = "DXO"
        viewControllers.append(newsNav)

        let cameraNav:UINavigationController = UINavigationController(rootViewController: CameraReviewController())
        cameraNav.title = "Camera"
        viewControllers.append(cameraNav)

        let lensNav:UINavigationController = UINavigationController(rootViewController: LensReviewController())
        lensNav.title = "Lens"
        viewControllers.append(lensNav)

        let moreNav:UINavigationController = UINavigationController(rootViewController: MoreController())
        moreNav.title = "More"
        viewControllers.append(moreNav)

        for i in viewControllers {
            i.navigationBar.isTranslucent = false
            i.navigationBar.barTintColor = UIColor.dxoBlue
            i.navigationBar.tintColor = UIColor.white
            i.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        }
        self.setViewControllers(viewControllers, animated: false)
    }

}
