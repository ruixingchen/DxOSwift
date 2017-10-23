//
//  DeviceDataBaseController.swift
//  DXOSwift
//
//  Created by ruixingchen on 22/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class DeviceDataBaseController: RXTableViewController {

    var dataSource:NSMutableArray = NSMutableArray() //two dimension
    var headerTitles:NSMutableArray = NSMutableArray()

    var deviceType:DeviceType = DeviceType.camera
    var cameraConfig:CameraConfig!
    var lensConfig:LensConfig!

    init(deviceType:DeviceType) {
        super.init()
        self.deviceType = deviceType
        if self.deviceType == .camera {
            cameraConfig = CameraConfig()
        }else if self.deviceType == .lens {
            lensConfig = LensConfig()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.deviceType = DeviceType.camera
        if self.deviceType == .camera {
            cameraConfig = CameraConfig()
        }else if self.deviceType == .lens {
            lensConfig = LensConfig()
        }
    }

    override func initTableView() -> UITableView {
        let tableView:UITableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
        return tableView
    }

    override func firstViewDidLoad() {
        super.firstViewDidLoad()
    }

    override func firstViewDidAppear(_ animated: Bool) {
        super.firstViewDidAppear(animated)

    }

    func reloadDataBase(){
        if self.deviceType == .camera && !CameraManager.shared.testedCameraReady{

        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

}

extension DeviceDataBaseController {

    enum DeviceType {
        case camera, lens, mobile
    }

    struct LensConfig {
        enum Sort {
            case score
            case sharpness
            case distortion
            case vignetting
            case transmission
            case aberration
        }
        enum ListType {
            case list, grid, graph
        }

        var listType:DeviceDataBaseController.LensConfig.ListType = DeviceDataBaseController.LensConfig.ListType.list
        var sortType:LensConfig.Sort = LensConfig.Sort.score
    }

    struct CameraConfig {
        enum SortType {
            case overall
            case portrait
            case landscape
            case sports
        }
        enum ListType {
            case list
            case yearGroup
            case graph
        }
        var listType:CameraConfig.ListType = CameraConfig.ListType.list
        var sortType:CameraConfig.SortType = CameraConfig.SortType.overall

        private func sorted(sortType:CameraConfig.SortType)->[Camera]{
            return CameraManager.shared.testedCamera.sorted(by: { (t1, t2) -> Bool in
                switch sortType {
                case .overall:
                    return t1.rankDxo > t2.rankDxo
                case .portrait:
                    return t1.rankColor > t2.rankColor
                case .landscape:
                    return t1.rankDyn > t2.rankDyn
                case .sports:
                    return t1.rankLln > t2.rankLln
                }
            })
        }


        /// the year grouped data source
        ///
        /// - Returns: the first is datasource(2 dimension, Camera), the last is header title (1 dimention, string)
        private func yearGrouped()->(NSMutableArray, NSMutableArray){
            let yearStringArray:NSMutableArray = NSMutableArray()
            let groupedDeviceArray:NSMutableArray = NSMutableArray()

            for i in 2000...2020 {
                yearStringArray.add("\(i)")
                groupedDeviceArray.add(NSMutableArray(capacity: 20))
            }

            for i in CameraManager.shared.testedCamera {
                let index:Int = yearStringArray.index(of: i.year)
                if index < 0 || index >= yearStringArray.count {
                    continue
                }
                (groupedDeviceArray[index] as! NSMutableArray).add(i)
            }
            for var i in 0..<yearStringArray.count {
                if (groupedDeviceArray[i] as! NSArray).count == 0 {
                    yearStringArray.removeObjects(at: IndexSet.init(integer: i))
                    groupedDeviceArray.removeObjects(at: IndexSet.init(integer: i))
                    i -= 1
                }
            }
            return (groupedDeviceArray, yearStringArray)
        }

        func dataSource() -> (NSMutableArray, NSMutableArray){
            if listType == ListType.list {
                let sorted:[Camera] = self.sorted(sortType: sortType)
                return (NSMutableArray.init(array: sorted), NSMutableArray())
            }else if listType == ListType.yearGroup {
                return self.yearGrouped()
            }else if listType == ListType.graph {

            }
            return (NSMutableArray(), NSMutableArray())
        }

    }
}
