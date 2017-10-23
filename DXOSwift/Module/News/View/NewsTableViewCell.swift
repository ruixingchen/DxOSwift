//
//  NewsTableViewCell.swift
//  DXOSwift
//
//  Created by ruixingchen on 19/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import Kingfisher

class NewsTableViewCell: RXTableViewCell {

    let coverImageView:UIImageView = UIImageView()
    let titleLabel:UILabel = UILabel()
    let abstractLabel:UILabel = UILabel()
    var badgeView:ReviewBadgeView?

    init(reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }

    override func setupSubviews() {
        super.setupSubviews()
        coverImageView.clipsToBounds = true
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.backgroundColor = nil
        self.contentView.addSubview(coverImageView)
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 2
        self.contentView.addSubview(titleLabel)
        abstractLabel.font = UIFont.systemFont(ofSize: 14)
        abstractLabel.textColor = UIColor.gray
        abstractLabel.textAlignment = .left
        abstractLabel.numberOfLines = 2
        self.contentView.addSubview(abstractLabel)

        setupAutoLayout()
    }

    private func setupAutoLayout(){
        coverImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(8)
            make.height.equalToSuperview().offset(-32)
            make.width.equalTo(self.coverImageView.snp.height).multipliedBy(1.5)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coverImageView.snp.right).offset(8)
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
        }
        abstractLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(0)
            make.bottom.equalToSuperview().offset(-4)
        }
    }

    func updateContent(review:Review) {
        titleLabel.text = review.title
        abstractLabel.text = review.abstract
        if let urlString = review.coverImage, let url = URL(string: urlString) {
            coverImageView.kf.setImage(with: url)
        }else{
            coverImageView.image = nil
        }
    }

}
