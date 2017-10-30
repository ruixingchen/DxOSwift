//
//  LensDatabaseDataSource.swift
//  DXOSwift
//
//  Created by ruixingchen on 29/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation
import SwiftyJSON

class LensDatabaseDataSource {

    var testedLens:[Lens] = []
    var previewLens:[Lens] = []

    var dataSource:[Lens] = []
    var sortType:SortType = SortType.score

    var isTestedLensReady:Bool {
        return !testedLens.isEmpty
    }

    var isReviewLensReady:Bool {
        return !previewLens.isEmpty
    }

    var priceMax:Float = 1
    var priceMin:Float = 1
    var priceSenserMax:Float = 1
    var priceSenserMin:Float = 1
    var yearMax:Int = 1
    var yearMin:Int = 1
    var globalMax:Float = 1 //dxo评分
    var globalMin:Float = 1
    var effmpixMax:Float = 1 //锐度
    var effmpixMin:Float = 1
    var distorsionMax:Float = 1 //畸变
    var distorsionMin:Float = 1
    var vignettingMax:Float = 1 //暗角
    var vignettingMin:Float = 1
    var tstopMax:Float = 1 //T值, 曝光级数
    var tstopMin:Float = 1
    var acMax:Float = 1 //色差(紫边)
    var acMin:Float = 1

    func reloadTested(json:JSON){
        priceMax = json["price"]["max"].floatValue
        priceMin = json["price"]["min"].floatValue
        priceSenserMax = json["priceSensor"]["max"].floatValue
        priceSenserMin = json["priceSensor"]["min"].floatValue
        yearMax = json["year"]["max"].intValue
        yearMin = json["year"]["min"].intValue
        globalMax = json["global"]["max"].floatValue
        globalMin = json["global"]["min"].floatValue
        effmpixMax = json["effmpix"]["max"].floatValue
        effmpixMin = json["effmpix"]["min"].floatValue
        distorsionMax = json["distorsion"]["max"].floatValue
        distorsionMin = json["distorsion"]["min"].floatValue
        vignettingMax = json["vignetting"]["max"].floatValue
        vignettingMin = json["vignetting"]["min"].floatValue
        tstopMax = json["tstop"]["max"].floatValue
        tstopMin = json["tstop"]["min"].floatValue
        acMax = json["ac"]["max"].floatValue
        acMin = json["ac"]["min"].floatValue

        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        var lensArray:[Lens] = []
        for lensJson in json["data"].arrayValue {
            guard let lens:Lens = Lens(fromJson: lensJson) else {
                continue
            }
            lens.c_launchTime = formatter.date(from: lens.launchDateGraph)?.timeIntervalSince1970 ?? 0
            lensArray.append(lens)
        }
        self.testedLens = lensArray
        sort(sortType: sortType)
    }

    func sort(sortType:SortType) {
        self.dataSource = self.testedLens.sorted(by: { (p1, p2) -> Bool in
            switch sortType {
            case .score:
                return p1.globalRanking < p2.globalRanking
            case .sharpness:
                return p1.effmpixRanking < p2.effmpixRanking
            case .distortion:
                return p1.distorsionRanking < p2.distorsionRanking
            case .vignetting:
                return p1.vignettingRanking < p2.vignettingRanking
            case .transmission:
                return p1.tstopRanking < p2.tstopRanking
            case .aberration:
                return p1.acRanking < p2.acRanking
            }
        })
        self.sortType = sortType
    }

}

extension LensDatabaseDataSource {
    enum SortType {
        case score, sharpness, distortion, vignetting, transmission, aberration
    }
}
