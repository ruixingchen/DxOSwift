//
//  CameraDetailController.swift
//  DXOSwift
//
//  Created by ruixingchen on 30/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class CameraDetailController: RXTableViewController, RetryLoadingViewDelegate {

    private let camera:Camera

    private let scores_section:Int = 0
    private let specifications_section:Int = 1

    private let loadingView:LoadingView = LoadingView()
    private var requestFailedView:RetryLoadingView?
    private let headerView:CameraDetailPictureHeaderView = CameraDetailPictureHeaderView()

    init(camera:Camera){
        self.camera = camera
        super.init()
    }

    deinit {
        #if DEBUG || debug
            log.verbose("deinit")
        #endif
        camera.specification = nil //set to reload from server
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initTableView() -> UITableView {
        return UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = camera.name

        headerView.frame = CGRect(x: 0, y: 0, width: 300, height: 150)
        if let url:URL = URL(string: camera.c_bigImage) {
            headerView.imageView.kf.setImage(with: url)
        }else{
            headerView.imageView.image = nil
        }
        if camera.specification == nil {
            requestCameraSpecification()
        }else{
            self.tableView.tableHeaderView = headerView
        }
    }

    override func setupTableView() {
        super.setupTableView()
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    func installHeaderRefresh(){
        let rc:UIRefreshControl = UIRefreshControl()
        rc.addTarget(self, action: #selector(headerRefreshAction), for: .valueChanged)
        self.tableView.refreshControl = rc
    }

    @objc func headerRefreshAction(){
        requestCameraSpecification()
    }

    func requestCameraSpecification(){

        if self.loadingView.superview == nil {
            self.view.addSubview(loadingView)
            loadingView.snp.makeConstraints({ (make) in
                make.center.equalToSuperview()
                make.width.equalTo(200)
                make.height.equalTo(50)
            })
        }
        loadingView.isHidden = false
        self.requestFailedView?.isHidden = true

        DXOService.cameraSpecifications(link: camera.link) {[weak self] (inObject, inError) in
            if self == nil {
                return
            }
            if inObject == nil || inError != nil {
                DispatchQueue.main.async {
                    //request failed
                    if self?.requestFailedView == nil {
                        self?.requestFailedView = RetryLoadingView()
                        self?.requestFailedView?.delegate = self
                        self?.view.addSubview(self!.requestFailedView!)
                        self?.requestFailedView?.snp.makeConstraints({ (make) in
                            make.center.equalToSuperview()
                            make.width.equalToSuperview().offset(-32)
                            make.height.equalTo(100)
                        })
                    }
                    self?.loadingView.isHidden = true
                    self?.requestFailedView?.isHidden = false
                }
                return
            }
            DispatchQueue.main.async {
                self?.camera.specification = inObject
                self?.loadingView.isHidden = true
                self?.requestFailedView?.isHidden = true
                self?.tableView.tableHeaderView = self?.headerView
                self?.tableView.reloadData()
            }
        }
    }

    //MARK: - RetryLoadingViewDelegate

    func retryLoadingViewDidTapRetryButton(retryLoadingView: RetryLoadingView) {
        self.requestCameraSpecification()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if self.camera.specification == nil {
            return 0
        }
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.camera.specification == nil {
            return 0
        }
        if section == scores_section {
            return 4
        }else if section == specifications_section {
            return self.camera.specification?.count ?? 0
        }
        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == scores_section {
            return LocalizedString.camera_dxo_senser_scores
        }else if section == specifications_section {
            return LocalizedString.camera_specifications
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        if indexPath.section == scores_section {
            var tCell:CameraDetailScoreTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "CameraDetailScoreTableViewCell") as? CameraDetailScoreTableViewCell
            if tCell == nil {
                tCell = CameraDetailScoreTableViewCell(style: .default, reuseIdentifier: "CameraDetailScoreTableViewCell")
            }

            var leftText:String?
            var progress:Float = 0
            var infoText:String?

            switch indexPath.row {
            case 0: //overall
                leftText = LocalizedString.camera_detail_overall_score
                progress = Float(camera.rankDxo)/135
                infoText = String.init(format: "%d", camera.rankDxo)
            case 1: //portrait
                leftText = LocalizedString.camera_detail_portrait_des
                progress = camera.rankColor/34
                infoText = String.init(format: "%.1f", camera.rankColor).appending(" bits")
            case 2: //Landscape
                leftText = LocalizedString.camera_detail_landscape_des
                progress = camera.rankDyn/20
                infoText = String.init(format: "%.1f", camera.rankDyn).appending(" Evs")
            case 3: //sports
                leftText = LocalizedString.camera_detail_sports_des
                progress = Float(camera.rankLln)/5200
                infoText = String.init(format: "%d", camera.rankLln).appending(" ISO")
            default:
                break
            }

            tCell?.leftLabel.text = leftText
            tCell?.updateProgress(progress: progress)
            tCell?.rightLabel.text = infoText

            cell = tCell
        }else if indexPath.section == specifications_section {
            guard let sep:Camera.Specification = self.camera.specification?.safeGet(at: indexPath.row) else {
                let cell:RXBlankTableViewCell = RXBlankTableViewCell(reuseIdentifier: nil)
                #if DEBUG || debug
                    cell.infoLabel.text = "can not get camera specifications"
                #endif
                return cell
            }
            var tCell:CameraDetailSpecificationsTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "CameraDetailSpecificationsTableViewCell") as? CameraDetailSpecificationsTableViewCell
            if tCell == nil {
                tCell = CameraDetailSpecificationsTableViewCell(style: .default, reuseIdentifier: "CameraDetailSpecificationsTableViewCell")
            }
            tCell?.leftLabel.text = sep.key
            tCell?.rightLabel.text = sep.value
            cell = tCell
        }
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == specifications_section {
            guard let sep:Camera.Specification = self.camera.specification?.safeGet(at: indexPath.row) else{
                return
            }
            print(sep.description)
        }
    }

}
