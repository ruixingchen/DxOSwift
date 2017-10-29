//
//  SearchResultNothingFoundView.swift
//  DXOSwift
//
//  Created by ruixingchen on 29/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import SnapKit

class SearchResultNothingFoundView: UIView {

    private let titleLabel:UILabel = UILabel()
    private let messageLabel:UILabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }

    func setupSubviews(){
        titleLabel.textColor = UIColor.lightGray
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.text = LocalizedString.search_nothing_found
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.snp.centerY).offset(-4)
            make.width.lessThanOrEqualToSuperview()
        }

        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont.title
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.text = LocalizedString.search_nothing_found_message
        self.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.snp.centerY).offset(-4)
            make.width.lessThanOrEqualToSuperview()
        }
    }

}
