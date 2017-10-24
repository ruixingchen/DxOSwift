//
//  NewsDetailController.swift
//  DXOSwift
//
//  Created by ruixingchen on 20/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import SnapKit

class NewsDetailController: RXViewController, UIWebViewDelegate {

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
        self.title = review?.title.abstract(length: 15)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        setupSubviews()

        guard let url:URL = URL(string: review?.targetUrl ?? "") else {
            log.error("news detail catched an error Review: \(review?.description ?? "nil")")
            return
        }
        let request:URLRequest = URLRequest(url: url)
        webView.loadRequest(request)
    }

    func setupSubviews(){
        webView.delegate = self
        self.view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalToSuperview()
        }
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        log.debug("webViewDidStartLoad")
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        log.debug("webViewDidFinishLoad")
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        log.debug("didFailLoadWithError")
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        log.debug("shouldStartLoadWith: \(request)")
        return true
    }
}
