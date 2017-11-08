//
//  NewsDetailController.swift
//  DXOSwift
//
//  Created by ruixingchen on 20/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import SnapKit
import WebKit

class NewsDetailController: RXViewController {

    var webView:WKWebView = WKWebView()

    var review:Review?

    deinit {
        #if DEBUG || debug
            log.verbose("deinit")
        #endif
    }

    init(review:Review){
        super.init(nibName: nil, bundle: nil)
        self.review = review
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = review?.title.abstract(length: 15)
        setupSubviews()

        guard let url:URL = URL(string: review?.targetUrl ?? "") else {
            log.error("news detail catched an error Review: \(review?.description ?? "nil")")
            return
        }
        let request:URLRequest = URLRequest(url: url)
        webView.load(request)
    }

    func setupSubviews(){
        webView.backgroundColor = UIColor.white
        self.view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalToSuperview()
        }

        if let nav:UINavigationController = self.navigationController {
            if nav.viewControllers.first == self {
                //this is the root view controller, means this view is presented by another view controller
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_arrow_back"), style: .plain, target: self, action: #selector(dismissSelf))
            }
        }
    }

    @objc func dismissSelf(){
        if let nav:UINavigationController = self.navigationController {
            if nav.viewControllers.first == self {
                if let wkNav:WKWebViewNavigationController = nav as? WKWebViewNavigationController {
                    wkNav.enableDismiss = true
                }
                nav.dismiss(animated: true, completion: nil)
            }
        }else{
            if self.presentingViewController != nil {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

}
