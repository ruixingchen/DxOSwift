//
//  CameraManager.swift
//  DXOSwift
//
//  Created by ruixingchen on 20/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation
import SwiftyJSON

/// manage the camera data base, use SQLite with FMDB, the data will be stored in sql
class CameraManager {

    var yearMax:Int = 0
    var yearMin:Int = 0
    var priceMax:Double = 0
    var priceMin:Double = 0
    var dxoScoreMax:Int = 0
    var dxoScoreMin:Int = 0
    var dynamicRangeMax:Double = 0
    var dynamicRangeMin:Double = 0
    var LlnMax:Int = 0
    var LlnMin:Int = 0
    var colorMax:Int = 0
    var colorMin:Int = 0

    static let shared:CameraManager = CameraManager()

    private init(){}

    /// reload all the data base, rewrite the DB if there is right data, or do nothing
    func reloadDataBase(jsonObject:JSON){
        yearMax = jsonObject["year"]["max"].int ?? yearMax
        yearMin = jsonObject["year"]["min"].int ?? yearMin
        priceMax = jsonObject["price"]["max"].double ?? priceMax
        priceMin = jsonObject["price"]["min"].double ?? priceMin
        dxoScoreMax = jsonObject["rankDxo"]["max"].int ?? dxoScoreMax
        dxoScoreMin = jsonObject["rankDxo"]["min"].int ?? dxoScoreMin
        dynamicRangeMax = jsonObject["rankDyn"]["max"].double ?? dynamicRangeMax
        dynamicRangeMin = jsonObject["rankDyn"]["min"].double ?? dynamicRangeMin
        LlnMax = jsonObject["rankLln"]["max"].int ?? LlnMax
        LlnMin = jsonObject["rankLln"]["min"].int ?? LlnMin
        colorMax = jsonObject["rankColor"]["max"].int ?? colorMax
        colorMin = jsonObject["rankColor"]["min"].int ?? colorMin

        var array:[String] = []


        for cameraJson in jsonObject["data"].arrayValue {
            let content = cameraJson["status"].string?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if content == nil {
                print("nil")
            }
            if !array.contains(content!) {
                array.append(content!)
            }
        }
        print(array)

    }

}
