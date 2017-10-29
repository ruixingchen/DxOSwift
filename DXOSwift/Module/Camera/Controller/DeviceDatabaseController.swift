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

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: LocalizedString.database_sort_title, style: .plain, target: self, action: #selector(didTapSortButton))
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
        let overall:UIAlertAction = UIAlertAction(title: LocalizedString.database_overall, style: .default) { (_) in
            self.cameraDataSource?.sort(sortType: .overall)
            self.tableView.reloadData()
        }
        let portrait:UIAlertAction = UIAlertAction(title: LocalizedString.database_portrait, style: .default) { (_) in
            self.cameraDataSource?.sort(sortType: .portrait)
            self.tableView.reloadData()
        }
        let landscape:UIAlertAction = UIAlertAction(title: LocalizedString.database_landscape, style: .default) { (_) in
            self.cameraDataSource?.sort(sortType: .landscape)
            self.tableView.reloadData()
        }
        let sports:UIAlertAction = UIAlertAction(title: LocalizedString.database_sports, style: .default) { (_) in
            self.cameraDataSource?.sort(sortType: .sports)
            self.tableView.reloadData()
        }
        let cancel:UIAlertAction = UIAlertAction(title: LocalizedString.title_cancel, style: .cancel, handler: nil)

        alert.addAction(overall)
        alert.addAction(portrait)
        alert.addAction(landscape)
        alert.addAction(sports)
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
            return 0
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:DeviceDatabaseTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell") as? DeviceDatabaseTableViewCell
        if cell == nil {
            cell = DeviceDatabaseTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        }

        if self.deviceType == .camera {
            guard let camera:Camera = self.cameraDataSource?.dataSource.safeGet(at: indexPath.row) else {
                let blankCell:RXBlankTableViewCell = RXBlankTableViewCell(reuseIdentifier: nil)
                #if DEBUG || debug
                    blankCell.infoLabel.text = "can not get camera"
                #endif
                return blankCell
            }
            var scoreText:String!
            var backgroundWidthMult:Double = 0
            switch cameraDataSource!.sortType {
            case .overall:
                scoreText = String.init(format: "%d", camera.rankDxo)
                backgroundWidthMult = Double(camera.rankDxo)/Double(cameraDataSource!.dxoScoreMax)
            case .portrait:
                scoreText = String.init(format: "%.1f", camera.rankColor)
                backgroundWidthMult = camera.rankColor/cameraDataSource!.colorMax
            case .landscape:
                scoreText = String.init(format: "%.1f", camera.rankDyn)
                backgroundWidthMult = camera.rankDyn/cameraDataSource!.dynamicRangeMax
            case .sports:
                scoreText = String.init(format: "%d", camera.rankLln)
                backgroundWidthMult = Double(camera.rankLln)/Double(cameraDataSource!.LlnMax)
            }
            cell?.scoreLabel.text = scoreText
            cell?.backgroundProgressView.snp.remakeConstraints({ (make) in
                make.left.equalToSuperview()
                make.height.equalToSuperview().offset(-8)
                make.centerY.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(backgroundWidthMult)
            })

            if let url:URL = URL(string: camera.image) {
                cell?.coverImageView.kf.setImage(with: url)
            }else{
                cell?.coverImageView.image = nil
            }
            cell?.titleLabel.text = camera.name
            var detailText:String = String(format: "%.1f", camera.sensorraw)
            detailText.append(" MP, ")
            detailText.append(camera.c_senserFormat.localizedDescription)
            cell?.detailLabel.text = detailText
        }else{

        }
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        var next:UIViewController?

        if self.deviceType == .camera {
            next = CameraDetailController()
        }else if self.deviceType == .lens {

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
