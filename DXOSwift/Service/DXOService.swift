//
//  DXOService.swift
//  DXOSwift
//
//  Created by ruixingchen on 17/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation
import Kanna
import SwiftyJSON
#if DEBUG || debug
    import netfox
#endif

enum ServiceError:Error {
    case badUrl
//    case sendFailed //request send failed
    case requestFailed //session calls an error
    case noResponse //the data is nil, but session does not calls any error
    case badResponse //the response format error
    case serverError //server returns an error
    case unknown
}

class DXOService {

    struct Define {
        static let logRequestDetail:Bool = false

        static let fakeNews:Bool = false
        static let fakeNewsFile:String = "newsSample.html"

        static let fakeMainPage:Bool = false
        static let fakeMainPageFile:String = "mainPageSample.html"

        static let fakeCameraReview:Bool = false
        static let fakeCameraReviewFile:String = ""

        static let fakeTestedCamera:Bool = true
        static let fakeTestedCameraFile:String = "testedCamera.json"
    }

    /// the basic request
    class func basicRequest(request:URLRequest, completion:((Data?, Error?)->Void)?){
        let sessionConfig:URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = request.timeoutInterval
        sessionConfig.timeoutIntervalForResource = request.timeoutInterval
        #if DEBUG || debug
            sessionConfig.protocolClasses?.insert(NFXProtocol.self, at: 0)
        #endif
        let session:URLSession = URLSession(configuration: sessionConfig)
        session.dataTask(with: request) { (inData, inResponse, inError) in
            if Define.logRequestDetail {
                //log the detail
            }
            completion?(inData, inError)
        }.resume()
    }

    /// request with ServiceError
    class func serviceRequest(request:URLRequest, completion:((Data?, ServiceError?)->Void)?){
        basicRequest(request: request) { (inData, inError) in
            var outError:ServiceError?

            defer {
                completion?(inData, outError)
            }

            if inError != nil {
                outError = ServiceError.requestFailed
                return
            }else if inData == nil {
                outError = ServiceError.noResponse
                return
            }
        }
    }

    class func extractReviewList(htmlDocument:HTMLDocument)->[Review]{
        let newsNodes:XPathObject = htmlDocument.xpath("//div[contains(@class, 'col post-item')]")
        var reviewList:[Review] = []
        for newsNode in newsNodes {
            let title:String = newsNode.xpath(".//h5[contains(@class,'post-title')]/text()").first?.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
            var targetUrl:String = newsNode.xpath(".//a[@class='plain']/@href").first?.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
             ?? ""
            if !targetUrl.isEmpty && !targetUrl.hasPrefix("http") {
                targetUrl = "https://www.dxomark.com" + targetUrl
            }
            if title.isEmpty || targetUrl.isEmpty {
                continue
            }

            let postTime:String? = newsNode.xpath(".//div[contains(@class,'post-meta')]/text()").first?.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let abstract:String? = newsNode.xpath(".//p[contains(@class,'excerpt')]/text()").first?.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let coverImage:String? = newsNode.xpath(".//div[contains(@class,'image-cover')]/img/@data-src").first?.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

            let commentNumLabel:String = newsNode.xpath(".//div[contains(@class,'blog-post-inner')]/p[contains(@class,'from_the_blog_comments')]/text()").first?.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
            var commentNum:Int = 0
            if !commentNumLabel.isEmpty {
                commentNum = commentNumLabel.replacingOccurrences(of: " comments", with: "", options: String.CompareOptions.backwards, range: nil).toInt() ?? 0
            }
            var deviceType:ReviewDeviceType?
            var score:Int = 0
            if let scoreBadgeNode:XMLElement = newsNode.xpath(".//div[contains(@class,'box-image')]/div[contains(@class,'scoreBadge')]").first {
                if let scoreBadgeNodeClass:String = scoreBadgeNode.xpath("./@class").first?.text?.lowercased() {
                    if scoreBadgeNodeClass.contains("lens") {
                        deviceType = ReviewDeviceType.lens
                    }else if scoreBadgeNodeClass.contains("camera") {
                        deviceType = ReviewDeviceType.camera
                    }else if scoreBadgeNodeClass.contains("mobile") {
                        deviceType = ReviewDeviceType.mobile
                    }
                }
                if let scoreText:String = scoreBadgeNode.xpath(".//div[@class='scoreBadgeValue']/text()").first?.text {
                    score = scoreText.toInt() ?? 0
                }
            }

            let review:Review = Review(title: title, url: targetUrl)
            review.postTime = postTime
            review.abstract = abstract
            review.coverImage = coverImage
            review.commentNum = commentNum
            review.deviceType = deviceType
            review.score = score

            let categoryNodes:XPathObject = newsNode.xpath(".//div[contains(@class,'blog-post-inner')]/p[contains(@class,'cat-label')]/text()")
            for categoryNode in categoryNodes {
                let text:String = categoryNode.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
                if text.isEmpty {
                    continue
                }
                review.category.append(text)
            }

            let tagNodes:XPathObject = newsNode.xpath(".//div[contains(@class,'blog-post-inner')]/div[@class='tags']/span[contains(@class, 'tag-label')]/text()")
            for tagNode in tagNodes {
                let text:String = tagNode.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
                if text.isEmpty {
                    continue
                }
                review.tag.append(text)
            }
            if Define.logRequestDetail {
                log.verbose(review.description)
            }
            reviewList.append(review)
        }
        return reviewList
    }

