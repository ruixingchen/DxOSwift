//
//  DeviceDetailSpecificationsTableViewCell.swift
//  DXOSwift
//
//  Created by ruixingchen on 30/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class DeviceDetailSpecificationsTableViewCell: RXTableViewCell {

    let leftLabel:UILabel = UILabel()
    let rightLabel:UILabel = UILabel()

    override func setupSubviews() {
        super.setupSubviews()
        leftLabel.numberOfLines = 0
        self.contentView.addSubview(leftLabel)
        leftLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.height.greaterThanOrEqualTo(40)
            make.right.lessThanOrEqualTo(self.contentView.snp.centerX)
        }

        rightLabel.numberOfLines = 0
        rightLabel.textColor = UIColor.gray
        self.contentView.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp.centerX)
            make.centerY.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.right.lessThanOrEqualToSuperview().offset(-10)
        }
    }

}
