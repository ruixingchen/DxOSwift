//
//  DeviceDetailScoreTableViewCell.swift
//  DXOSwift
//
//  Created by ruixingchen on 30/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import SnapKit

class DeviceDetailScoreTableViewCell: RXTableViewCell {

    let leftLabel:UILabel = UILabel()
    private let progressBackggroundView:UnclearView = UnclearView()
    private let progressColorView:UnclearView = UnclearView()
    let rightLabel:UILabel = UILabel()

    override func setupSubviews() {

        leftLabel.numberOfLines = 2
        leftLabel.minimumScaleFactor = 0.8
        leftLabel.adjustsFontSizeToFitWidth = true
        self.contentView.addSubview(leftLabel)
        leftLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.height.equalTo(40)
            make.right.equalTo(self.contentView.snp.centerX)
        }

        progressBackggroundView.backgroundColor = UIColor.white
        progressBackggroundView.layer.borderWidth = 0.5
        progressBackggroundView.layer.borderColor = UIColor(red:121.0/255.0,green:121.0/255.0,blue:121.0/255.0,alpha:255.0/255.0).cgColor
        self.contentView.addSubview(progressBackggroundView)
        progressBackggroundView.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp.centerX)
            make.centerY.equalToSuperview()
            make.height.equalTo(10)
            make.width.equalTo(80)
        }

        progressColorView.backgroundColor = UIColor(red:99.0/255.0,green:121.0/255.0,blue:182.0/255.0,alpha:255.0/255.0)
        progressBackggroundView.addSubview(progressColorView)

        rightLabel.adjustsFontSizeToFitWidth = true
        rightLabel.minimumScaleFactor = 0.7
        rightLabel.textAlignment = .left
        self.contentView.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { (make) in
            make.left.equalTo(progressBackggroundView.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualToSuperview().offset(-10)
        }
    }

    func updateProgress(progress:Float){
        var p:Float = progress
        if p > 1 {
            p = 1
        }else if p < 0 {
            p = 0
        }
        progressColorView.snp.remakeConstraints { (make) in
            make.left.equalToSuperview().offset(0.5)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-0.5)
            make.width.equalToSuperview().multipliedBy(p)
        }
    }

}
