//
//  RXViewController.swift
//  SampleProject
//
//  Created by ruixingchen on 18/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class RXViewController: UIViewController {

    /*
     record the time so we can know if the function is called
     */
    var lastViewDidLoad:TimeInterval = 0
    var lastViewWillAppear:TimeInterval = 0
    var lastViewWillLayoutSubviews:TimeInterval = 0
    var lastViewDidLayoutSubviews:TimeInterval = 0
    var lastViewDidAppear:TimeInterval = 0

    /// is this view during rotating transition?
    var isRotating:Bool = false

    //MARK: - Life Cycle

    override func viewDidLoad() {
        if lastViewDidLoad <= 0 {
            firstViewDidLoad()
        }
        lastViewDidLoad = Date().timeIntervalSince1970
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        if lastViewWillAppear <= 0 {
            firstViewWillAppear(animated)
        }
        lastViewWillAppear = Date().timeIntervalSince1970
        super.viewWillAppear(animated)
    }

    override func viewWillLayoutSubviews() {
        if lastViewWillLayoutSubviews <= 0 {
            firstViewWillLayoutSubviews()
        }
        lastViewWillLayoutSubviews = Date().timeIntervalSince1970
        super.viewWillLayoutSubviews()
    }

    override func viewDidLayoutSubviews() {
        if lastViewDidLayoutSubviews <= 0 {
            firstViewDidLayoutSubviews()
        }
        if lastViewDidLayoutSubviews > 0 && isRotating {
            viewDidLayoutSubviewsInTransition()
        }
        lastViewDidLayoutSubviews = Date().timeIntervalSince1970
        super.viewDidLayoutSubviews()
    }

    override func viewDidAppear(_ animated: Bool) {
        if lastViewDidAppear <= 0 {
            firstViewDidAppear(animated)
        }
        lastViewDidAppear = Date().timeIntervalSince1970
        super.viewDidAppear(animated)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        isRotating = true
        coordinator.animateAlongsideTransition(in: nil, animation: nil) { (_) in
            self.isRotating = false
        }
    }

    //MARK: - First

    func firstViewDidLoad(){

    }

    func firstViewWillAppear(_ animated: Bool){

    }

    func firstViewWillLayoutSubviews(){

    }

    func firstViewDidLayoutSubviews(){

    }

    func firstViewDidAppear(_ animated: Bool) {

    }

    func viewDidLayoutSubviewsInTransition() {

    }
}
