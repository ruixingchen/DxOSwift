//
//  StringExtension.swift
//  DXOSwift
//
//  Created by ruixingchen on 17/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

extension String {


    /// get the abstract of this string
    ///
    /// - Parameter length: the length of charactors you want to keep
    /// - Returns: the abstract
    func abstract(length:Int = 20)->String{
        if self.characters.count <= length {
            return self
        }
        var str:String = String(self[...self.index(self.startIndex, offsetBy: length)])
        str.append("...")
        return str
    }

    public func toInt() -> Int? {
        if let num: NSNumber = NumberFormatter().number(from: self) {
            return num.intValue
        } else {
            return nil
        }
    }

    public func toDouble() -> Double? {
        if let num: NSNumber = NumberFormatter().number(from: self) {
            return num.doubleValue
        } else {
            return nil
        }
    }

    public func toFloat() -> Float? {
        if let num: NSNumber = NumberFormatter().number(from: self) {
            return num.floatValue
        } else {
            return nil
        }
    }

    /// true/false, 1/0, 真/假
    public func toBool() -> Bool? {
        let trimmedString: String = trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch trimmedString {
        case "true", "1", "真":
            return true
        case "false", "0", "假":
            return false
        default:
            return nil
        }
    }

    /// calculate the height of string
    func height(_ width: CGFloat, font: UIFont, paragraphStyle: NSParagraphStyle? = nil) -> CGFloat {
        let size: CGSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        return ceil(self.size(size, font: font, paragraphStyle: paragraphStyle).height)
    }

    /// calculate the width of string
    func width(_ height: CGFloat = CGFloat.greatestFiniteMagnitude, font: UIFont, paragraphStyle: NSParagraphStyle? = nil) -> CGFloat {
        let size: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        return ceil(self.size(size, font: font, paragraphStyle: paragraphStyle).width)
    }

    /// calculate the size of string
    func size(_ size: CGSize, font: UIFont, paragraphStyle: NSParagraphStyle? = nil) -> CGSize {
        var attrib: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: font]
        if paragraphStyle != nil {
            attrib.updateValue(paragraphStyle!, forKey: NSAttributedStringKey.paragraphStyle)
        }
        return (self as NSString).boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes:attrib, context: nil).size
    }

    /// is this string an URL?
    func isUrl() -> Bool {
        let detector: NSDataDetector? = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let first: NSTextCheckingResult? = detector?.firstMatch(in: self, options: .withTransparentBounds, range: NSMakeRange(0, self.characters.count))
        if first?.range.location == 0 && first?.range.length == self.characters.count {
            return true
        }
        return false
    }

}
