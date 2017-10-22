//
//  CameraManager.swift
//  DXOSwift
//
//  Created by ruixingchen on 20/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation
import SwiftyJSON

/// manage the camera data base, may use sql to store the data, but for now time we only store it in ram
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

    var testedCamera:[Camera] = []
    var reviewCamera:[Camera] = []

    var testedCameraReady:Bool {
        return testedCamera.count != 0
    }

    private init(){}

    func reloadTestedCamera(jsonObject:JSON){
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

        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        var cameraArray:[Camera] = []
        for cameraJson in jsonObject["data"].arrayValue {
            let camera:Camera = Camera(fromJson: cameraJson)
            camera.launchTime = formatter.date(from: camera.launchDateGraph)?.timeIntervalSince1970 ?? 0
            cameraArray.append(camera)
        }
        log.verbose("test camera ")
        self.testedCamera = cameraArray.sorted(by: { (p1, p2) -> Bool in
            return p1.launchTime > p2.launchTime
        })
    }

}

extension CameraManager {
    
}
