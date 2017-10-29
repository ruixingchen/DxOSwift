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
    var priceMax:Double = 0
    var priceMin:Double = 0
    var dxoScoreMax:Int = 0
    var dxoScoreMin:Int = 0
    var dynamicRangeMax:Double = 0
    var dynamicRangeMin:Double = 0
    var LlnMax:Int = 0
    var LlnMin:Int = 0
    var colorMax:Double = 0
    var colorMin:Double = 0

    //    static let shared:CameraManager = CameraManager()

    var testedCamera:[Camera] = []
    var reviewCamera:[Camera] = []

    var dataSource:[Camera] = []
    var sortType:SortType = SortType.overall

    var testedCameraReady:Bool {
        return !testedCamera.isEmpty
    }

    init(){

    }

    func reloadTestedCamera(jsonObject:JSON){
        yearMax = jsonObject["year"]["max"].autoInt ?? yearMax
        yearMin = jsonObject["year"]["min"].autoInt ?? yearMin
        priceMax = jsonObject["price"]["max"].autoDouble ?? priceMax
        priceMin = jsonObject["price"]["min"].autoDouble ?? priceMin
        dxoScoreMax = jsonObject["rankDxo"]["max"].autoInt ?? dxoScoreMax
        dxoScoreMin = jsonObject["rankDxo"]["min"].autoInt ?? dxoScoreMin
        dynamicRangeMax = jsonObject["rankDyn"]["max"].autoDouble ?? dynamicRangeMax
        dynamicRangeMin = jsonObject["rankDyn"]["min"].autoDouble ?? dynamicRangeMin
        LlnMax = jsonObject["rankLln"]["max"].autoInt ?? LlnMax
        LlnMin = jsonObject["rankLln"]["min"].autoInt ?? LlnMin
        colorMax = jsonObject["rankColor"]["max"].autoDouble ?? colorMax
        colorMin = jsonObject["rankColor"]["min"].autoDouble ?? colorMin

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
        #if DEBUG || debug
            let startTime:TimeInterval = Date().timeIntervalSince1970
        #endif
        self.testedCamera = cameraArray.sorted(by: { (p1, p2) -> Bool in
            //sort with big id
            return p1.id > p2.id
        })
        #if DEBUG || debug
            log.verbose("sort all tested camera costs time: \(Date().timeIntervalSince1970 - startTime)")
        #endif
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
