//
//  SearchPresearchTableViewCell.swift
//  DXOSwift
//
//  Created by ruixingchen on 28/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import SnapKit

class SearchPresearchTableViewCell: RXTableViewCell {

    let coverImageView:UIImageView = UIImageView()
    let titleLabel:UILabel = UILabel()

    override func setupSubviews() {
        coverImageView.clipsToBounds = true
        coverImageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(64)
            make.width.equalTo(64)
        }
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coverImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(coverImageView)
            make.bottom.equalTo(coverImageView)
        }
    }

    func updateContent(presearch:PresearchObject){
        if presearch.img?.isEmpty ?? true {
            coverImageView.image = nil
        }else{
            coverImageView.kf.setImage(with: URL(string: presearch.img))
        }
        titleLabel.text = presearch.value
    }

}
