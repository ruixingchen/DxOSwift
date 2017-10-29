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
import FMDB
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
        #if DEBUG || debug
        static let logRequestDetail:Bool = false

        static let fakeNews:Bool = false
        static let fakeNewsFile:String = "newsSample.html"

        static let fakeMainPage:Bool = false
        static let fakeMainPageFile:String = "mainPageSample.html"

        static let fakeTestedCamera:Bool = false
        static let fakeTestedCameraFile:String = "testedCamera.json"

        static let fakeTestedLens:Bool = false
        static let fakeTestedLensFile:String = "testedLens.json"

        #endif
    }

    #if DEBUG || debug
    static let commonTimeoutInterval:Double = 30
    #else
    static let commonTimeoutInterval:Double = 30
    #endif

    static let reviewListCacheTableName:String = "reviewListCache"

    class func commonURLRequest(url:URL)->URLRequest{
        return URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: commonTimeoutInterval)
    }

    //MARK: - BasicRequest

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
            #if DEBUG || debug
                if Define.logRequestDetail {
                    //log the detail
                }
            #endif
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

    /// request for a review list, suitable for multi pages
    class func commonReviewList(request:URLRequest, completion:(([Review]?, RXError?)->Void)?){
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
        serviceRequest(request: request) { (inData, inError) in
            handleClosure(inData, inError)
        }
    }

    //MARK: - Extract

    /// extract the review list from HTML, if there is no Review in it, returns an empty array
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
            #if DEBUG || debug
                if Define.logRequestDetail {
                    log.verbose(review.description)
                }
            #endif
            reviewList.append(review)
        }
        return reviewList
    }

    /// extract the main page top topic
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

    //MARK: - Request

    /// get the main page top topic and review list
    ///
    /// - Parameter completion: the first is top topic, the second is review list
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

            DispatchQueue.global().async {
                let queue:FMDatabaseQueue = FMDatabaseQueue(path: DatabaseManager.shared.dbPath)
                queue.inTransaction({ (db, rollback) in
                    do {
                        try db.executeUpdate("DELETE FROM \(reviewListCacheTableName) WHERE for_source_list='MainPage'", values: nil)
                        var htmlInsert:Any!
                        if let str = String.init(data: inData!, encoding: .utf8) {
                            htmlInsert = str
                        }else {
                            htmlInsert = NSNull()
                        }
                        try db.executeUpdate("INSERT INTO \(reviewListCacheTableName) (for_source_list,addedTime,htmlText) VALUES (?,?,?)", values: ["MainPage", Date().timeIntervalSince1970, htmlInsert])
                    }catch {
                        log.error("insert main page cache failed, error: \(error.localizedDescription)")
                        rollback.pointee = true
                    }
                })
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
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(2)) {
                    let data = Data(forResource: Define.fakeMainPageFile)!
                    handleClosure(data, nil)
                }
                return
            }
        #endif

        let url:URL = URL(string: "https://www.dxomark.com")!
        let request:URLRequest = commonURLRequest(url: url)
        serviceRequest(request: request) { (inData, inError) in
            handleClosure(inData, inError)
        }
    }

    /// the main page data will be stored in local db, read it from this function
    ///
    /// - Parameter completion: the first is top topic, the second is review list
    class func mainPageCached(completion:(([Review]?, [Review]?, RXError?)->Void)?){
        DispatchQueue.global().async {
            var topTopic:[Review]?
            var reviews:[Review]?
            var error:RXError?

            let rs:FMResultSet? = DatabaseManager.shared.mainDB.executeQuery("SELECT * FROM \(reviewListCacheTableName) WHERE for_source_list='TopTopic' ORDER BY addedTime DESC LIMIT 1", withArgumentsIn: [])
            while rs?.next() == true {
                let htmlText:String = rs!.string(forColumn: "htmlText") ?? ""
                if htmlText.isEmpty {
                    log.error("cached main page html text empty")
                    continue
                }
                guard let htmlDocument:HTMLDocument = HTML(html: htmlText, encoding: .utf8) else {
                    log.error("cached main page html to parse failed, htmlText:\(htmlText.abstract(length: 100, addDot: true))")
                    continue
                }
                topTopic = extractTopTopic(htmlDocument: htmlDocument)
                log.verbose("extract top topic with \(topTopic?.count ?? 0)")
                reviews = extractReviewList(htmlDocument: htmlDocument)
                log.verbose("extract reviews with \(reviews?.count ?? 0)")
                break
            }
            if topTopic == nil || reviews == nil {
                error = RXError(description: "can not extract from html")
            }
            completion?(topTopic, reviews, error)
        }

    }

    /// get the news, the first page is the same as main page
    class func news(page:Int, completion:(([Review]?, RXError?)->Void)?){
        let url:URL = URL(string: "https://www.dxomark.com/news/page/\(page)/")!
        let request:URLRequest = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: commonTimeoutInterval)
        commonReviewList(request: request) { (inObject, inError) in
            completion?(inObject, inError)
        }
    }

    class func cameraReview(page:Int, completion:(([Review]?, RXError?)->Void)?) {
        let url:URL = URL(string: "https://www.dxomark.com/category/camera-reviews/page/\(page)/")!
        let request:URLRequest = commonURLRequest(url: url)
        commonReviewList(request: request) { (inObject, inError) in
            completion?(inObject, inError)
        }
    }

    class func lensReview(page:Int, completion:(([Review]?, RXError?)->Void)?) {
        let url:URL = URL(string: "https://www.dxomark.com/category/lens-reviews/page/\(page)/")!
        let request:URLRequest = commonURLRequest(url: url)
        commonReviewList(request: request) { (inObject, inError) in
            completion?(inObject, inError)
        }
    }

    class func mobileReview(page:Int, completion:(([Review]?, RXError?)->Void)?) {
        let url:URL = URL(string: "https://www.dxomark.com/category/mobile-reviews/page/\(page)/")!
        let request:URLRequest = commonURLRequest(url: url)
        commonReviewList(request: request) { (inObject, inError) in
            completion?(inObject, inError)
        }
    }

    class func mobileChart(completion:(([Review]?, RXError?)->Void)?){
        let url:URL = URL(string:"https://www.dxomark.com/category/mobile-reviews")!
        let request:URLRequest = commonURLRequest(url: url)

        serviceRequest(request: request) { (inData, inError) in
            var outError:RXError?
            var outObject:[Review]?

            defer {
                if outError != nil {
                    log.info("request with error:\n\(outError!.description)")
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
            let nodes:XPathObject = htmlDocument.xpath("//div[@id='mobilesTopScoringTab']/div[contains(@class,'listElement')]")
            var reviews:[Review] = []
            for node in nodes {
                let title:String = node.xpath(".//a").first?.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
                let href:String = node.xpath(".//a/@href").first?.text ?? ""
                let score:Int = node.xpath(".//div[@class='deviceScore']").first?.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).toInt() ?? 0
                if title.isEmpty || href.isEmpty || score == 0 {
                    log.info("parse mobile chart failed")
                    continue
                }
                let review:Review = Review(title: title, url: href)
                review.score = score
                reviews.append(review)
            }
            outObject = reviews
        }
    }

    class func articles(completion:(([Review]?, RXError?)->Void)?){
        let url:URL = URL(string: "https://www.dxomark.com/category/articles/")!
        let request:URLRequest = commonURLRequest(url: url)
        commonReviewList(request: request) { (inObject, inError) in
            completion?(inObject, inError)
        }
    }

    class func testedCamera(completion:((CameraDatabaseDataSource?, RXError?)->Void)?){
        let handleClosure:(Data?, ServiceError?)->Void = { (inData, inError) in
            var outError:RXError?
            var outObject:CameraDatabaseDataSource?
            defer {
                if outError != nil {
                    log.info("cameraDatabase request with error:\n\(outError!.description)")
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
            let json:JSON = JSON.init(data: inData!)
            let dataSource:CameraDatabaseDataSource = CameraDatabaseDataSource()
            dataSource.reloadTestedCamera(jsonObject: json)
            guard dataSource.testedCameraReady else {
                outError = RXError(description: "can not extract any Camera from JSON")
                return
            }
            outObject = dataSource
        }

        #if DEBUG
            if Define.fakeTestedCamera {
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(2)) {
                    let data = Data(forResource: Define.fakeTestedCameraFile)!
                    handleClosure(data, nil)
                }
                return
            }
        #endif

        let url:URL = URL(string: "https://www.dxomark.com/daksensor/ajax/jsontested")!
        var request:URLRequest = commonURLRequest(url: url)
//        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        serviceRequest(request: request) { (inData, inError) in
            handleClosure(inData, inError)
        }
    }

    class func testedLens(completion:((LensDatabaseDataSource?, RXError?)->Void)?){

        #if DEBUG
            if Define.fakeTestedLens {
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(2)) {
                    let data = Data(forResource: Define.fakeTestedLensFile)!
//                    handleClosure(data, nil)
                }
                return
            }
        #endif
    }

    class func presearch(key:String, userInfo:UserInfo? = nil, completion:(([PresearchObject]?, UserInfo?, RXError?)->Void)?){
        let handleClosure:(Data?, UserInfo?, ServiceError?)->Void = { (inData, inUserInfo, inError) in
            var outError:RXError?
            var outObject:[PresearchObject]?
            var outUserInfo:UserInfo? = inUserInfo

            defer {
                if outError != nil {
                    log.info("request with error:\n\(outError!.description)")
                }
                completion?(outObject, outUserInfo, outError)
            }

            if inError != nil {
                outError = RXError(error: inError!, errorDescription: "in error is not nil")
                return
            }else if inData == nil {
                outError = RXError(error: ServiceError.noResponse, errorDescription: "in data is nil")
                return
            }

            let json:JSON = JSON.init(data: inData!)["suggestions"]
            var presearchObjects:[PresearchObject] = []
            for i in json.arrayValue {
                if let object:PresearchObject = PresearchObject(fromJson: i) {
                    presearchObjects.append(object)
                }
            }
            outObject = presearchObjects
        }
        if let percentKey:String = key.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) {
            let url:URL = URL(string: "https://www.dxomark.com/wp-admin/admin-ajax.php?action=flatsome_ajax_search_products&query=\(percentKey)")!
            let request:URLRequest = commonURLRequest(url: url)
            serviceRequest(request: request) { (inData, inError) in
                handleClosure(inData, userInfo, inError)
            }
        }else {
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1)) {
                handleClosure(nil, userInfo, ServiceError.badUrl)
            }
        }
    }

    class func search(key:String, page:Int, userInfo:UserInfo? = nil, completion:(([Review]?, UserInfo?, RXError?)->Void)?){
        if let percentKey:String = key.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) {
            let url:URL = URL(string: "https://www.dxomark.com/page/\(page)/?s=\(percentKey)")!
            let request:URLRequest = commonURLRequest(url: url)
            commonReviewList(request: request) { (inObject, inError) in
                completion?(inObject, userInfo, inError)
            }
        }else {
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1)) {
                completion?(nil, userInfo, RXError(description: "key add percent failed"))
            }
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
