//
//  DeviceDetailController.swift
//  DXOSwift
//
//  Created by ruixingchen on 30/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class DeviceDetailController: RXTableViewController, RetryLoadingViewDelegate {

    private let deviceType:Device.DeviceType
    private var camera:Camera!
    private var lens:Lens!

    private var scores_section:Int = 0
    private let specifications_section:Int = 1

    private let loadingView:LoadingView = LoadingView()
    private var requestFailedView:RetryLoadingView?
    private let headerView:DeviceDetailPictureHeaderView = DeviceDetailPictureHeaderView()

    init(deviceType:Device.DeviceType, device:Device) {
        self.deviceType = deviceType
        super.init()
        if deviceType == Device.DeviceType.camera {
            self.camera = device as! Camera
        }else if deviceType == Device.DeviceType.lens {
            self.lens = device as! Lens
        }
    }

    deinit {
        #if DEBUG || debug
            log.verbose("deinit")
        #endif
        if deviceType == .camera {
            camera.specification = nil //set to reload from server
        }else if deviceType == .lens {
            lens.specification = nil
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initTableView() -> UITableView {
        return UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if self.deviceType == .camera {
            self.title = camera.name
        }else if self.deviceType == .lens {
            self.title = lens.name
        }

        headerView.frame = CGRect(x: 0, y: 0, width: 300, height: 150)

        var image:String?
        if self.deviceType == .camera {
            image = camera.c_bigImage
        }else if deviceType == .lens {
            image = lens.c_bigImage
        }
        if let url:URL = URL(string: image ?? "") {
            headerView.imageView.kf.setImage(with: url)
        }else{
            headerView.imageView.image = nil
        }
        if deviceType == .camera {
            if camera.specification == nil {
                requestSpecification()
            }else{
                self.tableView.tableHeaderView = headerView
            }
        }else if deviceType == .lens {
            if lens.specification == nil {
                requestSpecification()
            }else{
                self.tableView.tableHeaderView = headerView
            }
        }
    }

    override func setupTableView() {
        super.setupTableView()
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    func requestSpecification(){

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
        if deviceType == .camera {
            DXOService.cameraSpecifications(link: camera.link.appending("---Specifications")) {[weak self] (inObject, inError) in
                if self == nil {
                    return
                }
                self?.requestSpecificationsFinish(inObject: inObject, inError: inError)
            }
        }else if deviceType == .lens {
            let link = lens.link.replacingOccurrences(of: "__\(lens.idCamera!)", with: "---Specifications__\(lens.idCamera!)")
            DXOService.cameraSpecifications(link: link, completion: {[weak self] (inObject, inError) in
                if self == nil {
                    return
                }
                self?.requestSpecificationsFinish(inObject: inObject, inError: inError)
            })
        }
    }

    func requestSpecificationsFinish(inObject:[Device.Specification]?, inError:RXError?){
        if inObject == nil || inError != nil {
            DispatchQueue.main.async {
                //request failed
                if self.requestFailedView == nil {
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
            if self.deviceType == .camera {
                self.camera.specification = inObject
            }else if self.deviceType == .lens {
                self.lens.specification = inObject
            }
            self.loadingView.isHidden = true
            self.requestFailedView?.isHidden = true
            self.tableView.tableHeaderView = self.headerView
            self.tableView.reloadData()
        }
    }

    //MARK: - RetryLoadingViewDelegate

    func retryLoadingViewDidTapRetryButton(retryLoadingView: RetryLoadingView) {
        self.requestSpecification()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if deviceType == .camera {
            if camera.specification == nil {
                return 0
            }
            return 2
        }else if deviceType == .lens {
            if lens.specification == nil {
                return 0
            }
            return 2
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if deviceType == .camera {
            if self.camera.specification == nil {
                return 0
            }
            if section == scores_section {
                return 4
            }else if section == specifications_section {
                return self.camera.specification?.count ?? 0
            }
        }else if deviceType == .lens {
            if self.lens.specification == nil {
                return 0
            }
            if section == scores_section {
                return 5
            }else if section == specifications_section {
                return self.lens.specification?.count ?? 0
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if deviceType == .camera {
            if section == scores_section {
                return LocalizedString.camera_dxo_senser_scores
            }else if section == specifications_section {
                return LocalizedString.camera_specifications
            }
        }else if deviceType == .lens {

        }
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
            if indexPath.section == scores_section {
                var tCell:DeviceDetailScoreTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "DeviceDetailScoreTableViewCell") as? DeviceDetailScoreTableViewCell
                if tCell == nil {
                    tCell = DeviceDetailScoreTableViewCell(style: .default, reuseIdentifier: "DeviceDetailScoreTableViewCell")
                }

                var leftText:String?
                var progress:Float = 0
                var infoText:String?

                switch indexPath.row {
                case 0:
                    if deviceType == .camera {
                        //overall
                        leftText = LocalizedString.camera_detail_overall_score
                        progress = Float(camera.rankDxo)/135
                        infoText = String.init(format: "%d", camera.rankDxo)
                    }else if deviceType == .lens {
                        //sharpness
                        leftText = LocalizedString.database_camera_sharpness
                        progress = lens.effmpix/50.5
                        infoText = String.init(format: "%.1f", lens.effmpix).appending(" P-Mpix") //词穷, 这个怎么翻译? 可辨百万像素?
                    }
                case 1:
                    if deviceType == .camera {
                        //portrait
                        leftText = LocalizedString.camera_detail_portrait_des
                        progress = camera.rankColor/34
                        infoText = String.init(format: "%.1f", camera.rankColor).appending(" bits")
                    }else if deviceType == .lens {
                        //transmission
                        leftText = LocalizedString.database_lens_transmission
                        progress = 1-lens.tstop/2
                        infoText = String.init(format: "%.1f", lens.tstop).appending(" TStop")
                    }
                case 2:
                    if deviceType == .camera {
                        //Landscape
                        leftText = LocalizedString.camera_detail_landscape_des
                        progress = camera.rankDyn/20
                        infoText = String.init(format: "%.1f", camera.rankDyn).appending(" Evs")
                    }else if deviceType == .lens {
                        //Distortion
                        leftText = LocalizedString.database_lens_distortion
                        progress = 1-lens.distorsion/0.13
                        infoText = String.init(format: "%.3f", lens.distorsion).appending(" %")
                    }
                case 3:
                    if deviceType == .camera {
                        //sports
                        leftText = LocalizedString.camera_detail_sports_des
                        progress = Float(camera.rankLln)/5200
                        infoText = String.init(format: "%d", camera.rankLln).appending(" ISO")
                    }else if deviceType == .lens {
                        //Vignetting
                        leftText = LocalizedString.database_lens_vignetting
                        progress = 1+lens.vignetting/5.8
                        infoText = String.init(format: "%.1f", lens.vignetting).appending(" EV")
                    }
                case 4:
                    if deviceType == .lens {
                        //aberration
                        leftText = LocalizedString.database_lens_aberration
                        progress = 1-lens.ac/3.78
                        infoText = String.init(format: "%.1f", lens.ac).appending(" um")
                    }
                default:
                    break
                }

                tCell?.leftLabel.text = leftText
                tCell?.updateProgress(progress: progress)
                tCell?.rightLabel.text = infoText

                cell = tCell
            }else if indexPath.section == specifications_section {
                var specification:Device.Specification?
                if deviceType == .camera {
                    guard let sep:Device.Specification = self.camera.specification?.safeGet(at: indexPath.row) else {
                        let cell:RXBlankTableViewCell = RXBlankTableViewCell(reuseIdentifier: nil)
                        #if DEBUG || debug
                            cell.infoLabel.text = "can not get camera specifications"
                        #endif
                        return cell
                    }
                    specification = sep
                }else if deviceType == .lens {
                    guard let sep:Device.Specification = self.lens.specification?.safeGet(at: indexPath.row) else {
                        let cell:RXBlankTableViewCell = RXBlankTableViewCell(reuseIdentifier: nil)
                        #if DEBUG || debug
                            cell.infoLabel.text = "can not get camera specifications"
                        #endif
                        return cell
                    }
                    specification = sep
                }
                var tCell:DeviceDetailSpecificationsTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "DeviceDetailSpecificationsTableViewCell") as? DeviceDetailSpecificationsTableViewCell
                if tCell == nil {
                    tCell = DeviceDetailSpecificationsTableViewCell(style: .default, reuseIdentifier: "DeviceDetailSpecificationsTableViewCell")
                }
                tCell?.leftLabel.text = specification?.c_localizedKey
                tCell?.rightLabel.text = specification?.c_localizedValue
                cell = tCell
            }
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if deviceType == .camera {
            if indexPath.section == specifications_section {
                guard let sep:Device.Specification = self.camera.specification?.safeGet(at: indexPath.row) else{
                    return
                }
                print(sep.description)
            }

            #if DEBUG || debug
                
            #endif

        }else if deviceType == .lens {

        }
    }

}
