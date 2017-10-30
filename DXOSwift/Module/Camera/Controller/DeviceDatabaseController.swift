//
//  DeviceDatabaseController.swift
//  DXOSwift
//
//  Created by ruixingchen on 22/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import SwiftyJSON
import SnapKit

class DeviceDatabaseController: RXTableViewController, RetryLoadingViewDelegate {

    enum DeviceType {
        case camera, lens
    }

    let loadingView:LoadingView = LoadingView()
    var requestFailedView: RetryLoadingView?

    let deviceType:DeviceType
    var cameraDataSource:CameraDatabaseDataSource?
    var lensDataSource:LensDatabaseDataSource?

    init(deviceType: DeviceType) {
        self.deviceType = deviceType
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        self.deviceType = DeviceType.camera
        super.init(coder: aDecoder)
    }

    deinit {
        #if DEBUG || debug
            log.verbose("deinit")
        #endif
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.deviceType == .camera {
            self.title = LocalizedString.database_camera_database_title
        }else if self.deviceType == .lens {
            self.title = LocalizedString.database_lens_database_title
        }

        loadingView.messageLabel.text = LocalizedString.database_loading_message

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        requestDatabase()
    }

    override func setupTableView() {
        super.setupTableView()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 74
    }

    @objc func didTapSortButton(){
        let alert:UIAlertController = UIAlertController(title: LocalizedString.database_sort_title, message: nil, preferredStyle: .actionSheet)
        if self.deviceType == .camera {
            let overall:UIAlertAction = UIAlertAction(title: LocalizedString.database_camera_overall, style: .default) { (_) in
                self.cameraDataSource?.sort(sortType: .overall)
                self.tableView.reloadData()
            }
            let portrait:UIAlertAction = UIAlertAction(title: LocalizedString.database_camera_portrait, style: .default) { (_) in
                self.cameraDataSource?.sort(sortType: .portrait)
                self.tableView.reloadData()
            }
            let landscape:UIAlertAction = UIAlertAction(title: LocalizedString.database_camera_landscape, style: .default) { (_) in
                self.cameraDataSource?.sort(sortType: .landscape)
                self.tableView.reloadData()
            }
            let sports:UIAlertAction = UIAlertAction(title: LocalizedString.database_camera_sports, style: .default) { (_) in
                self.cameraDataSource?.sort(sortType: .sports)
                self.tableView.reloadData()
            }
            alert.addAction(overall)
            alert.addAction(portrait)
            alert.addAction(landscape)
            alert.addAction(sports)
        }else if self.deviceType == .lens {
            let score:UIAlertAction = UIAlertAction(title: LocalizedString.database_lens_dxo_mark_score, style: .default, handler: { (_) in
                self.lensDataSource?.sort(sortType: .score)
                self.tableView.reloadData()
            })
            let sharpness:UIAlertAction = UIAlertAction(title: LocalizedString.database_camera_sharpness, style: .default, handler: { (_) in
                self.lensDataSource?.sort(sortType: .sharpness)
                self.tableView.reloadData()
            })
            let distortion:UIAlertAction = UIAlertAction(title: LocalizedString.database_lens_distortion, style: .default, handler: { (_) in
                self.lensDataSource?.sort(sortType: .distortion)
                self.tableView.reloadData()
            })
            let vignetting:UIAlertAction = UIAlertAction(title: LocalizedString.database_lens_vignetting, style: .default, handler: { (_) in
                self.lensDataSource?.sort(sortType: .vignetting)
                self.tableView.reloadData()
            })
            let transmission:UIAlertAction = UIAlertAction(title: LocalizedString.database_lens_transmission, style: .default, handler: { (_) in
                self.lensDataSource?.sort(sortType: .transmission)
                self.tableView.reloadData()
            })
            let aberration:UIAlertAction = UIAlertAction(title: LocalizedString.database_lens_aberration, style: .default, handler: { (_) in
                self.lensDataSource?.sort(sortType: .aberration)
                self.tableView.reloadData()
            })
            alert.addAction(score)
            alert.addAction(sharpness)
            alert.addAction(distortion)
            alert.addAction(vignetting)
            alert.addAction(transmission)
            alert.addAction(aberration)
        }

        let cancel:UIAlertAction = UIAlertAction(title: LocalizedString.title_cancel, style: .cancel, handler: nil)
        alert.addAction(cancel)

        if UIDevice.current.userInterfaceIdiom == .phone {
            self.present(alert, animated: true, completion: nil)
        }else if UIDevice.current.userInterfaceIdiom == .pad {
            let popover:UIPopoverPresentationController? = alert.popoverPresentationController
            popover?.barButtonItem = self.navigationItem.rightBarButtonItem
            self.present(alert, animated: true, completion: nil)
        }
    }