    class func extractTopTopic(htmlDocument:HTMLDocument)->[Review]{
        let newsNodes:XPathObject = htmlDocument.xpath("//div[contains(@class,'banner-grid') and contains(@id,'banner-grid')]/div[contains(@class,'col')]")
        var reviewList:[Review] = []
        for newsNode in newsNodes {
            var title:String = newsNode.xpath(".//div[contains(@class,'text')]/div[contains(@class,'text-inner')]").first?.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
            if !title.isEmpty {
                title = title.replacingOccurrences(of: "\n", with: " ")
            }
            var targetUrl:String = newsNode.xpath(".//a[contains(@class,'fill')]/@href").first?.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
            if !targetUrl.isEmpty {
                if !targetUrl.hasPrefix("http") {
                    targetUrl = "https://www.dxomark.com" + targetUrl
                }
            }
//background-image: url(https://cdn.dxomark.com/wp-content/uploads/2017/10/google_pixel2_block.png)
            var coverImage:String?
            if let styleCSSString:String = newsNode.xpath(".//div[contains(@class,'banner')]/style[@scope='scope' and contains(text(), 'background-image')]").first?.text {
                let backgroundImageReg:NSRegularExpression = try! NSRegularExpression(pattern: "(http|https).*?\\.(png|jpg|jpeg|gif)", options: NSRegularExpression.Options.caseInsensitive)
                if let imageUrlRegResult = backgroundImageReg.firstMatch(in: styleCSSString, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, styleCSSString.count)) {
                    coverImage = (styleCSSString as NSString).substring(with: imageUrlRegResult.range)
                }
            }

