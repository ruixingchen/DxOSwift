//
//  CameraManager.swift
//  DXOSwift
//
//  Created by ruixingchen on 20/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation
import SwiftyJSON
import FMDB

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

    private let tableName:String = "cameraDataBase"

    static let shared:CameraManager = CameraManager()

    private init(){
        //create Table
        do {
            let createTableString:String = """
CREATE TABLE "\(tableName)" (
    "id" text PRIMARY KEY,
    "price" text,
    "year" TEXT,
    "brand" TEXT,
    "rankDxo" TEXT,
    "rankColor" TEXT,
    "rankDyn" TEXT,
    "rankLln" TEXT,
    "rankDxo_ranking" TEXT,
    "rankColor_ranking" TEXT,
    "rankDyn_ranking" TEXT,
    "rankLln_ranking" TEXT,
    "name" TEXT,
    "pixelDepth" TEXT,
    "sensor" TEXT,
    "type" TEXT,
    "status" TEXT,
    "launchDate" TEXT,
    "launchDateGraph" TEXT,
    "sensorraw" TEXT,
    "link" TEXT,
    "chapo" TEXT,
    "linkReview" TEXT,
    "maximum_iso" TEXT,
    "raw_format" TEXT,
    "autofocus" TEXT,
    "resolutionvideo" TEXT,
    "flash" TEXT,
    "video" TEXT,
    "waterproof" TEXT,
"image" TEXT
);
"""
            try DataBaseManager.shared.mainDB.executeUpdate(createTableString, values: [])
        }catch {
            log.error("create camera table failed, error: \(error)")
        }
    }

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

        var cameraArray:[Camera] = []
        for cameraJson in jsonObject["data"].arrayValue {
            cameraArray.append(Camera(fromJson: cameraJson))
        }

        //reload sql
        let queue = FMDatabaseQueue(path: DataBaseManager.shared.dbPath)
        queue.inTransaction { (db, rollback) in
            do {
                try db.executeUpdate("DELETE FROM \(tableName)", values: [])
                let insertString:String = """
                INSERT INTO \(tableName) (
                id,
                price,
                year,
                brand,
                rankDxo,
                rankColor,
                rankDyn,
                rankLln,
                rankDxo_ranking,
                rankColor_ranking,
                rankDyn_ranking,
                rankLln_ranking,
                name,
                pixelDepth,
                sensor,
                type,
                status,
                launchDate,
                launchDateGraph,
                sensorraw,
                link,
                chapo,
                linkReview,
                maximum_iso,
                raw_format,
                autofocus,
                resolutionvideo,
                flash,
                video,
                waterproof,
                image
                )
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);
                """
                for camera in cameraArray {
                    try db.executeUpdate(insertString, values: [
                        camera.id,
                        camera.price,
                        camera.year,
                        camera.brand,
                        camera.rankDxo,
                        camera.rankColor,
                        camera.rankDyn,
                        camera.rankLln,
                        camera.rankDxoRanking,
                        camera.rankColorRanking,
                        camera.rankDynRanking,
                        camera.rankLlnRanking,
                        camera.name,
                        camera.pixelDepth,
                        camera.sensor,
                        camera.type,
                        camera.status,
                        camera.launchDate,
                        camera.launchDateGraph,
                        camera.sensorraw,
                        camera.link,
                        camera.chapo,
                        camera.linkReview,
                        camera.maximumIso,
                        camera.rawFormat,
                        camera.autofocus,
                        camera.resolutionvideo,
                        camera.flash,
                        camera.video,
                        camera.waterproof,
                        camera.image
                        ])
                }
            } catch {
                log.error("reload camera DB failed, error:\(error)")
                rollback.pointee = true
            }
        }

    }

}