    func requestDatabase(){
        if loadingView.superview == nil {
            self.view.addSubview(loadingView)
            loadingView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.equalToSuperview().offset(-32)
                make.height.equalTo(50)
            }
        }
        loadingView.isHidden = false
        requestFailedView?.isHidden = true

        if self.deviceType == .camera {
            DXOService.testedCamera(completion: {[weak self] (inObject, inError) in
                self?.requestDatabaseFinish(dataSourceAnyObject: inObject, error: inError)
            })
        }else if self.deviceType == .lens{
            DXOService.testedLens(completion: {[weak self] (inObject, inError) in
                self?.requestDatabaseFinish(dataSourceAnyObject: inObject, error: inError)
            })
        }
    }

    func requestDatabaseFinish(dataSourceAnyObject:Any?, error:RXError?){
        if dataSourceAnyObject == nil || error != nil {
            DispatchQueue.main.async {
                if self.requestFailedView != nil {
                    self.requestFailedView = RetryLoadingView()
                    self.requestFailedView?.delegate = self
                    self.view.addSubview(self.requestFailedView!)
                    self.requestFailedView?.snp.makeConstraints({ (make) in
                        make.center.equalToSuperview()
                        make.width.equalToSuperview().offset(-32)
                        make.height.equalTo(100)
                    })
                }
                self.loadingView.isHidden = true
                self.requestFailedView?.isHidden = false
            }
            return
        }
        DispatchQueue.main.async {
            self.requestFailedView?.isHidden = true
            self.loadingView.isHidden = true
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: LocalizedString.database_sort_title, style: .plain, target: self, action: #selector(self.didTapSortButton))
            if self.deviceType == .camera {
                self.cameraDataSource = dataSourceAnyObject as? CameraDatabaseDataSource
                self.tableView.reloadData()
            }else {
                self.lensDataSource = dataSourceAnyObject as? LensDatabaseDataSource
                self.tableView.reloadData()
            }
        }
    }

    //MARK: - RetryLoadingViewDelegate

    func retryLoadingViewDidTapRetryButton(retryLoadingView: RetryLoadingView) {
        requestDatabase()
    }

    //MARK: - TableView

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.deviceType == .camera {
            return self.cameraDataSource?.dataSource.count ?? 0
        }else if self.deviceType == .lens {
            return self.lensDataSource?.dataSource.count ?? 0
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:DeviceDatabaseTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell") as? DeviceDatabaseTableViewCell
        if cell == nil {
            cell = DeviceDatabaseTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        }

        var scoreText:String?
        var backgroundWidthMult:Float = 0
        var imageUrl:String?
        var titleText:String?
        var detailText:String?

        if self.deviceType == .camera {
            guard let camera:Camera = self.cameraDataSource?.dataSource.safeGet(at: indexPath.row) else {
                let blankCell:RXBlankTableViewCell = RXBlankTableViewCell(reuseIdentifier: nil)
                #if DEBUG || debug
                    blankCell.infoLabel.text = "can not get camera"
                #endif
                return blankCell
            }
            switch cameraDataSource!.sortType {
            case .overall:
                scoreText = String.init(format: "%d", camera.rankDxo)
                backgroundWidthMult = Float(camera.rankDxo)/Float(cameraDataSource!.dxoScoreMax)
            case .portrait:
                scoreText = String.init(format: "%.1f", camera.rankColor)
                backgroundWidthMult = camera.rankColor/cameraDataSource!.colorMax
            case .landscape:
                scoreText = String.init(format: "%.1f", camera.rankDyn)
                backgroundWidthMult = camera.rankDyn/cameraDataSource!.dynamicRangeMax
            case .sports:
                scoreText = String.init(format: "%d", camera.rankLln)
                backgroundWidthMult = Float(camera.rankLln)/Float(cameraDataSource!.LlnMax)
            }
            imageUrl = camera.image
            titleText = camera.name
            detailText = String(format: "%.1f", camera.sensorraw)
            detailText?.append(" MP, ")
            detailText?.append(camera.c_senserFormat.localizedDescription)
        }else{
            guard let lens:Lens = self.lensDataSource?.dataSource.safeGet(at: indexPath.row) else {
                let blankCell:RXBlankTableViewCell = RXBlankTableViewCell(reuseIdentifier: nil)
                #if DEBUG || debug
                    blankCell.infoLabel.text = "can not get lens"
                #endif
                return blankCell
            }
            switch lensDataSource!.sortType {
            case .score:
                scoreText = String.init(format: "%.0f", lens.global)
                backgroundWidthMult = lens.global/lensDataSource!.globalMax
            case .sharpness:
                scoreText = String.init(format: "%.0f", lens.effmpix)
                backgroundWidthMult = lens.effmpix/lensDataSource!.effmpixMax
            case .distortion:
                scoreText = String.init(format: "%.3f", lens.distorsion)
                backgroundWidthMult = 1-lens.distorsion/lensDataSource!.distorsionMax
            case .vignetting:
                scoreText = String.init(format: "%.1f", lens.vignetting)
                backgroundWidthMult = 1-lens.vignetting/lensDataSource!.vignettingMin
            case .transmission:
                scoreText = String.init(format: "%.1f", lens.tstop)
                backgroundWidthMult = 1-lens.tstop/lensDataSource!.tstopMax
            case .aberration:
                scoreText = String.init(format: "%.1f", lens.ac)
                backgroundWidthMult = 1-lens.ac/lensDataSource!.acMax
            }

            imageUrl = lens.image
            titleText = lens.name
            detailText = LocalizedString.database_lens_mounted_on
            detailText?.append(": ")
            if (lens.mountedOn?.isEmpty ?? true) {
                detailText?.append(LocalizedString.common_unknown)
            }else{
                detailText?.append(lens.mountedOn)
            }
        }

        cell?.scoreLabel.text = scoreText
        cell?.backgroundProgressView.snp.remakeConstraints({ (make) in
            make.left.equalToSuperview()
            make.height.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(backgroundWidthMult)
        })
        if let url:URL = URL(string: imageUrl ?? "") {
            cell?.coverImageView.kf.setImage(with: url)
        }else{
            cell?.coverImageView.image = nil
        }
        cell?.titleLabel.text = titleText
        cell?.detailLabel.text = detailText
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        var next:UIViewController?

        if self.deviceType == .camera {
            guard let camera:Camera = self.cameraDataSource?.dataSource.safeGet(at: indexPath.row) else {
                log.error("can not get camera")
                return
            }
            let detail:CameraDetailController = CameraDetailController(camera: camera)
            detail.view.backgroundColor = UIColor.white
            next = detail
        }else if self.deviceType == .lens {
            guard let lens:Lens = self.lensDataSource?.dataSource.safeGet(at: indexPath.row) else {
                return
            }
            log.verbose(lens.shortDescription)
        }
        if next != nil {
            self.navigationController?.pushViewController(next!, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    }

//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let favoriteAction: UIContextualAction = UIContextualAction(style: .normal, title: "Favorite") { (action, _, finish) in
//            print("favorite \(indexPath.row)")
//        }
//        return UISwipeActionsConfiguration(actions: [favoriteAction])
//    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let favoriteAction:UITableViewRowAction = UITableViewRowAction(style: .default, title: LocalizedString.database_favorite_title) { (action, indexPath) in
            print("favorite \(indexPath.row)")
        }
        return [favoriteAction]
    }

}
