//
//  CameraDataBaseController.swift
//  DXOSwift
//
//  Created by ruixingchen on 20/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class CameraDataBaseController: RXTableViewController {

    override func firstViewWillAppear(_ animated: Bool) {
        super.firstViewWillAppear(animated)
        DXOService.cameraDataBase { (inError) in
            
        }
    }

    override func firstViewDidAppear(_ animated: Bool) {
        super.firstViewDidAppear(animated)

    }

}
