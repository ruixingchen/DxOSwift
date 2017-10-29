//
//  DeviceDatabaseTableViewCell.swift
//  DXOSwift
//
//  Created by ruixingchen on 20/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import SnapKit

class DeviceDatabaseTableViewCell: RXTableViewCell {

    let backgroundProgressView:UIView = UIView()
    let scoreLabel:UILabel = UILabel()
    let coverImageView:UIImageView = UIImageView()
    let titleLabel:UILabel = UILabel()
    let detailLabel:UILabel = UILabel()

    override func setupSubviews() {
        super.setupSubviews()

        self.separatorInset = UIEdgeInsetsMake(0, 2000, 0, 0)

        backgroundProgressView.backgroundColor = UIColor(red: 125.0/255.0, green: 209.0/255.0, blue: 240.0/255.0, alpha: 0.25)
        self.contentView.addSubview(backgroundProgressView)

        scoreLabel.textAlignment = .center
        scoreLabel.minimumScaleFactor = 0.5
        scoreLabel.adjustsFontSizeToFitWidth = true
        self.contentView.addSubview(scoreLabel)

        coverImageView.contentMode = .scaleAspectFit
        coverImageView.clipsToBounds = true
        self.contentView.addSubview(coverImageView)

        titleLabel.font = UIFont.title
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 2
        self.contentView.addSubview(titleLabel)

        detailLabel.font = UIFont.message
        detailLabel.textAlignment = .left
        detailLabel.textColor = UIColor.gray
        self.contentView.addSubview(detailLabel)

        scoreLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
        }

        coverImageView.snp.makeConstraints { (make) in
            make.left.equalTo(scoreLabel.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().offset(-16)
            make.width.equalTo(coverImageView.snp.height).multipliedBy(1.5)
        }

        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coverImageView.snp.right).offset(8)
            make.top.equalTo(coverImageView)
            make.right.equalToSuperview().offset(-16)
        }

        detailLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.bottom.equalTo(coverImageView)
            make.right.equalTo(titleLabel)
        }

    }

}

