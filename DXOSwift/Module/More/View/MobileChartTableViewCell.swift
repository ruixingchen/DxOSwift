//
//  MobileChartTableViewCell.swift
//  DXOSwift
//
//  Created by ruixingchen on 23/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import SnapKit

class MobileChartTableViewCell: RXTableViewCell {

    let backgroundColorView:UIView = UIView()
    let scoreLabel:UILabel = UILabel()
    let deviceNameLabel:UILabel = UILabel()

    var backgroundColorViewConstraint:Constraint!

    init(reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setupSubviews() {
        super.setupSubviews()
        self.separatorInset = UIEdgeInsetsMake(0, 99999, 0, 0)
        self.selectionStyle = .none

        backgroundColorView.backgroundColor = UIColor(red: 125.0/255.0, green: 209.0/255.0, blue: 240.0/255.0, alpha: 0.25)
        self.contentView.addSubview(backgroundColorView)

        scoreLabel.numberOfLines = 1
        scoreLabel.textAlignment = NSTextAlignment.left
        self.contentView.addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(32)
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
        }
        deviceNameLabel.numberOfLines = 1
        deviceNameLabel.textAlignment = NSTextAlignment.left
        self.contentView.addSubview(deviceNameLabel)
        deviceNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(scoreLabel.snp.right)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
        }
    }

    func updateContent(review:Review){
        scoreLabel.text = String.init(describing: review.score)
        deviceNameLabel.text = review.title
        let progress:CGFloat = CGFloat(review.score)/100
        backgroundColorView.snp.remakeConstraints { (make) in
            make.left.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.8)
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(progress)
        }
    }

}
