//
//  LoadingView.swift
//  DXOSwift
//
//  Created by ruixingchen on 29/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import SnapKit

class LoadingView: UIView {

    let indicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let messageLabel:UILabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }

    func setupSubviews(){
        indicator.startAnimating()
        self.addSubview(indicator)
        indicator.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        messageLabel.textColor = UIColor.lightGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.text = LocalizedString.title_loading
        self.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(indicator.snp.bottom).offset(8)
        }
    }

}
