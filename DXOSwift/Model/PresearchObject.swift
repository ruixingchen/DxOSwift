//
//  PresearchObject.swift
//  DXOSwift
//
//  Created by ruixingchen on 28/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation
import SwiftyJSON

class PresearchObject {

    var id : Int!
    var img : String!
    var price : String!
    var type : String!
    var url : String!
    var value : String!

    init?(fromJson json: JSON){
        if json.isEmpty{
            return
        }
        id = json["id"].intValue
        if id == -1 {
            log.debug("PresearchObject init failed, \nid:-1, \ntype:\(json["type"].stringValue), \nurl:\(json["url"].stringValue)")
            return nil
        }
        img = json["img"].stringValue
        price = json["price"].stringValue
        type = json["type"].stringValue
        url = json["url"].stringValue
        value = json["value"].stringValue
    }

}
