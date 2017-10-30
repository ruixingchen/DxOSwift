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

    var cacheSize:UInt?

    override func initFunction() {
        super.initFunction()
        self.title = LocalizedString.title_settings

//        sectionTitles.append(Define.section_common)
        sectionTitles.append(Define.section_cache)

        for i in sectionTitles {
            var rowTitle:[String] = []
            switch i {
            case Define.section_common:
                rowTitle.append(Define.row_hd_image_in_database)
                rowTitle.append(Define.row_mobile_review_language)
            case Define.section_cache:
                rowTitle.append(Define.row_clear_cahce)
            default:
                break
            }
            rowTitles.append(rowTitle)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func firstViewDidAppear(_ animated: Bool) {
        super.firstViewDidAppear(animated)
        KingfisherManager.shared.cache.calculateDiskCacheSize {[weak self] (size) in
            //async after one second, I want the user to find the transition
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1)) {
                log.verbose("image cache size: \(size)")
                self?.cacheSize = size
                //MARK: - Change this if we change the section of tableView content
                self?.tableView.reloadData()
            }
        }
    }

    override func initTableView() -> UITableView {
        return UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return rowTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowTitles.safeGet(at: section)?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let sectionTitle:String = sectionTitles.safeGet(at: section) else {
            return nil
        }
        var localizedTitle:String?

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
        var accessoryView:UIView?
        var accessoryType:UITableViewCellAccessoryType? = UITableViewCellAccessoryType.disclosureIndicator

        if sectionTitle == Define.section_common {
            if rowTitle == Define.row_mobile_review_language {
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
            }else if rowTitle == Define.row_hd_image_in_database {
                titleText = LocalizedString.settings_row_database_hd_image
                let switcher:IndexPathSwitch = IndexPathSwitch()
                switcher.indexPath = indexPath
                switcher.isOn = SettingsManager.databaseHDImage
                switcher.addTarget(self, action: #selector(switchValueChanged(sender:)), for: UIControlEvents.valueChanged)
                accessoryView = switcher
                accessoryType = UITableViewCellAccessoryType.none
            }
        }else if sectionTitle == Define.section_cache {
            if rowTitle == Define.row_clear_cahce {
                titleText = LocalizedString.settings_row_clear_cache
                if self.cacheSize == nil {
                    accessoryView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                    (accessoryView as? UIActivityIndicatorView)?.startAnimating()
                    accessoryType = nil
                }else{
                    detailText = "\(cacheSize!/1024)KB"
                }
            }
        }

        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
        }

        cell?.textLabel?.text = titleText
        cell?.detailTextLabel?.text = detailText
        if accessoryView != nil {
            cell?.accessoryType = .none
            cell?.accessoryView = accessoryView
        }else {
            cell?.accessoryView = nil
            cell?.accessoryType = accessoryType ?? UITableViewCellAccessoryType.none
        }

        return cell!
    }

    /// the normal text cell
//    func tableView(_ tableView: UITableView, textCellForRowAt indexPath: IndexPath, sectionTitle:String, rowTitle:String) -> UITableViewCell {
//
//    }

    /// the switch cell
//    func tableView(_ tableView: UITableView, switchCellForRowAt indexPath: IndexPath, sectionTitle:String, rowTitle:String) -> UITableViewCell {
//
//    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let rowTitle:String = rowTitles.safeGet(at: indexPath.section)?.safeGet(at: indexPath.row) else {
            log.error("can not get row title, indexPath:\(indexPath), titles:\(rowTitles)")
            return
        }
        if rowTitle == Define.row_mobile_review_language {
            self.tableView(tableView, didSelectMobileReviewLanguageAt: indexPath)
        }else if rowTitle == Define.row_clear_cahce {
            self.tableView(tableView, didSelectClearCacheAt: indexPath)
        }
    }

    func tableView(_ tableView:UITableView, didSelectMobileReviewLanguageAt indexPath:IndexPath) {
        let alert:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
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
        let cancelAction:UIAlertAction = UIAlertAction(title: LocalizedString.title_cancel, style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(systemAction)
        alert.addAction(englishAction)
        alert.addAction(chineseAction)
        alert.addAction(cancelAction)
        let idiom:UIUserInterfaceIdiom = UIDevice.current.userInterfaceIdiom
        if idiom == UIUserInterfaceIdiom.phone {
            self.present(alert, animated: true, completion: nil)
        }else if idiom == UIUserInterfaceIdiom.pad {

        }
    }

    func tableView(_ tableView:UITableView, didSelectClearCacheAt indexPath:IndexPath) {
        if self.cacheSize == nil {
            return
        }
        let alert:UIAlertController = UIAlertController(title: nil, message: LocalizedString.settings_clear_cache_warning_message, preferredStyle: UIAlertControllerStyle.actionSheet)
        let confirmAction:UIAlertAction = UIAlertAction(title: LocalizedString.settings_confirm_clear_cache, style: UIAlertActionStyle.destructive, handler: {[weak self] (action) in
            KingfisherManager.shared.cache.clearDiskCache(completion: {
                DispatchQueue.main.async {
                    self?.cacheSize = 0
                    self?.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                }
            })
        })
        let cancelAction:UIAlertAction = UIAlertAction(title: LocalizedString.title_cancel, style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
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
            if rowTitle == Define.row_hd_image_in_database {
                SettingsManager.databaseHDImage = sender.isOn
            }
        }

    }

}

extension SettingsController {
    struct Define {
        static let section_common:String = "section_common"
        static let row_hd_image_in_database:String = "row_database_hd_image"
        static let row_mobile_review_language:String = "row_mobile_review_language"

        static let section_cache:String = "section_cache"
        static let row_clear_cahce:String = "row_clear_cache"
    }

}
