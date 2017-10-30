//
//  CameraDatabaseDataSource.swift
//  DXOSwift
//
//  Created by ruixingchen on 29/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation
import SwiftyJSON

class CameraDatabaseDataSource {

    enum SortType {
        case overall, portrait, landscape, sports
    }

    var yearMax:Int = 0
    var yearMin:Int = 0
    var priceMax:Float = 0
    var priceMin:Float = 0
    var dxoScoreMax:Int = 0
    var dxoScoreMin:Int = 0
    var dynamicRangeMax:Float = 0
    var dynamicRangeMin:Float = 0
    var LlnMax:Int = 0
    var LlnMin:Int = 0
    var colorMax:Float = 0
    var colorMin:Float = 0

    var testedCamera:[Camera] = []
    var previewCamera:[Camera] = []

    var dataSource:[Camera] = []
    var sortType:SortType = SortType.overall

    var testedCameraReady:Bool {
        return !testedCamera.isEmpty
    }

    var previewCameraReady: Bool {
        return !previewCamera.isEmpty
    }

    init(){

    }

    func reloadTestedCamera(jsonObject:JSON){
        yearMax = jsonObject["year"]["max"].autoInt ?? yearMax
        yearMin = jsonObject["year"]["min"].autoInt ?? yearMin
        priceMax = jsonObject["price"]["max"].autoFloat ?? priceMax
        priceMin = jsonObject["price"]["min"].autoFloat ?? priceMin
        dxoScoreMax = jsonObject["rankDxo"]["max"].autoInt ?? dxoScoreMax
        dxoScoreMin = jsonObject["rankDxo"]["min"].autoInt ?? dxoScoreMin
        dynamicRangeMax = jsonObject["rankDyn"]["max"].autoFloat ?? dynamicRangeMax
        dynamicRangeMin = jsonObject["rankDyn"]["min"].autoFloat ?? dynamicRangeMin
        LlnMax = jsonObject["rankLln"]["max"].autoInt ?? LlnMax
        LlnMin = jsonObject["rankLln"]["min"].autoInt ?? LlnMin
        colorMax = jsonObject["rankColor"]["max"].autoFloat ?? colorMax
        colorMin = jsonObject["rankColor"]["min"].autoFloat ?? colorMin

        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        var cameraArray:[Camera] = []
        for cameraJson in jsonObject["data"].arrayValue {
            guard let camera:Camera = Camera(fromJson: cameraJson) else {
                continue
            }
            camera.c_launchTime = formatter.date(from: camera.launchDateGraph)?.timeIntervalSince1970 ?? 0
            cameraArray.append(camera)
        }
        self.testedCamera = cameraArray
        sort(sortType: sortType)
    }

    func sort(sortType:SortType) {
        self.dataSource = self.testedCamera.sorted(by: { (p1, p2) -> Bool in
            switch sortType {
            case .overall:
                return p1.rankDxoRanking < p2.rankDxoRanking
            case .portrait:
                return p1.rankColorRanking < p2.rankColorRanking
            case .landscape:
                return p1.rankDynRanking < p2.rankDynRanking
            case .sports:
                return p1.rankLlnRanking < p2.rankLlnRanking
            }
        })
        self.sortType = sortType
    }

}
