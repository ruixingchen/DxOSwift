//
//  Lens.swift
//  DXOSwift
//
//  Created by ruixingchen on 20/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation
import SwiftyJSON

class Lens: Device {

    var ac : Float!
    var acRanking : Int!
    var autofocus : String!
    var brand : String!
    var brandSensor : String!
    var chapo : String!
    var distorsion : Float!
    var distorsionRanking : Int!
    var effmpix : Float!
    var effmpixRanking : Int!
    var global : Float!
    var globalRanking : Int!
    var id : String!
    var idCamera : String!
    var idLen : Int!
    var image : String!
    var launchDate : String!
    var launchDateGraph : String!
    var lensType : String!
    var lensZoom : String!
    var lensrange : String!
    var link : String!
    var linkReview : String!
    var macro : String!
    var maxApertureAtMinFocal : Float!
    var mountType : String!
    var mountedOn : String!
    var mountedOnLink : String!
    var name : String!
    var pixelDepth : Float!
    var price : Int!
    var priceSensor : Int!
    var sensorformat : String!
    var sensorraw : Float!
    var status : String!
    var tstop : Float!
    var tstopRanking : Int!
    var type : String!
    var vignetting : Float!
    var vignettingRanking : Int!
    var weight : Int!
    var year : String!
    var zoomfactor : Int!

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        ac = json["ac"].floatValue
        acRanking = json["ac_ranking"].intValue
        autofocus = json["autofocus"].stringValue
        brand = json["brand"].stringValue
        brandSensor = json["brandSensor"].stringValue
        chapo = json["chapo"].stringValue
        distorsion = json["distorsion"].floatValue
        distorsionRanking = json["distorsion_ranking"].intValue
        effmpix = json["effmpix"].floatValue
        effmpixRanking = json["effmpix_ranking"].intValue
        global = json["global"].floatValue
        globalRanking = json["global_ranking"].intValue
        id = json["id"].stringValue
        idCamera = json["idCamera"].stringValue
        idLen = json["idLen"].intValue
        image = json["image"].stringValue
        launchDate = json["launchDate"].stringValue
        launchDateGraph = json["launchDateGraph"].stringValue
        lensType = json["lens_type"].stringValue
        lensZoom = json["lens_zoom"].stringValue
        lensrange = json["lensrange"].stringValue
        link = json["link"].stringValue
        linkReview = json["linkReview"].stringValue
        macro = json["macro"].stringValue
        maxApertureAtMinFocal = json["maxApertureAtMinFocal"].floatValue
        mountType = json["mountType"].stringValue
        mountedOn = json["mountedOn"].stringValue
        mountedOnLink = json["mountedOnLink"].stringValue
        name = json["name"].stringValue
        pixelDepth = json["pixelDepth"].floatValue
        price = json["price"].intValue
        priceSensor = json["priceSensor"].intValue
        sensorformat = json["sensorformat"].stringValue
        sensorraw = json["sensorraw"].floatValue
        status = json["status"].stringValue
        tstop = json["tstop"].floatValue
        tstopRanking = json["tstop_ranking"].intValue
        type = json["type"].stringValue
        vignetting = json["vignetting"].floatValue
        vignettingRanking = json["vignetting_ranking"].intValue
        weight = json["weight"].intValue
        year = json["year"].stringValue
        zoomfactor = json["zoomfactor"].intValue
    }
}

extension Lens {
    enum Brand: String {
        /*
         ["Sony", "Sigma", "Olympus", "Tamron", "Canon", "Nikon", "Tokina", "Carl Zeiss", "Panasonic", "Pentax", "Samyang", "Ricoh", "Samsung", "Voigtlander", "Konica Minolta"]
         */
        case sony = "Sony"
        case sigma = "Sigma"
        case olympus = "Olympus"
        case tamron = "Tamron"
        case canon = "Canon"
        case nikon = "Nikon"
        case carlZeiss = "Carl Zeiss"
        case panasonic = "Panasonic"
        case pentax = "Pentax"
        case samyang = "Samyang"
        case ricoh = "Ricoh"
        case samsung = "Samsung"
        case voigtlander = "Voigtlander"
        case konicaMinolta = "Konica Minolta"
    }

    enum MountType:String {
        /*
         ["Sony FE", "Canon EF", "Nikon F FX", "Micro 4/3", "Sony E", "Canon EF-S", "Nikon F DX", "Sony Alpha", "Pentax KAF", "Sony Alpha DT", "Compact", "Canon EF-M", "Nikon 1 CX", "Samsung NX", "Four Thirds"]
         */
        case sony_FE = "Sony FE"
        case canon_EF = "Canon EF"
        case nikon_F_FX = "Nikon F FX"
        case micro4_3 = "Micro 4/3"
        case sony_E = "Sony E"
        case canon_EF_S = "Canon EF-S"
        case nikon_F_DX = "Nikon F DX"
        case sony_Alpha = "Sony Alpha"
        case pentax_KAF = "Pentax KAF"
        case sony_AlphaDT = "Sony Alpha DT"
        case compact = "Compact"
        case canon_EF_M = "Canon EF-M"
        case nikon_1_CX = "Nikon 1 CX"
        case samsung_NX = "Samsung NX"
        case fourThirds = "Four Thirds"
        //need add more, but it has no model
    }

    enum ZoomType:String {
        case zoom = "zoom"
        case prime = "prime"
    }

    enum LensType:String {
        /*
         ["lens_superwide", "lens_telephoto", "lens_medium", "lens_wide", "lens_supertelephoto"]
         */
        case superWide = "lens_superwide"
        case telephoto = "lens_telephoto"
        case medium = "lens_medium"
        case wide = "lens_wide"
        case supertelephoto = "lens_supertelephoto"
    }


}
