//
//  Review.swift
//  DXOSwift
//
//  Created by ruixingchen on 17/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation

enum ReviewDeviceType:Int {
    case senser = 1
    case lens = 2
    case mobile = 3
}

class Review {

    var title:String
    var targetUrl:String
    var postTime:String?
    var abstract:String?
    var coverImage:String?
    var commentNum:Int = 0
    var deviceType:ReviewDeviceType?
    var score:Int = 0
    var category:[String] = []
    var tag:[String] = []

    init(title:String, url:String) {
        self.title = title
        self.targetUrl = url
    }

    var description:String {
        var str:String = ""
        str.append("title:\(title.abstract())\n")
        str.append("target url:\(targetUrl)\n")
        str.append("post time: \(postTime ?? "nil")\n")
        str.append("abstract:\(abstract?.abstract() ?? "nil")\n")
        str.append("coverImage:\(coverImage ?? "nil")\n")
        str.append("category:\(category)\n")
        str.append("commentNum:\(commentNum)\n")
        if deviceType == nil {
            str.append("deviceType: nil\n")
        }else{
            str.append("deviceType:\(deviceType!)\n")
        }
        str.append("score:\(score)")
        return str
    }

}
