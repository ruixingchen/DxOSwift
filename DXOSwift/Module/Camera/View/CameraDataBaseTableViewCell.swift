//
//  CameraDataBaseTableViewCell.swift
//  DXOSwift
//
//  Created by ruixingchen on 20/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import SnapKit

class CameraDataBaseTableViewCell: RXTableViewCell {

    let backgroundProgressView:UIView = UIView()
    let rankLabel:UILabel = UILabel()
    let coverImageView:UIImageView = UIImageView()
    let titleLabel:UILabel = UILabel()
    let scoreLabel:UILabel = UILabel()

    override func setupSubviews() {
        super.setupSubviews()
        self.contentView.addSubview(backgroundProgressView)
        backgroundProgressView.backgroundColor = UIColor.gray
        backgroundProgressView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.height.equalToSuperview().offset(-2)
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1)
        }
        self.contentView.addSubview(rankLabel)
        rankLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
        }
        coverImageView.contentMode = .scaleAspectFit
        coverImageView.clipsToBounds = true
        self.contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { (make) in
            make.left.equalTo(rankLabel.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().offset(-32)
            make.width.equalTo(coverImageView.snp.height).multipliedBy(2)
        }

    }


}