            let review:Review = Review(title: title, url: targetUrl)
            review.coverImage = coverImage
            reviewList.append(review)
        }
        return reviewList
    }

    /// request for a review list, suitable for multi pages
    class func commonReviewList(urlString:String, completion:(([Review]?, RXError?)->Void)?){
        let handleClosure:(Data?, ServiceError?)->Void = { (inData, inError) in
            var outError:RXError?
            var outObject:[Review]?

            defer {
                if outError != nil {
                    log.info("news request with error:\n\(outError!.description)")
                }
                completion?(outObject, outError)
            }

            if inError != nil {
                outError = RXError(error: inError!, errorDescription: "in error is not nil")
                return
            }else if inData == nil {
                outError = RXError(error: ServiceError.noResponse, errorDescription: "in data is nil")
                return
            }
            //start to parse the HTML document
            guard let htmlDocument:HTMLDocument = HTML(html: inData!, encoding: .utf8) else {
                outError = RXError(error: ServiceError.badResponse, errorDescription: "bad html response")
                return
            }
            //we only parse news here
            let reviews:[Review] = extractReviewList(htmlDocument: htmlDocument)
            log.verbose("extract reviews with \(reviews.count)")
            outObject = reviews
        }

        #if DEBUG
            if Define.fakeNews {
                DispatchQueue.global().async {
                    let data = Data(forResource: Define.fakeNewsFile)!
                    handleClosure(data, nil)
                }
                return
            }
        #endif

        let url:URL = URL(string: "https://www.dxomark.com/news/page/\(page)/")!
        let request:URLRequest = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 30)
        serviceRequest(request: request) { (inData, inError) in
            handleClosure(inData, inError)
        }
    }

    /// get the main page content and the top topic
    class func mainPage(completion:(([Review]?, [Review]?, RXError?)->Void)?){
        let handleClosure:(Data?, ServiceError?)->Void = { (inData, inError) in
            var outError:RXError?
            var outTopObject:[Review]?
            var outObject:[Review]?

            defer {
                if outError != nil {
                    log.info("mainPage request with error:\n\(outError!.description)")
                }
                completion?(outTopObject, outObject, outError)
            }

            if inError != nil {
                outError = RXError(error: inError!, errorDescription: "in error is not nil")
                return
            }else if inData == nil {
                outError = RXError(error: ServiceError.noResponse, errorDescription: "in data is nil")
                return
            }
            //start to parse the HTML document
            guard let htmlDocument:HTMLDocument = HTML(html: inData!, encoding: .utf8) else {
                outError = RXError(error: ServiceError.badResponse, errorDescription: "bad html response")
                return
            }

            let topTopics:[Review] = extractTopTopic(htmlDocument: htmlDocument)
            log.verbose("extract top topic with \(topTopics.count)")
            outTopObject = topTopics
            let reviews:[Review] = extractReviewList(htmlDocument: htmlDocument)
            log.verbose("extract reviews with \(reviews.count)")
            outObject = reviews
        }

        #if DEBUG
            if Define.fakeMainPage {
                DispatchQueue.global().async {
                    let data = Data(forResource: Define.fakeMainPageFile)!
                    handleClosure(data, nil)
                }
                return
            }
        #endif

        let url:URL = URL(string: "https://www.dxomark.com")!
        let request:URLRequest = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 30)
        serviceRequest(request: request) { (inData, inError) in
            handleClosure(inData, inError)
        }
    }

    /// get the news, the first page is the same as main page
    class func news(page:Int, completion:(([Review]?, RXError?)->Void)?){

        let handleClosure:(Data?, ServiceError?)->Void = { (inData, inError) in
            var outError:RXError?
            var outObject:[Review]?

            defer {
                if outError != nil {
                    log.info("news request with error:\n\(outError!.description)")
                }
                completion?(outObject, outError)
            }

            if inError != nil {
                outError = RXError(error: inError!, errorDescription: "in error is not nil")
                return
            }else if inData == nil {
                outError = RXError(error: ServiceError.noResponse, errorDescription: "in data is nil")
                return
            }
            //start to parse the HTML document
            guard let htmlDocument:HTMLDocument = HTML(html: inData!, encoding: .utf8) else {
                outError = RXError(error: ServiceError.badResponse, errorDescription: "bad html response")
                return
            }
            //we only parse news here
            let reviews:[Review] = extractReviewList(htmlDocument: htmlDocument)
            log.verbose("extract reviews with \(reviews.count)")
            outObject = reviews
        }

        #if DEBUG
            if Define.fakeNews {
                DispatchQueue.global().async {
                    let data = Data(forResource: Define.fakeNewsFile)!
                    handleClosure(data, nil)
                }
                return
            }
        #endif

        let url:URL = URL(string: "https://www.dxomark.com/news/page/\(page)/")!
        let request:URLRequest = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 30)
        serviceRequest(request: request) { (inData, inError) in
            handleClosure(inData, inError)
        }
    }

    class func cameraReview(page:Int, completion:(([Review]?, RXError?)->Void)?) {
        let handleClosure:(Data?, ServiceError?)->Void = { (inData, inError) in
            var outError:RXError?
            var outObject:[Review]?

            defer {
                if outError != nil {
                    log.info("cameraReview request with error:\n\(outError!.description)")
                }
                completion?(outObject, outError)
            }

            if inError != nil {
                outError = RXError(error: inError!, errorDescription: "in error is not nil")
                return
            }else if inData == nil {
                outError = RXError(error: ServiceError.noResponse, errorDescription: "in data is nil")
                return
            }
            //start to parse the HTML document
            guard let htmlDocument:HTMLDocument = HTML(html: inData!, encoding: .utf8) else {
                outError = RXError(error: ServiceError.badResponse, errorDescription: "bad html response")
                return
            }
            let reviews:[Review] = extractReviewList(htmlDocument: htmlDocument)
            log.verbose("extract reviews with \(reviews.count)")
            outObject = reviews
        }

        #if DEBUG
            if Define.fakeCameraReview {
                DispatchQueue.global().async {
                    let data = Data(forResource: Define.fakeCameraReviewFile)!
                    handleClosure(data, nil)
                }
                return
            }
        #endif

        let url:URL = URL(string: "https://www.dxomark.com/category/camera-reviews/page/\(page)/")!
        let request:URLRequest = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 30)
        serviceRequest(request: request) { (inData, inError) in
            handleClosure(inData, inError)
        }
    }

    class func testedCamera(completion:((RXError?)->Void)?){
        let handleClosure:(Data?, ServiceError?)->Void = { (inData, inError) in
            var outError:RXError?
            var outObject:[Camera]?

            defer {
                if outError != nil {
                    log.info("cameraDataBase request with error:\n\(outError!.description)")
                }
                completion?(outError)
            }

            if inError != nil {
                outError = RXError(error: inError!, errorDescription: "in error is not nil")
                return
            }else if inData == nil {
                outError = RXError(error: ServiceError.noResponse, errorDescription: "in data is nil")
                return
            }
            let json:JSON = JSON.init(data: inData!)
            CameraManager.shared.reloadTestedCamera(jsonObject: json)
        }

        #if DEBUG
            if Define.fakeTestedCamera {
                DispatchQueue.global().async {
                    let data = Data(forResource: Define.fakeTestedCameraFile)!
                    handleClosure(data, nil)
                }
                return
            }
        #endif

        let url:URL = URL(string: "https://www.dxomark.com/daksensor/ajax/jsontested")!
        let request:URLRequest = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 30)
        serviceRequest(request: request) { (inData, inError) in
            handleClosure(inData, inError)
        }
    }

}

extension DXOService {

    class func cpmpleteURLWithPath(path:String)->String {
        if path.hasPrefix("http") {
            return path
        }
        if path.hasPrefix("/"){
            return "https://www.dxomark.com".appending(path)
        }else{
            return "https://www.dxomark.com/".appending(path)
        }
    }

}
