//
//  SettingsController.swift
//  DXOSwift
//
//  Created by ruixingchen on 23/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import Kingfisher

class SettingsController: RXTableViewController {

    var sectionTitles:[String] = []
    var rowTitles:[[String]] = []

    var cachedImageSize:UInt?
    var clearCacheCellIndexPath:IndexPath?

    override func initFunction() {
        super.initFunction()
        self.title = LocalizedString.title_settings

        sectionTitles.append(Define.section_common)
        sectionTitles.append(Define.section_cache)
        #if DEBUG || debug
            sectionTitles.append(Define.section_debug)
        #endif

        for i in sectionTitles {
            var rowTitle:[String] = []
            switch i {
            case Define.section_common:
                rowTitle.append(Define.row_common_hd_image_in_database)
                rowTitle.append(Define.row_common_mobile_review_language)
            case Define.section_cache:
                rowTitle.append(Define.row_cache_clear_cahce)
            case Define.section_debug:
                #if DEBUG || debug
                    rowTitle.append(Define.row_debug_ignore_cache)
                    rowTitle.append(Define.row_debug_log_request)
                #endif
            default:
                break
            }
            rowTitles.append(rowTitle)
        }
    }

    override func initTableView() -> UITableView {
        return UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func firstViewDidAppear(_ animated: Bool) {
        super.firstViewDidAppear(animated)
        KingfisherManager.shared.cache.calculateDiskCacheSize {[weak self] (size) in
            //async after one second, I want the user to notice the transition
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1)) {
                log.verbose("image cache size: \(size)")
                self?.cachedImageSize = size
                if self?.clearCacheCellIndexPath == nil {
                    self?.tableView.reloadData()
                }else{
                    self?.tableView.reloadRows(at: [self!.clearCacheCellIndexPath!], with: UITableViewRowAnimation.automatic)
                }
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return rowTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowTitles.safeGet(at: section)?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionTitle:String = sectionTitles.safeGet(at: section) else {
            return nil
        }
        var localizedTitle:String?

        switch sectionTitle {
        case Define.section_common:
            break
        case Define.section_cache:
            break
        case Define.section_debug:
            #if DEBUG || debug
                localizedTitle = "DEBUG"
            #else
                break
            #endif
        default:
            break
        }
        return localizedTitle
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let sectionTitle:String = sectionTitles.safeGet(at: section) else {
            return nil
        }
        var localizedTitle:String?

        switch sectionTitle {
        case Define.section_common:
            break
        case Define.section_cache:
            break
        case Define.section_debug:
            #if DEBUG || debug
                localizedTitle = nil
            #else
                break
            #endif
        default:
            break
        }
        return localizedTitle
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionTitle:String = sectionTitles.safeGet(at: indexPath.section) else {
            let cell = RXBlankTableViewCell(reuseIdentifier: nil)
            #if DEBUG || debug
                cell.infoLabel.text = "can not get section title"
            #endif
            return cell
        }
        guard let rowTitle:String = rowTitles.safeGet(at: indexPath.section)?.safeGet(at: indexPath.row) else {
            let cell = RXBlankTableViewCell(reuseIdentifier: nil)
            #if DEBUG || debug
                cell.infoLabel.text = "can not get row title"
            #endif
            return cell
        }

        var titleText:String?
        var detailText:String?
        var accessoryType:UITableViewCellAccessoryType = UITableViewCellAccessoryType.disclosureIndicator
        var accessoryView:UIView?
        var selectionStyle:UITableViewCellSelectionStyle = UITableViewCellSelectionStyle.default

        if sectionTitle == Define.section_common {
            if rowTitle == Define.row_common_hd_image_in_database {
                titleText = LocalizedString.settings_row_database_hd_image
                let switcher:IndexPathSwitch = IndexPathSwitch()
                switcher.addTarget(self, action: #selector(switchValueChanged(sender:)), for: UIControlEvents.valueChanged)
                switcher.indexPath = indexPath
                switcher.isOn = SettingsManager.databaseHDImage
                accessoryView = switcher
                selectionStyle = UITableViewCellSelectionStyle.none
            }else if rowTitle == Define.row_common_mobile_review_language {
                titleText = LocalizedString.settings_row_mobile_review_language
                switch SettingsManager.mobilePreviewLanguage {
                case 1:
                    detailText = LocalizedString.settings_row_mobile_review_language_follow_system
                case 2:
                    detailText = LocalizedString.title_english
                case 3:
                    detailText = LocalizedString.title_chinese
                default:
                    break
                }
                accessoryType = .disclosureIndicator
            }
        }else if sectionTitle == Define.section_cache {
            if rowTitle == Define.row_cache_clear_cahce {
                clearCacheCellIndexPath = indexPath
                titleText = LocalizedString.settings_row_clear_cache
                if self.cachedImageSize == nil {
                    //show indicator
                    let indicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                    indicator.startAnimating()
                    accessoryView = indicator
                }else {
                    //show detail text
                    if cachedImageSize! < 1024 {
                        detailText = LocalizedString.settings_no_cached_image
                    }else {
                        detailText = String.dataSizeAbstract(size: UInt64(cachedImageSize!), decimal: 2)
                    }
                }
            }
        }else if sectionTitle == Define.section_debug {
            #if DEBUG || debug
                if rowTitle == Define.row_debug_ignore_cache {
                    titleText = "Ignore Cache"
                    let switcher:IndexPathSwitch = IndexPathSwitch()
                    switcher.addTarget(self, action: #selector(switchValueChanged(sender:)), for: UIControlEvents.valueChanged)
                    switcher.indexPath = indexPath
                    switcher.isOn = SettingsManager.debug_ignore_cache
                    accessoryView = switcher
                    selectionStyle = UITableViewCellSelectionStyle.none
                }else if rowTitle == Define.row_debug_log_request {
                    titleText = "Log All Requests"
                    let switcher:IndexPathSwitch = IndexPathSwitch()
                    switcher.addTarget(self, action: #selector(switchValueChanged(sender:)), for: UIControlEvents.valueChanged)
                    switcher.indexPath = indexPath
                    switcher.isOn = SettingsManager.debug_log_request
                    accessoryView = switcher
                    selectionStyle = UITableViewCellSelectionStyle.none
                }
            #endif
        }

        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "normal_cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "normal_cell")
        }

        cell?.textLabel?.text = titleText
        cell?.detailTextLabel?.text = detailText
        if accessoryView == nil {
            cell?.accessoryView = nil
            cell?.accessoryType = accessoryType
        }else {
            cell?.accessoryView = accessoryView
        }
        cell?.selectionStyle = selectionStyle

        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let sectionTitle:String = sectionTitles.safeGet(at: indexPath.section) else {
            log.error("can not get section title, indexPath:\(indexPath), titles:\(sectionTitles.count)")
            return
        }
        guard let rowTitle:String = rowTitles.safeGet(at: indexPath.section)?.safeGet(at: indexPath.row) else {
            log.error("can not get row title, indexPath:\(indexPath), titles:\(rowTitles)")
            return
        }

        if sectionTitle == Define.section_common {
            if rowTitle == Define.row_common_mobile_review_language {
                self.tableView(tableView, didSelectAlertRowAt: indexPath, sectionTitle: sectionTitle, rowTitle: rowTitle)
            }
        }else if sectionTitle == Define.section_cache {
            if rowTitle == Define.row_cache_clear_cahce {
                self.tableView(tableView, didSelectAlertRowAt: indexPath, sectionTitle: sectionTitle, rowTitle: rowTitle)
            }
        }else if sectionTitle == Define.section_debug {

        }
    }

    func tableView(_ tableView: UITableView, didSelectAlertRowAt indexPath: IndexPath, sectionTitle:String, rowTitle:String) {
        var actions:[UIAlertAction] = []
        var title:String?
        var message:String?
        var style:UIAlertControllerStyle = UIAlertControllerStyle.alert

        if sectionTitle == Define.section_common {
            if rowTitle == Define.row_common_mobile_review_language {
                let systemAction:UIAlertAction = UIAlertAction(title: LocalizedString.settings_row_mobile_review_language_follow_system, style: UIAlertActionStyle.default, handler: { (action) in
                    SettingsManager.mobilePreviewLanguage = 1
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                })
                let englishAction:UIAlertAction = UIAlertAction(title: LocalizedString.title_english, style: UIAlertActionStyle.default, handler: { (action) in
                    SettingsManager.mobilePreviewLanguage = 2
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                })
                let chineseAction:UIAlertAction = UIAlertAction(title: LocalizedString.title_chinese, style: UIAlertActionStyle.default, handler: { (action) in
                    SettingsManager.mobilePreviewLanguage = 3
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                })
                actions.append(systemAction)
                actions.append(englishAction)
                actions.append(chineseAction)
                title = nil
                style = UIAlertControllerStyle.actionSheet
            }
        }else if sectionTitle == Define.section_cache {
            if rowTitle == Define.row_cache_clear_cahce {
                guard let size = cachedImageSize, size > 1024 else{
                    return
                }
                let confirmAction:UIAlertAction = UIAlertAction(title: LocalizedString.settings_confirm_clear_cache, style: UIAlertActionStyle.destructive, handler: {[weak self] (action) in
                    KingfisherManager.shared.cache.clearDiskCache(completion: {
                        DispatchQueue.main.async {
                            self?.cachedImageSize = 0
                            self?.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                        }
                    })
                })
                actions.append(confirmAction)
                title = nil
                message = LocalizedString.settings_clear_cache_warning_message
                style = UIAlertControllerStyle.actionSheet
            }
        }else if sectionTitle == Define.section_debug {
            #if DEBUG || debug

            #endif
        }

        if actions.isEmpty {
            return
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        for i in actions {
            alert.addAction(i)
        }
        alert.addAction(UIAlertAction(title: LocalizedString.title_cancel, style: UIAlertActionStyle.cancel, handler: nil))
        let idiom:UIUserInterfaceIdiom = UIDevice.current.userInterfaceIdiom
        if idiom == UIUserInterfaceIdiom.phone {
            self.present(alert, animated: true, completion: nil)
        }else if idiom == UIUserInterfaceIdiom.pad {

        }

    }

    @objc func switchValueChanged(sender:IndexPathSwitch){
        guard let indexPath:IndexPath = sender.indexPath else {
            return
        }
        guard let sectionTitle:String = sectionTitles.safeGet(at: indexPath.section) else {
            return
        }
        guard let rowTitle:String = rowTitles.safeGet(at: indexPath.section)?.safeGet(at: indexPath.row) else {
            return
        }

        if sectionTitle == Define.section_common {
            if rowTitle == Define.row_common_hd_image_in_database {
                SettingsManager.databaseHDImage = sender.isOn
            }
        }else if sectionTitle == Define.section_debug {
            #if DEBUG || debug
                if rowTitle == Define.row_debug_ignore_cache {
                    SettingsManager.debug_ignore_cache = sender.isOn
                }else if rowTitle == Define.row_debug_log_request {
                    SettingsManager.debug_log_request = sender.isOn
                }
            #endif
        }
    }

}

extension SettingsController {
    struct Define {
        static let section_common:String = "section_common"
        static let row_common_hd_image_in_database:String = "row_common_database_hd_image"
        static let row_common_mobile_review_language:String = "row_common_mobile_review_language"

        static let section_cache:String = "section_cache"
        static let row_cache_clear_cahce:String = "row_clear_cache"

        static let section_debug:String = "section_debug"
        static let row_debug_ignore_cache:String = "row_debug_ignore_cache"
        static let row_debug_log_request:String = "row_debug_log_request"
    }

}
