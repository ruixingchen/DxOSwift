//
//  Camera.swift
//  DXOSwift
//
//  Created by ruixingchen on 20/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation
import SwiftyJSON

class Camera: Device {

    var autofocus : String!
    var brand : String!
    var chapo : String!
    var flash : String!
    var id : Int!
    var image : String!
    var launchDate : String!
    var launchDateGraph : String!
    var link : String!
    var linkReview : String!
    var maximumIso : Int!
    var name : String!
    var pixelDepth : Float!
    var price : Int!
    var rankColor : Float!
    var rankColorRanking : Int!
    var rankDxo : Int!
    var rankDxoRanking : Int!
    var rankDyn : Float!
    var rankDynRanking : Int!
    var rankLln : Int!
    var rankLlnRanking : Int!
    var rawFormat : String!
    var resolutionvideo : Int!
    var sensor : String!
    var sensorraw : Float!
    var status : String!
    var type : String!
    var video : String!
    var waterproof : String!
    var year : String!

    var launchTime:TimeInterval = 0

    init(fromJson json: JSON){
        if json.isEmpty{
            return
        }
        autofocus = json["autofocus"].stringValue
        brand = json["brand"].stringValue
        chapo = json["chapo"].stringValue
        flash = json["flash"].stringValue
        id = json["id"].intValue
        image = json["image"].stringValue
        if !(image?.isEmpty ?? true) {
            if image!.hasPrefix("//") {
                image = image?.replacingOccurrences(of: "//", with: "")
            }
        }
        launchDate = json["launchDate"].stringValue
        launchDateGraph = json["launchDateGraph"].stringValue
        link = json["link"].stringValue
        if !(link?.isEmpty ?? true) {
            link = DXOService.cpmpleteURLWithPath(path: link)
        }
        linkReview = json["linkReview"].stringValue
        if !(linkReview?.isEmpty ?? true) {
            linkReview = DXOService.cpmpleteURLWithPath(path: linkReview)
        }
        maximumIso = json["maximum_iso"].intValue
        name = json["name"].stringValue
        pixelDepth = json["pixelDepth"].floatValue
        price = json["price"].intValue
        rankColor = json["rankColor"].floatValue
        rankColorRanking = json["rankColor_ranking"].intValue
        rankDxo = json["rankDxo"].intValue
        rankDxoRanking = json["rankDxo_ranking"].intValue
        rankDyn = json["rankDyn"].floatValue
        rankDynRanking = json["rankDyn_ranking"].intValue
        rankLln = json["rankLln"].intValue
        rankLlnRanking = json["rankLln_ranking"].intValue
        rawFormat = json["raw_format"].stringValue
        resolutionvideo = json["resolutionvideo"].intValue
        sensor = json["sensor"].stringValue
        sensorraw = json["sensorraw"].floatValue
        status = json["status"].stringValue
        type = json["type"].stringValue
        video = json["video"].stringValue
        waterproof = json["waterproof"].stringValue
        year = json["year"].stringValue
    }
}

extension Camera {
    enum SenserFormat: String {
        /*
         ["sensor_apsc", "sensor_apsh", "sensor_fullframe", "sensor_compact_1over1.7", "sensor_compact_2over3", "sensor_medium", "sensor_micro43", "sensor_compact_1over2.3", "", "sensor_compact_1", "sensor_compact_1over3"]
         */
        case compact_1over3 = "sensor_compact_1over3"
        case compact_1over2_3 = "sensor_compact_1over2.3"
        case compact_1over1_7 = "sensor_compact_1over1.7"
        case compact_2over3 = "sensor_compact_2over3"
        case compact_1 = "sensor_compact_1"

        case micro43 = "sensor_micro43"
        case apsc = "sensor_apsc"
        case apsh = "sensor_apsh"
        case fullFrame = "sensor_fullframe"
        case mediumFormat = "sensor_medium"
        case unknow
    }

    enum Brand: String {
        /*
         ["Canon", "Fujifilm", "Hasselblad", "Konica Minolta", "Leaf", "Leica", "Mamiya", "Nikon", "Olympus", "Panasonic", "Pentax", "Phase One", "Samsung", "Sony", "Ricoh", "Nokia", "DJI", "GoPro", "YUNEEC"]
         */
        case canon = "Canon"
        case fujifilm = "Fujifilm"
        case hasselblad = "Hasselblad"
        case konicaMinolta = "Konica Minolta"
        case leaf = "Leaf"
        case leica = "Leica"
        case mamiya = "Mamiya"
        case nikon = "Nikon"
        case olympus = "Olympus"
        case panasonic = "Panasonic"
        case pentax = "Pentax"
        case phaseOne = "Phase One"
        case samsung = "Samsung"
        case sony = "Sony"
        case ricoh = "Ricoh"
        case nokia = "Nokia"
        case dji = "DJI"
        case gopro = "GoPro"
        case yuneec = "YUNEEC"
        case unknown
    }

    enum CameraType: String {
        /*
         ["entryleveldslr", "semiprodslr", "professional", "entryleveldslr, semiprodslr", "semiprodslr, professional", "highendcompact", "none", "hybrid", "compact", "mobile", "drone", "smartphone", "actioncamera"]
         */
        //some type has a white space at the end, we need trim it
        case entryLevelDSLR = "entryleveldslr"
        case semiProDSLR = "semiprodslr"
        case professional = "professional"
        case highEndCompact = "highendcompact"
        case node = "none"
        case hybrid = "hybrid"
        case compact = "compact"
        case mobile = "mobile"
        case drone = "drone"
        case smartPhone = "smartphone"
        case actionCamera = "actioncamera"
        case unknown
    }
}
