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
    var sensor : String! {
        didSet {
            c_senserFormat = SenserFormat(rawValue: sensor ?? "") ?? SenserFormat.unknow
        }
    }
    var sensorraw : Float! //mp
    var status : String!
    var type : String!
    var video : String!
    var waterproof : String!
    var year : String!

    //c_ means this is a calculated like property, will be setted when the linked property did set

    /// UTC time from launchDateGraph
    var c_launchTime:TimeInterval = 0
    var c_senserFormat:SenserFormat!

    init?(fromJson json: JSON){
        super.init()
        if !self.updateProperty(json: json) {
            return nil
        }
    }

    /// update property with JSON, to make didSet called in init function, if init failed, return false, or return true
    func updateProperty(json:JSON)->Bool{
        autofocus = json["autofocus"].stringValue
        brand = json["brand"].stringValue
        chapo = json["chapo"].stringValue
        flash = json["flash"].stringValue
        id = json["id"].intValue
        if id == 0 {
            return false
        }
        image = json["image"].stringValue
        if !(image?.isEmpty ?? true) {
            if image!.hasPrefix("//") {
                image = image?.replacingOccurrences(of: "//", with: "")
            }
            if !image.hasPrefix("http"){
                image = "https://"+image
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

        return true
    }
}

extension Camera {
    enum SenserFormat: String {
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
        case unknow = "unknown"

        var shortDescription:String {
            switch self {
            case .compact_1over3:
                return "1/3'"
            case .compact_1over2_3:
                return "1/2.3'"
            case .compact_1over1_7:
                return "1/1.7'"
            case .compact_2over3:
                return "2/3''"
            case .compact_1:
                return "1'"
            case .micro43:
                return "M43"
            case .apsc:
                return "APSC"
            case .apsh:
                return "APSH"
            case .fullFrame:
                return "FF"
            case .mediumFormat:
                return "MF"
            case .unknow:
                return "unknow"
            }
        }

        var localizedDescription:String {
            switch self {
            case .compact_1over3:
                return LocalizedString.databae_senser_1_3
            case .compact_1over2_3:
                return LocalizedString.databae_senser_1_2_3
            case .compact_1over1_7:
                return LocalizedString.databae_senser_1_1_7
            case .compact_2over3:
                return LocalizedString.databae_senser_2_3
            case .compact_1:
                return LocalizedString.databae_senser_1
            case .micro43:
                return LocalizedString.databae_senser_micro_4_3
            case .apsc:
                return LocalizedString.databae_senser_apsc
            case .apsh:
                return LocalizedString.databae_senser_apsh
            case .fullFrame:
                return LocalizedString.databae_senser_full_frame
            case .mediumFormat:
                return LocalizedString.database_senser_medium_format
            case .unknow:
                return LocalizedString.database_senser_unknown
            }
        }
    }

    enum Brand: String {
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
