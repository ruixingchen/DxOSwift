//
//  NewsDetailController.swift
//  DXOSwift
//
//  Created by ruixingchen on 20/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import SnapKit

class NewsDetailController: RXViewController {

    let webView:UIWebView = UIWebView()

    var review:Review?

    init(review:Review){
        super.init(nibName: nil, bundle: nil)
        self.review = review
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        self.title = review?.title.abstract(length: 15)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }

    override func firstViewDidAppear(_ animated: Bool) {
        super.firstViewDidAppear(animated)
        guard let url:URL = URL(string: review?.targetUrl ?? "") else {
            log.error("news detail catched an error Review: \(review?.description ?? "nil")")
            return
        }
        let request:URLRequest = URLRequest(url: url)
        webView.loadRequest(request)
    }

    func setupSubviews(){

        self.view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalToSuperview()
        }
    }

}
