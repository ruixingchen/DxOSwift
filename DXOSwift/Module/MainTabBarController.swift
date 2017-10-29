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
        newsNav.tabBarItem = UITabBarItem(title: LocalizedString.title_dxo, image: nil, selectedImage: nil)
        viewControllers.append(newsNav)

        let cameraNav:UINavigationController = UINavigationController(rootViewController: CameraReviewController())
        cameraNav.tabBarItem = UITabBarItem(title: LocalizedString.title_camera, image: nil, selectedImage: nil)
        viewControllers.append(cameraNav)

        let lensNav:UINavigationController = UINavigationController(rootViewController: LensReviewController())
        lensNav.tabBarItem = UITabBarItem(title: LocalizedString.title_lens, image: nil, selectedImage: nil)
        viewControllers.append(lensNav)

        let moreNav:UINavigationController = UINavigationController(rootViewController: MoreController())
        moreNav.tabBarItem = UITabBarItem(title: LocalizedString.title_more, image: nil, selectedImage: nil)
        viewControllers.append(moreNav)

        for i in viewControllers {
            i.navigationBar.isTranslucent = false
            i.navigationBar.barTintColor = UIColor.dxoBlue
            i.navigationBar.tintColor = UIColor.white
            i.navigationBar.barStyle = .black
            i.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        }
        self.setViewControllers(viewControllers, animated: false)
    }

}
