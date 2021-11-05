//
//  DetailVideoViewController.swift
//  Tin
//
//  Created by vietnb on 6/19/19.
//  Copyright © 2019 vietnb. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftSoup
import Alamofire
import GoogleMobileAds

import AVFoundation
import WebKit
//import FBSDKShareKit
import MessageUI
import FBSDKCoreKit
//import FacebookLogin

import GoogleInteractiveMediaAds

class DetailVideoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ViewMoreCriticalCollectionViewCellDelegate {
    
    let sizeFontTitle:CGFloat = IS_IPHONE ? 30 : 36
    let sizeFontDescrip:CGFloat = IS_IPHONE ? 20 : 24
    let sizeFontContent:CGFloat = IS_IPHONE ? 20 : 24
    let sizeFontCaption:CGFloat = IS_IPHONE ? 17 : 20
    
    var didLoadRelateArticle = false
    
    //MARK: - Input TextView
    var textInput = DetailInput()
    var currentText = ""

    @objc func endEditting() {
        textInput.textView.resignFirstResponder()
    }

    let contentView = ContentBlurView()
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if textInput.textView.isFirstResponder {
            endEditting()
            return
        }
        if(indexPath.section == 0)
        {
            //print("co vao 1")
            if(indexPath.row > 2)
            {
                if let dictData = arrayContent.object(at: indexPath.row - 3) as? NSDictionary
                {
                    if(dictData.object(forKey: "type") != nil)
                    {
                        let type = dictData.object(forKey: "type") as! String
                        if(type == "img")
                        {
                            let type = dictData.object(forKey: "type") as! String
                            if(type == "img")
                            {
                                guard let imgString = dictData.object(forKey: "src") as? String else {return}
                                var images = [SKPhoto]()
                                for item in arrayListImageNative {
                                    let photo = SKPhoto.photoWithImageURL(item as! String)
                                    photo.shouldCachePhotoURLImage = true
                                    images.append(photo)
                                }
                                
                                let cell = collectionView.cellForItem(at: indexPath) as! ContentNativeCollectionViewCell
                                let img = cell.imageNative.image
                                
                                let browser = SKPhotoBrowser(originImage: img ?? UIImage(), photos: images, animatedFromView: cell)
                                if arrayListImageNative.contains(imgString) {
                                    let index = arrayListImageNative.index(of: imgString)
                                    browser.initializePageIndex(index)
                                } else {
                                    browser.initializePageIndex(0)
                                }
                                
                                browser.delegate = self
                                
                                present(browser, animated: true, completion: {})
                            }
                        }
                    }
                }
            } else if indexPath.row == 1 {
//                self.view.addSubview(contentView)
//                contentView.setOriginFrame()
//                contentView.alpha = 1
//                contentView.snp.makeConstraints { (make) in
//                    make.edges.equalToSuperview()
//                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    self.contentView.animateWebview()
//                }
            }
        }
    }
    
    func gotoContentDocument(document:Any?, indexPath:IndexPath?,fromSource:String, appType:Model_EAppType)
    {
        if let data = document as? Model_Document
        {
            DataTracking.sharedInstance.detectDataTrackingClick(dataDetect: data, pos: UInt32(indexPath!.row), appLocat: "", appType: appType)
            if(data.type == .contentTypeArticles)
            {
                self.gotoContentArticle(data: data, fromSource: fromSource)
            }
            else if(data.type == .contentTypeVideos)
            {
                self.gotoContentVideo(data: data, fromSource: fromSource)
            }
            else if(data.type == .contentTypeSponsors)
            {
                FirebaseAnalyticLog.sharedInstance.logEvent(eventName: READ_ALL_ARTICLE, itemID: data.sponsor.id.description, itemName: "", itemCategory: "", location: READ_SPONSORED_ARTICLE)
                let storyboard = Global.sharedInstance.getMainStoryboard()
                let webKitViewController = storyboard.instantiateViewController(withIdentifier: "WebKitViewController") as! WebKitViewController
                webKitViewController.url = data.sponsor.jumpURL
                
                webKitViewController.strTitle = data.sponsor.title
                self.navigationController?.pushViewController(webKitViewController, animated: true)
            }
            else if(data.type == .contentTypeVote)
            {
                FirebaseAnalyticLog.sharedInstance.logEvent(eventName: RATE_APP, itemID: "", itemName: "", itemCategory: "")
                let link = data.vote.jumpURL
                if(data.vote.type == .inApp)
                {
                    let storyboard = Global.sharedInstance.getMainStoryboard()
                    let webKitViewController = storyboard.instantiateViewController(withIdentifier: "WebKitViewController") as! WebKitViewController
                    webKitViewController.url = link
                    
                    webKitViewController.strTitle = data.vote.title
                    self.navigationController?.pushViewController(webKitViewController, animated: true)
                }
                else
                {
                    if let url = URL(string: link) {
                        // check if your application can open the NSURL instance
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            else if(data.type == .contentTypeUtilities)
            {
                self.gotoUtility(data: data, navigation: self.navigationController)
            }
        }
    }
    
    func gotoContentArticle(data:Model_Document, fromSource:String)
    {
        //vao man hinh detailViewController
        let storyboard = Global.sharedInstance.getMainStoryboard()
        let detailViewController = DetailViewController()
                
        let sid = data.art.sid
        let lid = data.art.lid
        let cid = data.art.cid
        let is_live = data.art.isLive.rawValue
        let link = data.art.url
        let itemTopics = data.art.topics
        
        detailViewController.infoArticleProto = data
                
        detailViewController.nameCategory = Global.sharedInstance.getTopic(sid: Int(sid), cid: Int(cid))!
        
        detailViewController.nameWebsite = Global.sharedInstance.getNameWebsite(sid: Int(sid))!
                        
        var isFade = true
        if(is_live == 1)
        {
            isFade = false
        }
        
        if(isFade == true)
        {
            if !self.dictArrNewsFade.contains(lid)
            {
                self.dictArrNewsFade.append(lid)
            }
        }
        
        if(Global.sharedInstance.getModeInReview() == true)
        {
            if(sid != 3 && sid != 17)
            {
                if let url = URL(string: link) {
                    // check if your application can open the NSURL instance
                    //UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    UIApplication.shared.open(url, options: [:]) { (result) in
                        
                    }
                    return
                }
            }
        }
        
        /////vao bai chi tiet
        FirebaseAnalyticLog.sharedInstance.logEvent(eventName: fromSource, itemID: lid, itemName: Global.sharedInstance.getNameWebsite(sid: Int(sid))!, itemCategory: Global.sharedInstance.getTopic(sid: Int(999), cid: Int(data.art.supercid))!, itemTopics: itemTopics)
        
        FirebaseAnalyticLog.sharedInstance.logEvent(eventName: READ_ALL_ARTICLE, itemID: lid, itemName: Global.sharedInstance.getNameWebsite(sid: Int(sid))!, itemCategory: Global.sharedInstance.getTopic(sid: Int(999), cid: Int(data.art.supercid))!, location: fromSource, itemTopics: itemTopics)
        
        self.navigationController?.pushViewController(viewController: detailViewController, animated: true, completion: {
            self.collectionArticle?.reloadData()
        })
    }
    
    func gotoContentVideo(data:Model_Document, fromSource:String)
    {
        let storyboard = Global.sharedInstance.getMainStoryboard()
        let listVideoShowViewController = storyboard.instantiateViewController(withIdentifier: "ListVideoViewController") as! ListVideoViewController
        listVideoShowViewController.originModelCell = data
        self.navigationController?.pushViewController(listVideoShowViewController, animated: true)
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, layout  collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        
        if(section == 0)
        {
            return CGSize(width: 0, height: 0)
        }
        else if(section == 1)
        {
            //Xem bài gốc
            return CGSize(width: checkLandScape, height: 0)
//            if(IS_IPAD)
//            {
//                return CGSize(width: checkLandScape, height: 88)
//            }
//            return CGSize(width: checkLandScape, height: 44)
        }
        else if(section == 2)
        {
            if(arrayAdsLastArticle.count>0)
            {
                if (arrayAdsLastArticle.lastObject as? AdsGoogleObject) != nil
                {
                    return CGSize(width: checkLandScape, height: ((checkLandScape - 30)*9)/16 + 120)
                }
                else if let objectAds = arrayAdsLastArticle.lastObject as? GAMBannerView
                {
                    return CGSize(width: checkLandScape, height: objectAds.frame.height + 20)
                }
            }
        }
        else if section == 4 {
            if(arrayAdsCenter2.count>0)
            {
                if (arrayAdsCenter2.lastObject as? AdsGoogleObject) != nil
                {
                    return CGSize(width: checkLandScape, height: ((checkLandScape - 30)*9)/16 + 186)
                }
                else if let objectAds = arrayAdsCenter2.lastObject as? GAMBannerView
                {
                    return CGSize(width: checkLandScape, height: objectAds.frame.height + 32)
                }
            }
        }
        else if(section == 3 || section == 7)
        {
            if(section == 3)
            {
                if(arrayArticleRelated.count>0)
                {
                    if(IS_IPAD)
                    {
                        return CGSize(width: checkLandScape, height: arrayAdsLastArticle.count > 0 ? 60 : 80)
                    }
                    return CGSize(width: checkLandScape, height: arrayAdsLastArticle.count > 0 ? 41 : 59)
                }
            }
            else
            {
                if(arrayArticleTopRead.count>0)
                {
                    if(IS_IPAD)
                    {
                        return CGSize(width: checkLandScape, height: 80)
                    }
                    return CGSize(width: checkLandScape, height: 59)
                }
            }
        }
        else if(section == 5)
        {
            if(arrayCommentArticle.count == 0)
            {
                if(IS_IPAD)
                {
                    return CGSize(width: checkLandScape, height: 130)
                }
                return CGSize(width: checkLandScape, height: 55)
            }
            
            if(IS_IPAD)
            {
                return CGSize(width: checkLandScape, height: 115 - (arrayAdsCenter2.count > 0 ? 18 : 0))
            }
            return CGSize(width: checkLandScape, height: 59 - (arrayAdsCenter2.count > 0 ? 18 : 0))
        }
        else if(section == 6)
        {
            if(arrayCommentArticle.count>0)
            {
                if(IS_IPAD)
                {
                    return CGSize(width: checkLandScape, height: 91)
                }
                return CGSize(width: checkLandScape, height: 55)
            }
        } else if section == 8 {
            return CGSize(width: checkLandScape, height: IS_IPHONE ? 50 : 65)
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            if(indexPath.section == 0)
            {
                let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ContentHeaderCollection", for: indexPath) as! ContentHeaderCollection
                return reusableview
            }
            else if(indexPath.section == 1)//xem bai goc
            {
                let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ViewOriginArticleCollectionViewCell", for: indexPath) as! ViewOriginArticleCollectionViewCell
                reusableview.delegate = self
                reusableview.setupView(isLive: false)
                return reusableview
            }
            else if(indexPath.section == 2)
            {
                if(arrayAdsLastArticle.count>0)
                {
                    let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ViewAdsArticleDetailCollectionViewCell", for: indexPath) as! ViewAdsArticleDetailCollectionViewCell
                    
                    if let objectAds = arrayAdsLastArticle.lastObject as? AdsGoogleObject
                    {
                        customizeGoogleAdsView.frame = CGRect(x: 0, y: 0, width: reusableview.frame.width, height: reusableview.frame.height)
                        customizeGoogleAdsView.setItemsFrame(adsGoogleObject: objectAds, viewController: self)
                        reusableview.addSubview(customizeGoogleAdsView)
                    }
                    else if let objectAds = arrayAdsLastArticle.lastObject as? GAMBannerView
                    {
                        var rect = objectAds.frame
                        rect.origin.x = (reusableview.frame.width - rect.size.width)/2
                        rect.origin.y = (reusableview.frame.height - rect.size.height)/2
                        objectAds.frame = rect
                        reusableview.addSubview(objectAds)
                    }
                    
                    return reusableview
                }
            }
            else if(indexPath.section == 3 || indexPath.section == 7)
            {
                if(indexPath.section == 3)
                {
                    if(arrayArticleRelated.count>0)
                    {
                        let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TitleTLQCollectionViewCell", for: indexPath) as! TitleTLQCollectionViewCell
                        reusableview.setupView(text: "Tin liên quan", isResize: arrayAdsLastArticle.count > 0 ? true : false)
                        return reusableview
                    }
                }
                
                if(arrayArticleTopRead.count>0)
                {
                    let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TitleTLQCollectionViewCell", for: indexPath) as! TitleTLQCollectionViewCell
                    reusableview.setupView(text: "Tin đọc nhiều", isResize: false)
                    return reusableview
                }
            }
            else if(indexPath.section == 5)//neu y kien
            {
                if(arrayCommentArticle.count == 0)
                {
                    let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ViewMoreCriticalCollectionViewCell", for: indexPath) as! ViewMoreCriticalCollectionViewCell
                    reusableview.delegate = self
                    reusableview.setupView(arrayComment: arrayCommentArticle)
                    reusableview.btnClick.addTarget(self, action: #selector(actionViewMoreComment), for: .touchUpInside)
                    return reusableview
                }
                else
                {
                    let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TitleTLQCollectionViewCell", for: indexPath) as! TitleTLQCollectionViewCell
                    reusableview.setupView(text: "Bình luận", isResize: false)
                    reusableview.constraintTop.constant = arrayAdsCenter2.count > 0 ? 0 : 8
                    reusableview.constraintHeight.constant = arrayAdsCenter2.count > 0 ? 0 : 10
                    return reusableview
                }
            }
            else if(indexPath.section == 6)
            {
                if(arrayCommentArticle.count>0)
                {
                    let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ViewMoreCriticalCollectionViewCell", for: indexPath) as! ViewMoreCriticalCollectionViewCell
                    reusableview.delegate = self
                    reusableview.setupView(arrayComment: arrayCommentArticle)
                    reusableview.btnClick.addTarget(self, action: #selector(actionViewMoreComment), for: .touchUpInside)
                    return reusableview
                }
            }
            else if indexPath.section == 8 {
                let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "PopVCCollectionReusableView", for: indexPath) as! PopVCCollectionReusableView
                return reusableview
            } else if  indexPath.section == 4 {
                if(arrayAdsCenter2.count>0)
                {
                    let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ViewAdsArticleDetailCollectionViewCell", for: indexPath) as! ViewAdsArticleDetailCollectionViewCell
                    
                    if let objectAds = arrayAdsCenter2.lastObject as? AdsGoogleObject
                    {
                        customizeGoogleAdsViewCenter2.frame = CGRect(x: 0, y: 0, width: reusableview.frame.width, height: reusableview.frame.height)
                        customizeGoogleAdsViewCenter2.setItemsFrame(adsGoogleObject: objectAds, viewController: self)
                        reusableview.addSubview(customizeGoogleAdsViewCenter2)
                    }
                    else if let objectAds = arrayAdsCenter2.lastObject as? GAMBannerView
                    {
                        var rect = objectAds.frame
                        rect.origin.x = (reusableview.frame.width - rect.size.width)/2
                        rect.origin.y = (reusableview.frame.height - rect.size.height)/2
                        objectAds.frame = rect
                        reusableview.setDataToView(bannerView: objectAds, source: 1)
                    }
                    
                    return reusableview
                }
            }
            return UICollectionReusableView.init()
            
            
        default:  fatalError("Unexpected element kind")
        }
    }
    
    @objc func actionViewMoreComment()
    {
        let storyboard = Global.sharedInstance.getMainStoryboard()
        let pageCriticalViewController = storyboard.instantiateViewController(withIdentifier: "PageCriticalViewController") as! PageCriticalViewController
        pageCriticalViewController.infoArticleCommentProto = self.infoArticleProto
        
        //let arrayArticle11 = arrayArticle
        self.navigationController?.pushViewController(pageCriticalViewController, animated: true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if !didLoadRelateArticle {
            return 8
        }
        return 9
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(indexPath.section == 0)
        {
            if(indexPath.row == 0)
            {
                if(arrayContent.count > 0)
                {
                    let heightVideo = (SCREEN_WIDTH*9)/16
                    return CGSize(width: SCREEN_WIDTH, height: heightVideo)
                }
                
            }
            else if(indexPath.row == 1)
            {
                if(IS_IPAD)
                {
                    return CGSize(width: checkLandScape, height: self.getHeightText(title: self.infoArticleProto.video.title, font: UIFont.init(name: FONT_SFDISPLAY_SEMIBOLD, size: sizeFontTitle + increase)!) + 30)
                }
                
                if(Global.sharedInstance.getModeInReview() == true)
                {
                    return CGSize(width: checkLandScape, height: self.getHeightText(title: self.infoArticleProto.video.title, font: UIFont.init(name: FONT_SFDISPLAY_SEMIBOLD, size: sizeFontTitle + increase)!) + 15)
                }
                
                return CGSize(width: checkLandScape, height: self.getHeightText(title: self.infoArticleProto.video.title, font: UIFont.init(name: FONT_SFDISPLAY_SEMIBOLD, size: sizeFontTitle + increase)!) + 30)
            }
            else if(indexPath.row == 2)
            {
                if(IS_IPAD)
                {
                    return CGSize(width: checkLandScape, height: 60)
                }
                return CGSize(width: checkLandScape, height: 30)
            }
            else if(indexPath.row == 3)
            {
                return CGSize(width: 0, height: 0) //description
            }
        }
        else if(indexPath.section == 3 || indexPath.section == 7)
        {
            var arrayArticle = arrayArticleRelated
            if(indexPath.section == 7)
            {
                arrayArticle = arrayArticleTopRead
            }
            
            if let data = arrayArticle.object(at: indexPath.row) as? Model_Document
            {
                if(data.type == .contentTypeArticles)
                {
                    if(SCREEN_WIDTH <= 320 && SCREEN_HEIGHT <= 568)
                    {
                        return CGSize.init(width: checkLandScape, height: (CGFloat((SCREEN_WIDTH - 44)/3)*3/4) + 38)
                    }
                    
                    return CGSize.init(width: checkLandScape, height: (CGFloat((SCREEN_WIDTH - 44)/3)*3/4) + 32)
                }
                if(data.type == .contentTypeSponsors)
                {
                    if(SCREEN_WIDTH <= 320 && SCREEN_HEIGHT <= 568)
                    {
                        return CGSize.init(width: checkLandScape, height: (CGFloat((SCREEN_WIDTH - 44)/3)*3/4) + 38)
                    }
                    
                    return CGSize.init(width: checkLandScape, height: (CGFloat((SCREEN_WIDTH - 44)/3)*3/4) + 32)
                }
                else if(data.type == .contentTypeUtilities || data.type == .contentTypeVote)
                {
                    if(SCREEN_WIDTH <= 320 && SCREEN_HEIGHT <= 568)
                    {
                        return CGSize.init(width: checkLandScape, height: (CGFloat((SCREEN_WIDTH - 44)/3)*3/4) + 38)
                    }
                    
                    return CGSize.init(width: checkLandScape, height: (CGFloat((SCREEN_WIDTH - 44)/3)*3/4) + 32)
                }
            }
        }
        else if(indexPath.section == 5)
        {
            if(IS_IPAD)
            {
                if(arrayCommentArticle.count>2)
                {
                    if(indexPath.row == 2)
                    {
                        return CGSize(width: checkLandScape, height: 50)
                    }
                    let dictData = arrayCommentArticle.object(at: indexPath.row) as! NSDictionary
                    let height = self.getHeightTextCmt(title: dictData.object(forKey: "content") as! String)
                    return CGSize(width: checkLandScape, height: height + 135)
                }
                else
                {
                    if(indexPath.row == arrayCommentArticle.count)
                    {
                        return CGSize(width: checkLandScape, height: 50)
                    }
                    let dictData = arrayCommentArticle.object(at: indexPath.row) as! NSDictionary
                    let height = self.getHeightTextCmt(title: dictData.object(forKey: "content") as! String)
                    return CGSize(width: checkLandScape, height: height + 135)
                }
            }
            else
            {
                if(arrayCommentArticle.count>2)
                {
                    if(indexPath.row == 2)
                    {
                        return CGSize(width: checkLandScape, height: 30)
                    }
                    let dictData = arrayCommentArticle.object(at: indexPath.row) as! NSDictionary
                    let height = self.getHeightTextCmt(title: dictData.object(forKey: "content") as! String)
                    return CGSize(width: checkLandScape, height: height + 63)
                }
                else
                {
                    //xem xet
                    if(indexPath.row == arrayCommentArticle.count)
                    {
                        return CGSize(width: checkLandScape, height: 50)
                    }
                    let dictData = arrayCommentArticle.object(at: indexPath.row) as! NSDictionary
                    let height = self.getHeightTextCmt(title: dictData.object(forKey: "content") as! String)
                    return CGSize(width: checkLandScape, height: height + 70.5 + 2)
                }
            }
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    public func getHeightText(title: String, font: UIFont)->CGFloat {
        print("title: ", title)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = line_spacing
        paragraphStyle.alignment = .left
        
        let attributedString = NSMutableAttributedString(string: title as String, attributes:
            [NSAttributedString.Key.paragraphStyle:paragraphStyle,
             NSAttributedString.Key.font:font]
        )
        
        //print("aa:", self.view.frame.width)
        
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let sizeOfString = attributedString.boundingRect(with: CGSize(width: checkLandScape - originX*2, height: 10000), options: options, context: nil)
        
        return CGFloat(sizeOfString.height + 0.5)
    }
    
    public func getHeightTextHtml(title: String, font: UIFont)->CGFloat {
        //xem lai ham nay
        //print("title: ", title)
        let textTitle = String(format: "<style>body{font-family: '%@'; font-size:%fpx;}</style>%@", FONT_UITEXT_REGULAR, sizeFontContent + increase,  title)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = line_spacing
        paragraphStyle.alignment = .left
        
        let attributedString = NSMutableAttributedString(string: textTitle as String, attributes:
            [NSAttributedString.Key.paragraphStyle:paragraphStyle,
             NSAttributedString.Key.font:font]
        )
        
        //print("aa:", self.view.frame.width)
        
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let sizeOfString = attributedString.boundingRect(with: CGSize(width: checkLandScape - originX*2, height: 10000), options: options, context: nil)
        
        return CGFloat(sizeOfString.height + 0.5)
    }
    
    public func getHeightTextCmt(title: String)->CGFloat {
        //print("title: ", title)
        var font = UIFont.init(name: FONT_UITEXT_REGULAR, size: 14)!
        var width:CGFloat = checkLandScape - 79 - originX
        if(IS_IPAD)
        {
            font = UIFont.init(name: FONT_UITEXT_REGULAR, size: 22)!
            width = checkLandScape - 123
        }
        
        let height = title.height(constraintedWidth: width, font: font)
        
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 0
//        paragraphStyle.alignment = .left
//
//        let attributedString = NSMutableAttributedString(string: title as String, attributes:
//            [NSAttributedString.Key.paragraphStyle:paragraphStyle,
//             NSAttributedString.Key.font:font]
//        )
        
        //print("aa:", self.view.frame.width)
        
//        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
//        let sizeOfString = attributedString.boundingRect(with: CGSize(width: width, height: 10000), options: options, context: nil)
        
//        return CGFloat(sizeOfString.height) + 0.5
        return height + 0.5
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cellV = cell as? ContentNativeCollectionViewCell {
            if cellV.isHasVideo && playerView.superview != nil && originPlayerFrame != CGRect.zero && playerView.isFullScreen == false {
                playerView.removeFromSuperview()
                playerView.frame = originPlayerFrame
                playerView.alpha = 1
                playerView.controlView.hiddenButton.isHidden = true
                currentCellNative.addSubview(playerView)
                isSuperViewCollectionViewCell = true
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cellV = cell as? ContentNativeCollectionViewCell {
            if cellV.isHasVideo {
                if playerView.superview != nil && playerView.isFullScreen == false {
                    originPlayerFrame = playerView.frame
                    playerView.removeFromSuperview()
                    var yOffSet: CGFloat = 65 + (self.websiteApp != nil ? 44 : 0) + Global.sharedInstance.marginTopBarHeight()
                    if IS_IPAD {
                        yOffSet = 77
                        if Global.sharedInstance.getModeInReview() == true {
                            yOffSet = 127
                        }
                    }
                    
                    self.playerView.frame = .init(x: SCREEN_WIDTH/3, y: yOffSet, width: SCREEN_WIDTH*2/3, height: SCREEN_WIDTH*2/3 * (9/16))
                    playerView.controlView.hiddenButton.isHidden = false
                    self.view.addSubview(self.playerView)
                    originPlayerFrame2 = playerView.frame
                    isSuperViewCollectionViewCell = false
                }
            }
        }
    }
    
    var isSuperViewCollectionViewCell = true
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if(section == 0)
        {
            return arrayContent.count + 3
        }
        else if(section == 1)//xem bai goc
        {
            return 0
        }
        else if(section == 2)//quang cao
        {
            return 0
        }
        else if(section == 3)
        {
            return arrayArticleRelated.count
        }
        else if(section == 5) //new y kien
        {
            if(arrayCommentArticle.count>=2)
            {
                return 2
            }
            return arrayCommentArticle.count
        }
        else if(section == 6) //xem binh luan
        {
            return 0
        }
        else if(section == 7) //tin doc nhieu
        {
            return arrayArticleTopRead.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(indexPath.section == 0) //tin native
        {
            var identifi:String = ""
            if(indexPath.row == 0)
            {
                if(arrayContent.count > 0)
                {
                    if let dictData = arrayContent.object(at: 0) as? NSDictionary
                    {
                        if(dictData.object(forKey: "type") != nil)
                        {
                            let type = dictData.object(forKey: "type") as! String
                            if(type == "video" || type == "script")
                            {
                                identifi = "CellVideoNative"
                            }
                        }
                    }
                }
            }
            else  if(indexPath.row == 1)
            {
                identifi = "CellTitleNative"
            }
            else if(indexPath.row == 2)
            {
                identifi = "CellSuperCategory"
            }
            else
            {
                identifi = "CellDesNative"
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifi, for: indexPath) as! ContentNativeCollectionViewCell
            cell.backgroundColor = .clear
            
            if(indexPath.row == 0)
            {
                if(arrayContent.count > 0)
                {
                    if let dictData = arrayContent.object(at: 0) as? NSDictionary
                    {
                        if(dictData.object(forKey: "type") != nil)
                        {
                            let type = dictData.object(forKey: "type") as! String
                            if(type == "video" || type == "script")
                            {
                                //dang lam
                                //print("co video");
                                
                                let dictData = arrayContent.object(at: cell.playBtn.tag) as! NSDictionary
                                if(dictData.object(forKey: "content") != nil && dictData.object(forKey: "type") as! String == "video") {
                                    if let arrayData = dictData.object(forKey: "content") as? [String] {
                                        if arrayData.count > 0 {
                                            cell.setDataToCell(modelDocument: infoArticleProto, arrayData: arrayData, indexPath: indexPath, isNightMode: true, isBright: false)
                                        }
                                    }
                                }
                                
                                cell.situasionDelegate = self
                                cell.delegate = self
                                
                                cell.isHasVideo = true
                                cell.imgLeftCst.constant = 0
                                
                                cell.playBtn.tag = indexPath.row
                                cell.playBtn.addTarget(self, action: #selector(startPlayVideo(btn:seek:)), for: .touchUpInside)
                            }
                        }
                    }
                }
            }
            else if(indexPath.row == 1)
            {
                cell.setCenterY()
                let labelText = self.infoArticleProto.video.title
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = line_spacing
                
                let attributedString = NSMutableAttributedString(string: labelText, attributes:
                    [NSAttributedString.Key.paragraphStyle:paragraphStyle,
                     NSAttributedString.Key.font:UIFont.init(name: FONT_SFDISPLAY_SEMIBOLD, size: CGFloat(sizeFontTitle + increase))!]
                )
                
                if(Global.sharedInstance.getModeInReview() == true)
                {
                    cell.constraintTop?.constant = 0
                }
                
                cell.labelText.attributedText = attributedString
                cell.labelText.sizeToFit()
                
                cell.labelText.mixedTextColor = .init(normal: .black, night: .white)
            }
            else if(indexPath.row == 2)
            {
                cell.setUpCategoryCell(website: nameWebsite, topic: nameCategory, time: self.infoArticleProto.art.posttime)
                cell.originButton.isHidden = true
//                cell.originAction = { [weak self] in
//                    guard let `self` = self else {return}
//                    self.changeModeAction()
//                }
                cell.websiteAction = { [weak self] in
                    guard let `self` = self else {return}
                    self.clickWebSites()
                }
                cell.topicAction = { [weak self] in
                    guard let `self` = self else {return}
                    self.clickTopic()
                }
//                if Global.sharedInstance.getModeInReview() != true {
//                    if Global.sharedInstance.isTypeViewNative(nameWebsite: nameWebsite) == true {
//                        cell.originButton.isHidden = false
//                    } else {
//                        cell.originButton.isHidden = true
//                    }
//                } else {
//                    cell.originButton.isHidden = true
//                }
                
//                cell.nameTopic.setTitle("  " + nameCategory + "  ", for: .normal)
//                cell.nameTopic.addTarget(self, action: #selector(clickTopic), for: .touchUpInside)
//                cell.nameTopic.backgroundColor = Constant.Color.mainThemeColor
//                cell.nameWebsite.text = nameWebsite
//                cell.nameWebsite.isUserInteractionEnabled = true
//                cell.nameWebsite.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickWebSites)))
//
//                cell.nameTopic.titleLabel?.font = UIFont.init(name: FONT_UITEXT_REGULAR, size: IS_IPHONE ? 12 : 16)!
//                cell.nameWebsite.font = UIFont.init(name: FONT_UITEXT_REGULAR, size: IS_IPHONE ? 12 : 16)!
//
//                cell.nameWebsite.textColor = UIColor(rgb: 0x4A90E2)
                
            }
            else if(indexPath.row == 3)
            {
                let labelText = self.infoArticleProto.video.desc
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = line_spacing
                
                let attributedString = NSMutableAttributedString(string: labelText, attributes:
                    [NSAttributedString.Key.paragraphStyle:paragraphStyle,
                     NSAttributedString.Key.font:UIFont.init(name: FONT_UITEXT_BOLD, size: CGFloat(sizeFontDescrip + increase))!]
                )
                cell.labelText.attributedText = attributedString
                cell.labelText.sizeToFit()
                
                let modeRead = UserDefault.sharedInstance.getSettingModeRead()
                if (modeRead == "readBlack")
                {
                    cell.labelText.textColor = .white
                }
                else
                {
                    cell.labelText.textColor = .black
                }
            }
            
            return cell
        }
        else if(indexPath.section == 3 || indexPath.section == 7)
        {
            var arrayArticle = arrayArticleRelated
            if(indexPath.section == 7)
            {
                arrayArticle = arrayArticleTopRead
            }
            
            if let data = arrayArticle.object(at: indexPath.row) as? Model_Document
            {
                if(data.type == .contentTypeArticles)
                {
                    let identif:String = "ListNewsCollectionViewCell1"
                    
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identif, for: indexPath) as! ListNewsCollectionViewCell1
                    cell.setDataToCell(modelDocument: data, indexPath: indexPath, dictArrNewsFade: self.dictArrNewsFade)
                    cell.delegate = self
                    
                    if indexPath.section == 3, cell.viewLineCell != nil {
                        cell.viewLineCell?.isHidden = false
                        if arrayAdsCenter2.count > 0 || arrayCommentArticle.count > 0, indexPath.row == arrayArticle.count - 1 {
                            cell.viewLineCell?.isHidden = true
                        }
                    }
                    return cell
                }
                else if(data.type == .contentTypeSponsors)
                {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IdentifierCellSponser, for: indexPath) as! ListNewsSponserCollectionViewCell
                    cell.delegate = self
                    cell.setDataToCell(data: data, indexPath: indexPath)
                    return cell
                }
                else if(data.type == .contentTypeUtilities || data.type == .contentTypeVote)
                {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailNewsUtilityCollectionViewCell", for: indexPath) as! ListNewsUtilityCollectionViewCell
                    cell.setDataProtoToCell(data: data, indexPath: indexPath)
                    cell.delegate = self
                    return cell
                }
            }
        }
        else if(indexPath.section == 5)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CriticalOfCriticalCollectionViewCell", for: indexPath) as! CriticalOfCriticalCollectionViewCell
            cell.delegate = self
            cell.setDataToCell(itemData: arrayCommentArticle.object(at: indexPath.row) as! NSDictionary, dicLidComment: dicLidComment, arrayBadWord: [], atIndex: indexPath.row)
            
            cell.lineComment.isHidden = false
            if(indexPath.row == 0)
            {
                cell.lineComment.isHidden = true
            }
            
            return cell
        }
        
        return UICollectionViewCell.init()
    }
        
    @objc func startPlayVideo(btn: UIButton, seek: Int = 0)
    {
        if textInput.textView.isFirstResponder {
            endEditting()
            return
        }
        playerView.situationEnable = false
        currentSeekTime = seek
        arrayListVideoNative.removeAllObjects()
        currentIndexPath = IndexPath.init(row: btn.tag, section: 0)
        if let current = collectionArticle?.cellForItem(at: currentIndexPath!) as? ContentNativeCollectionViewCell
        {
            currentCellNative = current
        }
        
        print("currentCellNative: ", currentCellNative)
        if(isSmallScreen == true) && playerView.isFullScreen == false
        {
            playerView.frame = currentCellNative.imageBackgroundVideo.frame
            let dictData = arrayContent.object(at: btn.tag) as! NSDictionary
            
            print("dictData: ", dictData)
            if(dictData.object(forKey: "content") != nil)
            {
                let arrayData = dictData.object(forKey: "content") as! NSArray
                print("arrayData: ", arrayData)
                if(arrayData.count>0)
                {
                    //thong ke
                    //print("dictData: ", dictData)
                    
                    let name = nameWebsite //24h
                    let category = nameCategory //Giai tri
                    let lid:String = self.infoArticleProto.video.lid
                    
                    FirebaseAnalyticLog.sharedInstance.logEvent(eventName: PLAY_VIDEO, itemID: lid, itemName: name, itemCategory: category, method: MANUAL, location:
                                                                    IN_APP_ARTICLE, itemTopics: self.infoArticleProto.video.topics)
                    
                    queue.removeAll()
                    for path in arrayData
                    {
                        if let strPath = path as? String
                        {
                            if let url = Global.sharedInstance.encodingUrl(strPath: strPath)
                            {
                                let res = BMPlayerResourceDefinition(url: url,
                                definition: "")
                                queue.append(res)
                            }
                        }
                    }
                    if(queue.count > 0)
                    {
                        let asset = BMPlayerResource(name: "",
                                                     definitions: queue,
                                                     cover: nil)

                        playerView.setVideo(resource: asset, videoMeta: infoArticleProto.video.videoMeta)
                        playerView.play()
                    }

                    playerView.delegate = self
                    playerView.controlView.volumeButton.setImage((mute ? UIImage.init(named: "ico-volume-off") : UIImage.init(named: "ico-volume-on")), for: .normal)
                    
                }
            }
        }
        
        if playerView.isFullScreen == false {
            currentCellNative.addSubview(playerView)
            currentCellNative.bringSubviewToFront(playerView)
            currentCellNative.playBtn.superview?.sendSubviewToBack(currentCellNative.playBtn)
            collectionArticle?.reloadData()
        }
    }
    
    var typeToDetail:XKType_TO_DETAILNEWS = .XK_NORMAL
    
    var tsStart:Int64 = 0
    var isSendTrackingReaded:Bool = false
    
    var lidArticleLoad:String = ""
    var dictArrNewsFade = [String]()
    
    //review App
    var viewOfWebsiteApp = UIView()
    var websiteApp: WKWebView?
    @IBOutlet weak var lblOriginArticle: UILabel!
    @IBOutlet weak var viewOriginArticle: UIView!
    @IBOutlet weak var btnSetting:UIButton!
    @IBOutlet weak var viewModeWeb_App:UIView!
    @IBOutlet weak var viewLineWeb:UIView!
    @IBOutlet weak var viewLineApp:UIView!
    @IBOutlet weak var lblTitleWeb:UILabel!
    @IBOutlet weak var lblTitleApp:UILabel!
    @IBOutlet weak var progressView:UIProgressView!
    //let progressView = UIProgressView(progressViewStyle: .bar)
    private var estimatedProgressObserver: NSKeyValueObservation?
    
    let viewInteract: ViewInteract = .fromNib()
        
    let adsGoogleDFP = AdsGoogleDFP()
    let adsGoogleCenter2DFP = AdsGoogleDFP()
    
    //lay thumb
    var generatorThumb: ACThumbnailGenerator!
    var dictUrl_ContributorVideo = NSMutableDictionary()
    
    var isMarked:Bool = false
    var queue: [BMPlayerResourceDefinition] = []
    var currentSeekTime = 0
    var playerView = BMPlayer()
    var containerView = UIView()
    
    var urlIconWebsite:String = ""
    var nameWebsite:String = "" {
        didSet {
            contentView.nameWebsite = self.nameWebsite
        }
    }
    var sID:Int = 0
    var nameTopicWebsite = ""
    var infoArticleProto = Model_Document.init() {
        didSet {
            self.contentView.videoProtobuf = infoArticleProto
            self.playerView.videoType = infoArticleProto.video.videoType
        }
    }
    var nameCategory:String = "" {
        didSet {
            self.contentView.nameCategory = self.nameCategory
        }
    }
    
    var line_spacing:CGFloat = 0
    var strTitle:String = ""
    var contentArticle:String = ""
    var timeStamp:String = ""
    var arrayListImage = NSMutableArray()
    var requestUrlImage:String = ""
    var photosWithUrl = NSMutableArray()
    var showMenu:Bool = false
    var setting:Bool = false
    
    var contentTextWebview:String = ""
    var initWebview:Bool = false
    
    var arrayCommentArticle = NSMutableArray()
    var arrayUrlAvatar = NSMutableArray()
    var tapGesture = UITapGestureRecognizer()
    var showComment:Bool = false
    var getComment:Bool = false
    var linkArticle:String = ""
    var pointX:CGFloat = 0
    var stopVideo:Bool = false
    
    var buttonTopic = UIButton()
    var buttonWebsites = UIButton()
    var panRecognizerSliderVideo = UIPanGestureRecognizer()
    var labelNotifiSaveArticle = UILabel()
    
    var arrayAdsLastArticle = NSMutableArray()
    var arrayAdsCenter2 = NSMutableArray()
    var arrayArticleRelated = NSMutableArray()
    var arrayArticleTopRead = NSMutableArray()
    
    //var bannerViewGG =
    var checkLandScape:CGFloat = 0
    var checkLandScapeHeight:CGFloat = 0
    
    var arrayContent = NSMutableArray()
    var arrayListVideoNative = NSMutableArray()
    var arrayListImageNative = NSMutableArray()
    var photosWithURLNative = NSMutableArray()
    
    var increase:CGFloat = 0
    //var wmPlayer = WM
    var currentIndexPath:IndexPath?
    var isSmallScreen:Bool = true
    
    var dicLidComment = NSDictionary()
    var buttonShowKeyboard = UIButton()
    var showKeyboardBool:Bool = false
    var heightKeyboard:CGFloat = 0
    
    var originX:CGFloat = 0
    let customizeGoogleAdsView: CustomizeGoogleAdsView = .fromNib()
    let customizeGoogleAdsViewCenter2: CustomizeGoogleAdsView = .fromNib()
    
    @IBOutlet weak var viewShadow:UIView!
    let viewSettingControl: ModeControlArticle = .fromNib()
    
    var labelNameTopicView = UILabel()
    var labelTimeStampView = UILabel()
    var coverImageView = UIImageView()
    
    var labelTitleView = UILabel()
    var labelNameWebsites = UILabel()
    var scrollWebView = UIScrollView()
    var webView = WKWebView()
    @IBOutlet weak var buttonCloseViewPopupSetting:UIButton!
    @IBOutlet weak var imageBookMark:UIImageView!
    var collectionArticle:UICollectionView?
    @IBOutlet weak var icon_setting:UIImageView!
    @IBOutlet weak var imgBack:UIImageView!
    
    @IBOutlet weak var viewStatus:UIView!
    @IBOutlet weak var viewTitle:UIView!
//    @IBOutlet weak var imgIconPage:UIImageView!
    
    @IBOutlet weak var viewHome:UIView!
    
    var currentCellNative = ContentNativeCollectionViewCell()
    let viewLogin: ViewPopupLogin = .fromNib()
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var constrBottomViewHome:NSLayoutConstraint!
    
    let viewContainerLoginFB = UIView(frame: UIScreen.main.bounds)
    func showViewLogin(text:String, textResult:String)
    {
        self.viewContainerLoginFB.backgroundColor = .init(white: 0, alpha: 0.6)
        self.viewContainerLoginFB.isUserInteractionEnabled = true
        self.viewContainerLoginFB.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickHiddenKeyboard)))
        viewLogin.messageText = textResult
        viewLogin.textLogin.text = TEXT_LOGINFB_COMMENT
        viewContainerLoginFB.tag = 99
        
        viewContainerLoginFB.addSubview(viewLogin)
        viewLogin.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(IS_IPHONE ? 32 : (SCREEN_WIDTH/4))
        }
        view.addSubview(viewContainerLoginFB)
    }
    
    @objc func clickHiddenKeyboard()
    {
        textInput.textView.resignFirstResponder()
        UIView.animate(withDuration: 0.3, animations: {
            self.viewContainerLoginFB.removeFromSuperview()
            self.buttonShowKeyboard.isHidden = true
        }) { (result) in
            
        }
    }
    
    func getUnitIDFromSetting()
    {
        
    }
    
    func actionOpenSetting()
    {
        viewSettingControl.updateSlider()
        viewSettingControl.sliderBrightness.value = CGFloat(UIScreen.main.brightness)*100
        viewSettingControl.reloadSwitch()
        
        UIView.animate(withDuration: 0.3, animations: {
            var rect = CGRect(x: 0, y: SCREEN_HEIGHT - self.viewSettingControl.frame.height, width: SCREEN_WIDTH, height: self.viewSettingControl.frame.height)
            if IS_IPAD {
                rect = CGRect(x: SCREEN_WIDTH - 450, y: 80, width: 450, height: 280)
            }
            self.viewSettingControl.frame = rect
        }) { (result) in
            if let interactivePopGestureRecognizer = self.navigationController?.interactivePopGestureRecognizer {
                interactivePopGestureRecognizer.isEnabled = false
            }
        }
    }
    
    @IBAction func actionClosePopupSetting()
    {
        self.actionCloseSetting()
        setting = false
        self.icon_setting.mixedImage = .init(normal: "icon_setting", night: "icon_setting_light")
        
        self.actionCloseSetting()
        UIView.animate(withDuration: 0.3, animations: {
            self.buttonCloseViewPopupSetting.alpha = 0
        }) { (result) in
            self.buttonCloseViewPopupSetting.isHidden = true
        }
    }
    
    func actionCloseSetting()
    {
        UIView.animate(withDuration: 0.3, animations: {
            var rect = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: self.viewSettingControl.frame.height)
            if IS_IPAD {
                rect = CGRect(x: SCREEN_WIDTH - 16, y: 80, width: 480, height: 280)
            }

            self.viewSettingControl.frame = rect
        }) { (result) in
            if let interactivePopGestureRecognizer = self.navigationController?.interactivePopGestureRecognizer {
                interactivePopGestureRecognizer.isEnabled = true
            }
        }
    }
    
    @IBAction func actionSettingMenu()
    {
        
        if textInput.textView.isFirstResponder {
            endEditting()
            return
        }
        
        self.icon_setting.mixedImage = .init(normal: "icon_setting", night: "icon_setting_light")
        
        if(setting == false)
        {
            //thong ke
            FirebaseAnalyticLog.sharedInstance.logEvent(eventName: APP_TOPBAR_SETTING, itemID: "", itemName: "", itemCategory: "")
            
            setting = true
            buttonCloseViewPopupSetting.isHidden = false
            self.actionOpenSetting()
            UIView.animate(withDuration: 0.3, animations: {
                self.buttonCloseViewPopupSetting.alpha = 0.3
            }) { (result) in
                
            }
        }
        else
        {
            setting = false
            
            self.actionCloseSetting()
            UIView.animate(withDuration: 0.3, animations: {
                self.buttonCloseViewPopupSetting.alpha = 0
            }) { (result) in
                self.buttonCloseViewPopupSetting.isHidden = true
            }
        }
    }
    
    var isHiddenStatusBar:Bool = false
    override var prefersStatusBarHidden: Bool {
         return isHiddenStatusBar
    }
    
    func showStatusBar()
    {
        isHiddenStatusBar = false
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func hiddenStatusBar()
    {
        isHiddenStatusBar = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UserDefault.sharedInstance.getSettingModeRead() == "readBlack" ? .lightContent : .default
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }
    @objc func applicationWillResignActive()
    {
        if playerView.superview != nil {
            playerView.pause()
        }
    }
    
    @objc func applicationBecomeActiveDetailVideo()
    {
        if playerView.superview != nil {
            playerView.play()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setNeedsStatusBarAppearanceUpdate()
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
    }
    
    @objc func onDeviceOrientationChange()
    {
        print("quay video")
    }
    
    @IBAction func actionHome()
    {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func requestGoogleDFP(postion:XKPotisionAdsGoogle)
    {
        if(ConfigServer.sharedInstance.ios_gg_ads_id_Enable == 1)
        {
            var unitID:String = ""
            if postion == XKPotisionAdsGoogle.XKPotisionLast
            {
                var unitID:String = ""
                
                //qcao cuoi bai
                if(self.infoArticleProto.video.supercid == 1 || self.infoArticleProto.video.supercid == 4 || self.infoArticleProto.video.supercid == 5)
                {
                    unitID = ConfigServer.sharedInstance.ios_gg_ads_id_Below_detail
                }
                else
                {
                    unitID = ConfigServer.sharedInstance.ios_gg_ads_id_Below_detail_sport
                }
                
                if (self.infoArticleProto.video.hasGoogleAdsBelowDetail == true)
                {
                    self.adsGoogleDFP.loadGoogleDFP(viewController: self, gAd: self.infoArticleProto.video.googleAdsBelowDetail, position: .adEndContent)
                    return
                }
                
                print("unitID: ", unitID)
                self.adsGoogleDFP.loadGoogleDFP(viewController: self, unitID: unitID, position: .adEndContent)
            } else {
                if (self.infoArticleProto.video.hasGoogleAdsCenter2 == true)
                {
                    adsGoogleCenter2DFP.delegate = self
                    self.adsGoogleCenter2DFP.loadGoogleDFP(viewController: self, gAd: infoArticleProto.video.googleAdsCenter2, position: .adCenter2)
                }
            }
        }
    }
    
    deinit {
        print("goi ham deinit: DetailVideoViewController")
        NotificationCenter.default.removeObserver(self)
    }
    
    func showViewIconHome()
    {
        self.viewHome.isHidden = true
        let tabbarController = AppDelegate.sharedInstance.getTabBarController()
        if(tabbarController.viewControllers != nil)
        {
            if(tabbarController.viewControllers!.count > 0 && tabbarController.indexTab >= 0 && tabbarController.indexTab < tabbarController.viewControllers!.count)
            {
                if let navigationController = tabbarController.viewControllers![tabbarController.indexTab] as? UINavigationController
                {
                    if(navigationController.viewControllers.count>1)
                    {
                        var count = 0
                        for vc in navigationController.viewControllers
                        {
                            if vc.isKind(of: DetailViewController.self)
                            {
                                count = count + 1
                            }
                            else if vc.isKind(of: DetailVideoViewController.self)
                            {
                                count = count + 1
                            }
                        }
                        
                        if(count > 1 && Global.sharedInstance.getModeInReview() == false)
                        {
                            self.viewHome.isHidden = false
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        if nameWebsite == "" {
            nameWebsite = Global.sharedInstance.getNameWebsite(sid: Int(sID))!
        }
        viewStatus.layer.zPosition = -1
        
        self.tsStart = Date.currentTimeInMillis()
        dictArrNewsFade = DBManagement.share.getLidReaded()
        self.setNeedsStatusBarAppearanceUpdate()
        
        UIView.hr_setToastThemeColor(color: UIColor(red: 76/255.0, green: 76/255.0, blue: 76/255.0, alpha: 0.1))
        
        self.adsGoogleDFP.delegate = self
        
        showViewIconHome()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        viewLogin.delegate = self
        viewLogin.viewController = self
        
        // Do any additional setup after loading the view.
        self.getUnitIDFromSetting()
        self.customizeGoogleAdsView.tag = 100
        
        self.buttonShowKeyboard.backgroundColor = .black
        self.buttonShowKeyboard.alpha = 0.6
        self.buttonShowKeyboard.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        self.buttonShowKeyboard.addTarget(self, action: #selector(clickHiddenKeyboard), for: .touchUpInside)
        self.buttonShowKeyboard.isHidden = true
                
        originX = 15
        if(IS_IPAD)
        {
            originX = 80
        }

        viewTitle.addShadow(shadowOffset: .init(width: 0, height: 1), shadowOpacity: 0.5, shadowRadius: 1)
        
        lblTitle.font = UIFont.init(name: FONT_SFDISPLAY_SEMIBOLD, size: 16)
        if(IS_IPAD)
        {
            lblTitle.font = UIFont.init(name: FONT_SFDISPLAY_SEMIBOLD, size: 20)
        }
        
        urlIconWebsite = Global.sharedInstance.getIconWeb(sid:Int(self.infoArticleProto.video.sid))
        
//        imgIconPage.sd_setImage(with: URL(string: urlIconWebsite), placeholderImage: Global.sharedInstance.showPlaceHolderImage())
        
//        self.constrBottomViewHome.constant = self.constrBottomViewHome.constant + Global.sharedInstance.marginBottomBarHeight()
        
        if IS_IPAD {
            viewSettingControl.frame = CGRect(x: SCREEN_WIDTH - 16, y: 80, width: 480, height: 300)
            viewSettingControl.viewContainer.cornerRadius = 10
            drawArrow()
        } else {
            viewSettingControl.frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: 256 - (Global.sharedInstance.getModeInReview() ? 60 : 0))
        }
        self.view.addSubview(viewSettingControl)
        viewSettingControl.delegate = self
        
        line_spacing = 5
                
        checkLandScape = SCREEN_WIDTH
        checkLandScapeHeight = SCREEN_HEIGHT
        
        self.viewModeWeb_App.isHidden = true
        if(self.lidArticleLoad.count > 0)
        {
            ///reload lai data (truong hop push, truong hop bai is_live = 1)
            APIRequest.sharedInstance.getArticleWidthIdPush(lid: self.lidArticleLoad, typeToDetail: self.typeToDetail,isPushLive: false, isDecrease: false) { [weak self] (result, error) in
                
                guard let strongSelf = self else { return }
                                
                var isSuccess = false
                if(result != nil)
                {
                    print("resultData: ", result as Any)
                    
                    if let dataResult = result as? Data
                    {
                        do
                        {
                            let data = try Model_ArticleDetailResponses(serializedData: dataResult)
                            
                            //UserDefault.sharedInstance.setArrayDocumentReaded(modelDocument: data) data.linfo)
                            
                            let document = Global.sharedInstance.changeArticleToDocument(model_Article: data.linfo)
                            
                            main {
                                DBManagement.share.saveArticleReadedToDB(model: document)
                            }
                         
                            
                            let sid = data.linfo.sid
                            let cid = data.linfo.cid

                            strongSelf.sID = Int(sid)
                            //strongSelf.infoArticleProto = data.linfo
                            strongSelf.infoArticleProto = Model_Document()
                            strongSelf.infoArticleProto.type = .contentTypeArticles
                            strongSelf.infoArticleProto.art = data.linfo

                            strongSelf.nameCategory =  Global.sharedInstance.getTopic(sid: Int(sid), cid: Int(cid))!

                            strongSelf.nameWebsite = Global.sharedInstance.getNameWebsite(sid: Int(sid))!

                            strongSelf.createViewAndReloadData()
                            isSuccess = true
                        }
                        catch let error {
                            print(error.localizedDescription)
                        }
                    }
                }
                   
                if(isSuccess == false)
                {
                    AppDelegate.sharedInstance.reloadInternetView.refreshData()
                    if(error != nil)
                    {
                        if(error!._code == 404)
                        {
                            AppDelegate.sharedInstance.reloadInternetView.Data404()
                        }
                    }
                    AppDelegate.sharedInstance.reloadInternetView.isHidden = false
                    AppDelegate.sharedInstance.reloadInternetView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - 44 - Global.sharedInstance.marginBottomBarHeight() - 60, width: strongSelf.view.frame.width, height: 50)
                    strongSelf.view.addSubview(AppDelegate.sharedInstance.reloadInternetView)
                    AppDelegate.sharedInstance.reloadInternetView.delegate = self
                }
            }
        }
        else
        {
            DBManagement.share.saveArticleReadedToDB(model: self.infoArticleProto)
            createViewAndReloadData()
        }
        
        NotificationCenter.default.removeObserver(self)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        showMenu = false
        setting = false
        buttonCloseViewPopupSetting.isHidden = true
                
        getComment = true
        stopVideo = false
                                        
        self.changeBackgroundColor(checkReloadWebview: true)
        
        self.labelNotifiSaveArticle.center = self.view.center
        self.labelNotifiSaveArticle.backgroundColor = .black
        self.labelNotifiSaveArticle.textColor = .white
        self.view.addSubview(self.labelNotifiSaveArticle)
        self.labelNotifiSaveArticle.textAlignment = .center
        self.labelNotifiSaveArticle.font = UIFont.init(name: FONT_UITEXT_SEMIBOLD, size: IS_IPHONE ? 14 : 20)
        
        view.addSubview(textInput)
        textInput.mode = .detail
        self.view.addSubview(viewSettingControl)
        textInput.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
        }
        bottomInputConstraint = textInput.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
        bottomInputConstraint?.isActive = true
        textInput.lbAlert.snp.updateConstraints { (make) in
            make.height.equalTo(0)
        }
        self.setUpInputAction()
        
        addBottomSubViewIphoneX()
        self.viewInteract.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        self.viewInteract.delegate = self
        self.view.addSubview(viewInteract)
    }
    
    var bottomInputConstraint: NSLayoutConstraint?
    
    func drawArrow() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 30))
        path.addLine(to: CGPoint(x: 400, y: 30))
        path.addLine(to: CGPoint(x: 420, y: 0))
        path.addLine(to: CGPoint(x: 440, y: 30))
        path.addLine(to: CGPoint(x: 450, y: 30))
        path.addLine(to: CGPoint(x: 450, y: 210))
        path.addLine(to: CGPoint(x: 0, y: 210))

        // Draw arrow
        path.close()

        let shape = CAShapeLayer()
        //shape.backgroundColor = UIColor.blue.cgColor
        shape.fillColor = UIColor.white.cgColor
        shape.path = path.cgPath
        viewSettingControl.layer.insertSublayer(shape, at: 0)
    }
    func createViewAndReloadData()
    {
        urlIconWebsite = Global.sharedInstance.getIconWeb(sid:Int(self.infoArticleProto.video.sid))
        
//        imgIconPage.sd_setImage(with: URL(string: urlIconWebsite), placeholderImage: Global.sharedInstance.showPlaceHolderImage())
        
        self.createWebsiteApp()
        
        panRecognizerSliderVideo = UIPanGestureRecognizer.init(target: self, action:#selector(sliderVideo(sender:)))
        panRecognizerSliderVideo.minimumNumberOfTouches = 1
        panRecognizerSliderVideo.maximumNumberOfTouches = 1
        getComment = true
        collectionArticle = self.createCollectionView()
        self.view.insertSubview(collectionArticle!, at: 0)
        
        self.parseContent()
    }
    
    func createWebsiteApp()
    {
        self.viewModeWeb_App.isHidden = true
        print("BB: ", (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String))
        if(Global.sharedInstance.getModeInReview() == true)
        {
            self.lblTitleWeb.text = "Trình duyệt"
            self.lblTitleApp.text = "Ứng dụng gốc"
            
            self.viewOriginArticle.isHidden = false
            self.viewModeWeb_App.isHidden = false //thay doi
            
            self.lblOriginArticle.text = "Xem bài gốc"
            self.lblOriginArticle.font = UIFont.init(name: FONT_UITEXT_REGULAR, size: 14)
            self.lblOriginArticle.textColor = UIColor(rgb: 0xcFD9300)
            self.lblOriginArticle.textAlignment = .center
            self.lblOriginArticle.layer.borderColor = UIColor(rgb: 0xFF9500).cgColor
            self.lblOriginArticle.layer.borderWidth = 1
            self.lblOriginArticle.layer.masksToBounds = true
            self.lblOriginArticle.layer.cornerRadius = self.viewOriginArticle.frame.height/2
            
            viewOfWebsiteApp.backgroundColor = .white
            viewOfWebsiteApp.frame = CGRect(x: 0, y: 64 + (IS_IPHONE ? 44 : 60) + Global.sharedInstance.marginTopBarHeight(), width: checkLandScape, height: checkLandScapeHeight - (64 + (IS_IPHONE ? 44 : 60) + Global.sharedInstance.marginTopBarHeight()) - Global.sharedInstance.marginBottomBarHeight())
            self.view.addSubview(viewOfWebsiteApp)
            
            websiteApp = WKWebView()
            websiteApp?.navigationDelegate = self
            websiteApp?.frame = CGRect(x: 0, y: 0, width: viewOfWebsiteApp.frame.width, height: viewOfWebsiteApp.frame.height)
            viewOfWebsiteApp.addSubview(websiteApp!)
            
            let url = URL(string: self.infoArticleProto.video.fplayurl)!
            websiteApp!.load(URLRequest(url: url))
            
            websiteApp!.allowsBackForwardNavigationGestures = true
            
            let btn = UIButton()
            btn.tag = 0
            self.actionWeb_Native(btn: btn)
            
            //progressView.tintColor = UIColor(rgb: 0xF24F29)
            estimatedProgressObserver = websiteApp!.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
                self?.progressView.progress = Float(webView.estimatedProgress)
            }
        }
    }
    
    @objc func changeBackgroundColor(checkReloadWebview:Bool)
    {
        viewSettingControl.changeBGColor()
//        viewShadow.mixedBackgroundColor = .init(normal: Constant.Color.hexEBEBEBColor, night: Constant.Color.lineColorDarkMode)
        viewShadow.mixedBackgroundColor = .init(normal: .white, night: .darkGray)
        self.icon_setting.mixedImage = .init(normal: "icon_setting", night: "icon_setting_light")
        viewStatus.mixedBackgroundColor = .init(normal: Constant.Color.bgStatusBar, night: Constant.Color.bgStatusBarDark)
        self.view.mixedBackgroundColor = .init(normal: .white, night: Constant.Color.bgDarkModeColor)
        webView.mixedBackgroundColor = .init(normal: .white, night: Constant.Color.bgDarkModeColor)
        viewTitle.mixedBackgroundColor = .init(normal: .white, night: Constant.Color.blackColor)
        labelNameTopicView.textColor = .white
        labelTitleView.mixedTextColor = .init(normal: UIColor(rgb: 0x252525), night: .lightText)
        labelNameWebsites.mixedTextColor = .init(normal: UIColor(rgb: 0x4A90E2), night: .lightText)
        labelTimeStampView.mixedTextColor = .init(normal: UIColor(rgb: 0x7d7d7d), night: .lightText)
        lblTitle.mixedTextColor = .init(normal: UIColor(rgb: 0x252525), night: .lightText)

        
        imgBack.mixedImage = .init(normal: "icon_back_black", night: "icon_back_white")
        
        self.collectionArticle?.reloadData()
    }

    func showNotificationComment(str:String)
    {
        print("xong")
        labelNotifiSaveArticle.numberOfLines = 0
        labelNotifiSaveArticle.text
            = str
        UIView.animate(withDuration: 0, animations: {
            self.labelNotifiSaveArticle.isHidden = false
            self.labelNotifiSaveArticle.alpha = 0.9
        }, completion: nil)
        
        let width = Global.sharedInstance.getWidthText(title: labelNotifiSaveArticle.text!, font: labelNotifiSaveArticle.font)
        labelNotifiSaveArticle.frame = CGRect(x: 10, y: 20, width: width + 20, height: 40)
        labelNotifiSaveArticle.center = self.view.center
        UIView.animate(withDuration: 5, animations: {
            self.labelNotifiSaveArticle.alpha = 0
        }, completion: nil)
    }
    
    @objc func keyboardWillShow(notification:Notification)
    {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue, let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            UIView.animate(withDuration: duration, animations: {
                self.bottomInputConstraint?.constant = -keyboardHeight + (IS_IPHONE_X ? 34 : 0)
                self.textInput.lbAlert.snp.updateConstraints { (make) in
                    make.height.equalTo(30)
                }
                self.textInput.btnClear.snp.updateConstraints { (make) in
                    make.height.equalTo(30)
                    make.width.equalTo(50)
                }
                self.textInput.btnClear.alpha = 1
                self.textInput.lbAlert.alpha = 1
                self.view.layoutIfNeeded()
            }) { (result) in
                if self.textInput.textView.isFirstResponder {
                    self.textInput.textView.text = self.currentText
                    self.textInput.textViewDidChange(self.textInput.textView)
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification:Notification)
    {
        if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            UIView.animate(withDuration: duration, animations: {
                self.bottomInputConstraint?.constant = 0
                self.textInput.lbAlert.snp.updateConstraints { (make) in
                    make.height.equalTo(0)
                }
                self.textInput.btnClear.snp.updateConstraints { (make) in
                    make.height.equalTo(0)
                    make.width.equalTo(0)
                }
                self.textInput.lbAlert.alpha = 0
                self.textInput.btnClear.alpha = 0
                self.textInput.btnSend.snp.updateConstraints { (make) in
                    make.width.equalTo(0)
                }
                self.textInput.btnComment.snp.updateConstraints { (make) in
                    make.width.equalTo(52)
                }
                self.view.layoutIfNeeded()
            }) { (result) in
                if !self.textInput.textView.isFirstResponder {
                    self.currentText = self.textInput.textView.text
                    self.textInput.textView.text = ""
                }
            }
        }
    }
    
    func parseContent()
    {
        lblTitle.text = nameWebsite
        self.setFrameIconPage()
        
        // gui notif analytic
        
        //var stringDefaultFontNative
        if let increaseDf = UserDefault.sharedInstance.getFontSizeNative() {
            self.increase = increaseDf
        }
        
        self.parseContentNative(strContent:String(format: "<div>%@</div>", self.infoArticleProto.video.content))
    }
    
    func getThumbFromUrlM3u8(url:String) {
        DispatchQueue.main.async {
            let streamUrl = URL(string: url)!
            self.generatorThumb = ACThumbnailGenerator(streamUrl: streamUrl, strUrl: url)
            self.generatorThumb.delegate = self
            self.generatorThumb.captureImage(at: 1)
        }
    }
    
    func generateThumnailMp4(strUrl : String, completion: @escaping ((_ image: UIImage?)->Void)) {
        if strUrl.count > 0
        {
            print("strUrl: ", strUrl)
            if let url = URL.init(string: strUrl)
            {
                DispatchQueue.global().async {
                    let asset = AVAsset(url: url)
                    let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
                    avAssetImageGenerator.appliesPreferredTrackTransform = true
                    let thumnailTime = CMTimeMake(value: 1, timescale: 1)
                    do {
                        let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
                        let thumbImage = UIImage(cgImage: cgThumbImage)
                        DispatchQueue.main.async {
                            completion(thumbImage)
                        }
                    } catch {
                        print(error.localizedDescription)
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }
            }
        }
        DispatchQueue.main.async {
            completion(nil)
        }
    }
    
    func loadContentToWebView()
    {
        let strDes = self.infoArticleProto.video.desc
        
        let modeRead = UserDefault.sharedInstance.getSettingModeRead()
        if (modeRead == "readBlack")
        {
            self.view.backgroundColor = UIColor(rgb: 0x444343)
            icon_setting.image = UIImage.init(named: "icon_setting")
        }
        else
        {
            self.view.backgroundColor = .white
            icon_setting.image = UIImage.init(named: "icon_setting")
        }
        imgBack.mixedImage = .init(normal: "icon_back_black", night: "icon_back_white")
        let fontSize = Int(sizeFontCaption + increase)
        if(IS_IPAD)
        {
            contentTextWebview = String(format: "<html style='text-align:left;margin:0px 75px 0px 75px;background-color: transparent;'><head><style>body {font-family: %@;line-height:155%;color: #000000;}tbody {font-family:%@;line-height:155%;color: #000000;}b:not(.mytitle) {    font-family: %@;line-height:155%;    }strong{    font-family:%@;line-height:155%;    }i {    font-family:%@;text-align:left;line-height:155%;color: #000000;    }</style></head><style></style><body id = 'theninhWebview'><script>function showImageArticle(imgLoc){document.location = imgLoc}</script><script><script type='text/javascript'>var player; function onYouTubeIframeAPIReady(){player=new YT.Player('player')}</script></script><div style='text-align:left;margin-top:0px;'><div style='margin:0px auto;font-family:SF-UI-Display-Light !important;line-height:155%;color:white'></div><p> <span style='background-color: transparent;font-family:%@;line-height:155%;color:white'><b></b></span> <span style=' font-family:%@; line-height:155%;color: #FFFFFF; border-bottom:0px solid #222;padding:4px 0 ; margin:0px 0 '></span></p><div id ='theninhWebviewDiv' style='padding-top:%fpx'> <span style='background-color: transparent;font-family:%@;line-height:155%;color:black'><b>%@</b></span><span style='text-align:left;font-family:%@ !important;line-height:155%;padding-bottom:5px' >%@</span></div><script>function showImageArticle(imgLoc){document.location = imgLoc}</script>%@<script>document.getElementById('theninhWebview').style.fontSize = '%ldpx'</script></body></html>", FONT_UITEXT_REGULAR,FONT_UITEXT_REGULAR,FONT_UITEXT_REGULAR,FONT_UITEXT_REGULAR,FONT_UITEXT_REGULAR,FONT_UITEXT_REGULAR,FONT_UITEXT_REGULAR,(self.labelTimeStampView.frame.origin.y + 51),FONT_UITEXT_REGULAR,strDes,FONT_UITEXT_REGULAR,contentArticle,linkArticle,fontSize)
        }
        else
        {
            contentTextWebview = String(format: "<html style='text-align:left;margin:0px 4px 0px 4px;background-color: transparent;'><head><style>body {font-family: %@;line-height:35px;color: #000000;}tbody {font-family:%@;line-height:35px;color: #000000;}b:not(.mytitle) {    font-family: %@;line-height:35px;    }strong{    font-family:SF-UI-Text-Semibold;line-height:35px;    }i {    font-family:SFUIText-LightItalic;text-align:left;color: #000000;line-height:35px;    }</style><meta name='viewport' content='width=device-width,initial-scale=1'></head><style></style><body id = 'theninhWebview'><script>function showImageArticle(imgLoc){document.location = imgLoc}</script><script><script type='text/javascript'>var player; function onYouTubeIframeAPIReady(){player=new YT.Player('player')}</script></script><div style='text-align:left;margin-top:0px;'><div style='margin:0px auto;font-family:%@ !important;line-height:35px;color:white'></div><p> <span style='background-color: transparent;font-family:%@;line-height:35px;color:white'><b></b></span> <span style=' font-family:%@; line-height:35px;color: #FFFFFF; border-bottom:0px solid #222;padding:4px 0 ; margin:0px 0 '></span></p><div id ='theninhWebviewDiv' style='padding-top:%fpx'> <span style='background-color: transparent;font-family:%@;line-height:35px;color:black'><b>%@</b></span><span style='text-align:left;font-family:%@ !important;line-height:35px;padding-bottom:5px' >%@</span></div><script>function showImageArticle(imgLoc){document.location = imgLoc}</script>%@<script>document.getElementById('theninhWebview').style.fontSize = '%ldpx'</script></body></html>", FONT_UITEXT_REGULAR,FONT_UITEXT_REGULAR,FONT_UITEXT_REGULAR,FONT_UITEXT_REGULAR,FONT_UITEXT_REGULAR,FONT_UITEXT_REGULAR,(self.labelTimeStampView.frame.origin.y + 21),FONT_UITEXT_REGULAR,strDes,FONT_UITEXT_REGULAR,contentArticle,linkArticle,fontSize)
        }
        
        webView.loadHTMLString(contentTextWebview, baseURL: nil)
    }
    
    public func getHeightTextLabel(label: UILabel)->CGFloat {
        
        let attributedString = NSMutableAttributedString(string: label.text!, attributes:
            [NSAttributedString.Key.font:label.font]
        )
        
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let sizeOfString = attributedString.boundingRect(with: CGSize(width: checkLandScape - originX*2, height: 10000), options: options, context: nil)
        
        return CGFloat(sizeOfString.height)
    }
    
    func resizeHeightToFitForLabel(label:UILabel, text:String)
    {
        label.text = text
        self.resizeHeightToFitForLabel(label:label)
        label.sizeToFit()
    }
    
    func resizeHeightToFitForLabel(label:UILabel)
    {
        if(IS_IPAD)
        {
            var newFrame = label.frame
            newFrame.size.height = self.getHeightTextLabel(label: label)
            label.frame = newFrame
            
            let width1 = Global.sharedInstance.getWidthText(title: nameCategory, font: labelNameTopicView.font)
            labelNameTopicView.frame = CGRect(x: label.frame.origin.x, y: label.frame.maxY + 34, width: width1, height: 34)
            
            let width2 = Global.sharedInstance.getWidthText(title: " • " + timeStamp, font: labelTimeStampView.font)
            let width3 = Global.sharedInstance.getWidthText(title: self.nameWebsite.replacingOccurrences(of: " •", with: ""), font: labelNameWebsites.font)
            
            labelNameWebsites.frame = CGRect(x: width1 == 0 ? labelNameTopicView.frame.maxX : 19 + labelNameTopicView.frame.maxX, y: labelNameTopicView.frame.origin.y, width: width3, height: labelNameTopicView.frame.height)
            
            labelTimeStampView.frame = CGRect(x: labelNameWebsites.frame.maxX, y: labelNameTopicView.frame.origin.y, width: width2, height: labelNameTopicView.frame.height)
            
            buttonTopic.frame = CGRect(x: label.frame.origin.x, y: labelTitleView.frame.origin.y + labelTitleView.frame.height - 10, width: labelNameTopicView.frame.width, height: 70)
            
            buttonWebsites.frame = CGRect(x: buttonTopic.frame.maxX, y: buttonTopic.frame.origin.y, width: width2 + 10, height: buttonTopic.frame.height)
        }
        else
        {
            var newFrame = label.frame
            newFrame.size.height = self.getHeightTextLabel(label: label)
            label.frame = newFrame
            
            let width1 = Global.sharedInstance.getWidthText(title: nameCategory, font: labelNameTopicView.font)
            labelNameTopicView.frame = CGRect(x: 15, y: label.frame.maxY + 10, width: width1, height: 20)
            
            let width2 = Global.sharedInstance.getWidthText(title: " • " + timeStamp, font: labelTimeStampView.font)
            let width3 = Global.sharedInstance.getWidthText(title: self.nameWebsite.replacingOccurrences(of: " •", with: ""), font: labelNameWebsites.font)
            
            labelNameWebsites.frame = CGRect(x: width1 == 0 ? labelNameTopicView.frame.maxX : 8 + labelNameTopicView.frame.maxX, y: labelNameTopicView.frame.origin.y, width: width3, height: labelNameTopicView.frame.height)
            
            labelTimeStampView.frame = CGRect(x: labelNameWebsites.frame.maxX, y: labelNameTopicView.frame.origin.y, width: width2, height: labelNameTopicView.frame.height)
            
            buttonTopic.frame = CGRect(x: 15, y: labelTitleView.frame.origin.y + labelTitleView.frame.height - 10, width: labelNameTopicView.frame.width, height: 30)
            
            buttonWebsites.frame = CGRect(x: buttonTopic.frame.maxX, y: buttonTopic.frame.origin.y, width: width2 + 10, height: buttonTopic.frame.height)
        }
        
        labelNameTopicView.layer.masksToBounds = true
        labelNameTopicView.layer.cornerRadius = labelNameTopicView.frame.height/2
    }
    
    
    func parseContentNative(strContent: String)
    {
        let arrayUrlVideo = self.infoArticleProto.video.listVideos
        if(arrayUrlVideo.count > 0)
        {
            let newContributors = NSMutableDictionary.init()
            //newContributors.setObject(index, forKey: "index" as NSCopying)
            newContributors.setObject("video", forKey:"type" as NSCopying)
            
            newContributors.setObject(arrayUrlVideo, forKey: "content" as NSCopying)
            arrayContent.add(newContributors)
            
            let url = arrayUrlVideo[0]
            //
            dictUrl_ContributorVideo .setObject(newContributors, forKey: url as NSCopying)
            if(url.contains(".m3u8") == true)
            {
                self.getThumbFromUrlM3u8(url: url)
            }
            else if(url.contains(".mp4") == true)
            {
                self.generateThumnailMp4(strUrl: url) { [weak self] (image) in
                    
                    guard let strongSelf = self else { return }
                    
                    if(image != nil)
                    {
                        let index = strongSelf.arrayContent.index(of: newContributors)
                        strongSelf.arrayContent.remove(newContributors)
                        newContributors.setObject(image as Any, forKey: "imgThumnail" as NSCopying)
                        newContributors.setObject(image!.size.height/image!.size.width, forKey: "height" as NSCopying)
                        strongSelf.arrayContent.insert(newContributors, at: index)
                        strongSelf.collectionArticle?.reloadData()
                    }
                }
            }
            self.getRelateArticle()
        }
    }
    
    func getRelateArticle()
    {
        if(getComment == true)
        {
            ///goi ham getcomment
            
            //arrayBadWord = dangxem
            dicLidComment = UserDefault.sharedInstance.getArrayArticleLike()
            
            let id_User = UserDefault.sharedInstance.getIdComment()
            let parameter = ["offset": "0","id": id_User, "lid": self.infoArticleProto.video.lid, "size": "2", "type" : "latest"] as Parameters
            
            print("para: ", parameter)
            
            APIRequest.sharedInstance.getAllComment(level: 0, parameter: parameter) { [weak self] (result, error) in
                guard let strongSelf = self else { return }
                if(error == nil && result != nil)
                {
                    if let dictResult = result as? NSDictionary
                    {
                        if let total = dictResult.object(forKey: "total") as? Int
                        {
                            if(total > 0)
                            {
                                
                                                                
                                strongSelf.arrayCommentArticle.removeAllObjects()
                                strongSelf.arrayCommentArticle.addObjects(from: dictResult.object(forKey: "data") as! [Any])
                                main {
                                    strongSelf.textInput.btnComment.addBadge(badge: total)
                                    
                                    if(Global.sharedInstance.getModeInReview() == true)
                                    {
                                        if(total > 2)
                                        {
                                            strongSelf.textInput.btnComment.addBadge(badge: 2)
                                        }
                                    }
                                    strongSelf.collectionArticle?.reloadData()
                                }
                            }
                        }
                    }
                }
            }
            self.extentGetRelate()
            getComment = false
        }
    }
    
    func extentGetRelate()
    {
        APIRequest.sharedInstance.getRelatedArticle(lid: self.infoArticleProto.video.lid, typeToDetail: self.typeToDetail) { [weak self] (result, error) in
            guard let strongSelf = self else { return }

            strongSelf.arrayArticleRelated.removeAllObjects()
            strongSelf.arrayArticleTopRead.removeAllObjects()

            if let dataResult = result as? Data
            {
                do
                {
                    let model_ListingResponse = try Model_RelativeResponses(serializedData: dataResult)
                    strongSelf.arrayArticleRelated.addObjects(from: model_ListingResponse.linfos)
                    strongSelf.arrayArticleTopRead.addObjects(from: model_ListingResponse.topread)
                    
                    strongSelf.requestGoogleDFP(postion: XKPotisionAdsGoogle.XKPotisionLast)
                    strongSelf.requestGoogleDFP(postion: XKPotisionAdsGoogle.XKPositionCenter2)
                    
                    if strongSelf.arrayArticleRelated.count > 0 || strongSelf.arrayArticleTopRead.count > 0 {
                        strongSelf.didLoadRelateArticle = true
                    }
                    main {
                        strongSelf.collectionArticle?.reloadWithoutAnimation()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        strongSelf.calcPlayVideo()
                    }
                }
                catch {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        strongSelf.calcPlayVideo()
                    }
                }
            }
        }
        
    }
    
    func minHeightForText(text: String)->CGFloat
    {
        let attributedString = NSMutableAttributedString(string: text as String, attributes:
            [NSAttributedString.Key.font:UIFont.init(name: FONT_UITEXT_REGULAR, size: 15)!])
        
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        var sizeOfString = attributedString.boundingRect(with: CGSize(width: 656, height: 9999), options: options, context: nil)
        if(IS_IPAD)
        {
            sizeOfString = attributedString.boundingRect(with: CGSize(width: SCREEN_WIDTH - 63, height: 9999), options: options, context: nil)
        }
        
        return CGFloat(sizeOfString.height)
    }
    
    
    func usingNSRange(stringContent:NSString, strDivRange:NSString, strEndDivRange:NSString)->NSArray
    {
        if(stringContent.length>0)
        {
            let string = stringContent
            let results = NSMutableArray.init()
            var divRange = string.range(of: strDivRange as String, options: .caseInsensitive)
            while (true)
            {
                if(string.length>divRange.location)
                    //if(divRange.length < string.length)
                {
                    divRange = string.range(of: strDivRange as String, options: .caseInsensitive, range: divRange)
                    
                    if(divRange.location == NSNotFound)
                    {
                        break
                    }
                    
                    var endDivRange = NSRange()
                    endDivRange.location = divRange.length + divRange.location
                    endDivRange.length = string.length - endDivRange.location
                    endDivRange = string.range(of: strEndDivRange as String, options: .caseInsensitive, range: endDivRange)
                    //163 2
                    
                    if(endDivRange.location == NSNotFound)
                    {
                        break
                    }
                    
                    divRange.location = divRange.length + divRange.location
                    divRange.length = endDivRange.location - divRange.location
                    //18 145
                    
                    let result = string.substring(with: divRange)
                    results.add(result.count>0 ? result : ";")
                    divRange.location = endDivRange.location + endDivRange.length + 1
                    //166 145
                    
                    print("str: ", string)
                    print("str: ", string.length)
                    print("divran:", divRange.location)
                    
                    divRange.length = string.length - divRange.location
                    //166 -1
                }
                else
                {
                    break
                }
            }
            
            return results
        }
        
        return NSArray.init()
    }
    
    func setFrameIconPage()
    {
//        let size = Global.sharedInstance.getWidthText(title: self.lblTitle.text!, font: self.lblTitle.font)
//        let oX:CGFloat = size/2
//        let x = SCREEN_WIDTH/2 - self.imgIconPage.frame.width - 10 - oX
//        var rect = self.imgIconPage.frame
//        rect.origin.x = x
//        //        if(IS_IPAD)
//        //        {
//        //            rect.origin.y = 17
//        //        }
//        self.imgIconPage.frame = rect
//
//        self.imgIconPage.layer.masksToBounds = true
//        self.imgIconPage.layer.cornerRadius = self.imgIconPage.frame.width/2
    }
    
    func reloadWebview()
    {
        print("reloadWebview")
    }
    var subcid: Int = 0
    var arrayCatOfVideo = NSMutableArray()
    @objc func clickTopic()
    {
//        let storyboard = Global.sharedInstance.getMainStoryboard()
//        let listvideo = storyboard.instantiateViewController(withIdentifier: "ListVideoViewController") as! ListVideoViewController
//        listvideo.subcid = subcid
//        listvideo.arrayCatOfVideo = self.arrayCatOfVideo
//        listvideo.nameCategory = nameCategory
//        listvideo.isMainPage = false
//        self.navigationController?.pushViewController(listvideo, animated: true)
    }
    
    @objc func clickWebSites()
    {
        if let dictData = UserDefault.sharedInstance.getArrayWebsiteKhamPha() {
            for i in 0..<dictData.count {
                if let data = dictData[i] as? NSDictionary {
                    if let websites = data.object(forKey: "websites") as? NSArray {
                        for k in 0..<websites.count {
                            if let item = websites[k] as? NSDictionary {
                                if let websiteName = item.object(forKey: "name") as? String {
                                    if websiteName == nameWebsite {
                                        let storyboard = Global.sharedInstance.getMainStoryboard()
                                        let pageListNewsViewController = storyboard.instantiateViewController(withIdentifier: "PageListNewsViewController") as! PageListNewsViewController
                                        pageListNewsViewController.dictArticle = item
                                        
                                        FirebaseAnalyticLog.sharedInstance.logEvent(eventName: NEWSPAPER, itemID: "", itemName: websiteName, itemCategory: "")
                                        self.navigationController?.pushViewController(pageListNewsViewController, animated: true)
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func createWebview()
    {
        self.webView.scrollView.isScrollEnabled = false
        scrollWebView.backgroundColor = .clear
        if(IS_IPAD)
        {
            if iOS_VERSION_LESS_THAN(version: "11.0") {
                scrollWebView.frame = CGRect(x: 0, y: 77, width: checkLandScape, height: checkLandScapeHeight - 20 - 8 - Global.sharedInstance.marginBottomBarHeight())
            } else {
                scrollWebView.frame = CGRect(x: 0, y: 77, width: checkLandScape, height: checkLandScapeHeight - 20 - 57 - Global.sharedInstance.marginBottomBarHeight())
            }
            
            
            webView.frame = CGRect(x: 0, y: 0, width: scrollWebView.frame.width, height: scrollWebView.frame.height)
        }
        else
        {
            if iOS_VERSION_LESS_THAN(version: "11.0") {
                scrollWebView.frame = CGRect(x: 0, y: 64 + (self.websiteApp != nil ? 54 : 0) + Global.sharedInstance.marginTopBarHeight(), width: checkLandScape, height: checkLandScapeHeight - (20 + (self.websiteApp != nil ? 54 : 0) + Global.sharedInstance.marginTopBarHeight()) - Global.sharedInstance.marginBottomBarHeight())
            } else {
                scrollWebView.frame = CGRect(x: 0, y: 64 + (self.websiteApp != nil ? 54 : 0) + Global.sharedInstance.marginTopBarHeight(), width: checkLandScape, height: checkLandScapeHeight - (20 + 44 + (self.websiteApp != nil ? 54 : 0) + Global.sharedInstance.marginTopBarHeight()) - Global.sharedInstance.marginBottomBarHeight())
            }
            webView.frame = CGRect(x: 0, y: 0, width: scrollWebView.frame.width, height: scrollWebView.frame.height)
        }
        
        webView.navigationDelegate = self
        //webView.scalesPageToFit = false
        webView.scrollView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 15)
        webView.scrollView.backgroundColor = .clear
        webView.isOpaque = false
        
        scrollWebView.addSubview(webView)
        self.view.insertSubview(scrollWebView, at: 0)
    }
    
    func createCollectionView()->UICollectionView
    {
        var frame = CGRect(x: 0, y: 64 + (self.websiteApp != nil ? 44 : 0) + Global.sharedInstance.marginTopBarHeight(), width: checkLandScape, height: checkLandScapeHeight - (60 + (self.websiteApp != nil ? 44 : 0) + Global.sharedInstance.marginTopBarHeight() + Global.sharedInstance.marginBottomBarHeight()))
        if iOS_VERSION_LESS_THAN(version: "11.0") {
            frame = CGRect(x: 0, y: 64 + (self.websiteApp != nil ? 44 : 0) + Global.sharedInstance.marginTopBarHeight(), width: checkLandScape, height: checkLandScapeHeight - (20 + (self.websiteApp != nil ? 44 : 0) + Global.sharedInstance.marginTopBarHeight() + Global.sharedInstance.marginBottomBarHeight()))
        }
        if(IS_IPAD)
        {
            var y: CGFloat = 77
            if Global.sharedInstance.getModeInReview() == true {
                y = 127
            }
            if iOS_VERSION_LESS_THAN(version: "11.0") {
                frame = CGRect(x: 0, y: y, width: checkLandScape, height: checkLandScapeHeight - y + 50)
            } else {
                frame = CGRect(x: 0, y: y, width: checkLandScape, height: checkLandScapeHeight - y)
            }
        }
        
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.itemSize = CGSize(width: 10, height: 10)
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView.init(frame: frame, collectionViewLayout: flowLayout)
        self.registerAllNibForCollection(collectionView: collectionView)
        collectionView.bounces = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = true
        return collectionView
    }
    
    func registerAllNibForCollection(collectionView:UICollectionView)
    {
        
        collectionView.register(UINib.init(nibName: "DetailNewsUtilityCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DetailNewsUtilityCollectionViewCell")
    
        collectionView.register(UINib.init(nibName: "ListNewsCollectionViewCell1", bundle: nil), forCellWithReuseIdentifier: "ListNewsCollectionViewCell1")
                
        collectionView.register(UINib.init(nibName: "CellTitleNative", bundle: nil), forCellWithReuseIdentifier: "CellTitleNative")
        collectionView.register(UINib.init(nibName: "CellDesNative", bundle: nil), forCellWithReuseIdentifier: "CellDesNative")
        collectionView.register(UINib.init(nibName: "CellTextNative", bundle: nil), forCellWithReuseIdentifier: "CellTextNative")
        collectionView.register(UINib.init(nibName: "CellSuperCategory", bundle: nil), forCellWithReuseIdentifier: "CellSuperCategory")
        
        collectionView.register(UINib.init(nibName: "CellImageNative", bundle: nil), forCellWithReuseIdentifier: "CellImageNative")
        
        collectionView.register(UINib.init(nibName: "CriticalOfCriticalCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CriticalOfCriticalCollectionViewCell")
        
        collectionView.register(UINib.init(nibName: IdentifierCellSponser, bundle: nil), forCellWithReuseIdentifier: IdentifierCellSponser)
        collectionView.register(UINib.init(nibName: "CellVideoNative", bundle: nil), forCellWithReuseIdentifier: "CellVideoNative")
        collectionView.register(UINib.init(nibName: "CellAdsNative", bundle: nil), forCellWithReuseIdentifier: "CellAdsNative")
        
        collectionView.register(UINib(nibName: "ContentHeaderCollection", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ContentHeaderCollection")
        collectionView.register(UINib(nibName: "ViewOriginArticleCollectionViewCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ViewOriginArticleCollectionViewCell")
        collectionView.register(UINib(nibName: "ViewAdsArticleDetailCollectionViewCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ViewAdsArticleDetailCollectionViewCell")
        collectionView.register(UINib(nibName: "TitleTLQCollectionViewCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TitleTLQCollectionViewCell")
        collectionView.register(UINib(nibName: "ViewMoreCriticalCollectionViewCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ViewMoreCriticalCollectionViewCell")
        collectionView.register(UINib(nibName: "PopVCCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "PopVCCollectionReusableView")
    }
    
    @objc func sliderVideo(sender:Any)
    {
        
    }
    
    @IBAction func actionBack()
    {
        //thong ke
        FirebaseAnalyticLog.sharedInstance.logEvent(eventName: APP_BACK, itemID: "", itemName: "", itemCategory: "")
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionWeb_Native(btn: UIButton)
    {
        if(btn.tag == 0)
        {
            print("dang web")
            viewOfWebsiteApp.isHidden = false
            self.icon_setting.isHidden = true
            self.btnSetting.isHidden = true
            
            self.viewLineWeb.isHidden = false
            self.viewLineApp.isHidden = true
            
            self.lblTitleWeb.font = UIFont.init(name: FONT_SFDISPLAY_SEMIBOLD, size: 14)
            self.lblTitleApp.font = UIFont.init(name: FONT_SFDISPLAY_SEMIBOLD, size: 14)
            
            self.progressView.alpha = 1
            self.progressView.isHidden = false
            if playerView.superview != nil {
                playerView.pause()
                playerView.isHidden = true
            }
        }
        else
        {
            print("dang in app")
            viewOfWebsiteApp.isHidden = true
            self.icon_setting.isHidden = false
            self.btnSetting.isHidden = false
            
            self.viewLineWeb.isHidden = true
            self.viewLineApp.isHidden = false
            
            self.lblTitleApp.font = UIFont.init(name: FONT_SFDISPLAY_SEMIBOLD, size: 14)
            self.lblTitleWeb.font = UIFont.init(name: FONT_SFDISPLAY_SEMIBOLD, size: 14)
            
            self.progressView.alpha = 0
            self.progressView.isHidden = true
            if playerView.superview != nil {
                playerView.isHidden = false
            }
        }
    }
    
    @IBAction func actionOriginArticle()
    {
        if let url = URL(string: self.infoArticleProto.video.url) {
            // check if your application can open the NSURL instance
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return
        }
    }
   
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerView.pause()
        let scriptStopYTB = "document.getElementById('ytplayer').contentWindow.postMessage('{\"event\":\"command\",\"func\":\"' + 'stopVideo' + '\",\"args\":\"\"}', '*');"
        webView.evaluateJavaScript(scriptStopYTB, completionHandler: nil)
        webView.stopLoading()
//        stopVideo = true
        
        let script = "var videos = document.querySelectorAll(\"video\"); for (var i = videos.length - 1; i >= 0; i--) { videos[i].pause(); };"
        webView.evaluateJavaScript(script, completionHandler: nil)
        webView.evaluateJavaScript("player = document.getElementById('ytplayer');function stop(){player.stopVideo();return false;}", completionHandler: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        
        if playerView.isFullScreen {
            playerView.fullScreenButtonPressed()
        }
        playerView.pause()
        textInput.textView.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationBecomeActiveDetailVideo), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        dicLidComment = UserDefault.sharedInstance.getArrayArticleLike()
        
        dictArrNewsFade = DBManagement.share.getLidReaded()
        self.collectionArticle?.reloadData()
        
        isMarked = Global.sharedInstance.checkImageBookMark(lid: self.infoArticleProto.video.lid)
        
        textInput.btnSave.isSelected = isMarked
        
        self.clickHiddenKeyboard()
        self.textInput.refreshAvatar()
        
        let strAutoVideo = UserDefault.sharedInstance.getSettingAutoPlayVideo()
        if(strAutoVideo == "1") {
            if playerView.superview != nil{
                playerView.play()
            }
        }
        
        viewSettingControl.updateSlider()
    }
    func reloadFontSize() {
        guard let inc = UserDefault.sharedInstance.getFontSizeNative() else {return}
        increase = inc
        collectionArticle?.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        changeVideoPlayerFrame(orientation: UIDevice.current.orientation)
    }
    
    fileprivate func changeVideoPlayerFrame(orientation: UIDeviceOrientation) {
        
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            orientationLandscape()
        case .portrait, .portraitUpsideDown:
            orientationPortrait()
        default: break
        }
        self.view.layoutIfNeeded()
    }
    var originPlayerFrame = CGRect.zero
    var originPlayerFrame2 = CGRect.zero
    fileprivate func orientationLandscape() {
        if originPlayerFrame == CGRect.zero {
            originPlayerFrame = playerView.frame
        }
        playerView.controlView.hiddenButton.isHidden = true
        if(IS_IPHONE)
        {
            playerView.transform = CGAffineTransform.init(rotationAngle: -CGFloat(Double.pi/2))
            playerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
            playerView.controlView.frame = playerView.frame
            self.view.layoutIfNeeded()
        }
        else
        {
            playerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT )
        }
        view.addSubview(playerView)
    }
    
    fileprivate func orientationPortrait() {
        playerView.transform = CGAffineTransform.init(rotationAngle: CGFloat(0))
        if isSuperViewCollectionViewCell {
            playerView.frame = originPlayerFrame
            currentCellNative.addSubview(playerView)
        } else {
            playerView.frame = originPlayerFrame2
            playerView.controlView.hiddenButton.isHidden = false
            self.view.addSubview(playerView)
        }
    }
    
    func pushViewAds(url:String)
    {
        let storyboard = Global.sharedInstance.getMainStoryboard()
        let webKitViewController = storyboard.instantiateViewController(withIdentifier: "WebKitViewController") as! WebKitViewController
        webKitViewController.url = url
        webKitViewController.strTitle = lblTitle.text!
        self.navigationController?.pushViewController(webKitViewController, animated: true)
    }
}
extension DetailVideoViewController: BMPlayerDelegate {
    
    func bmPlayer(player: BMPlayer, playerOrientChanged isFullscreen: Bool) {
        endEditting()
        if !isFullscreen {
            self.showStatusBar()
            changeVideoPlayerFrame(orientation: UIDeviceOrientation.portrait)
        } else {
            self.hiddenStatusBar()
            changeVideoPlayerFrame(orientation: UIDeviceOrientation.landscapeRight)
        }
    }
    
    func bmPlayer(player: BMPlayer, playerIsPlaying playing: Bool) {
        print("| BMPlayerDelegate | playerIsPlaying | playing - \(playing)")
    }
    
    func bmPlayer(player: BMPlayer, playerStateDidChange state: BMPlayerState) {
        print("| BMPlayerDelegate | playerStateDidChange | state - \(state)")
        switch state {
        case .readyToPlay:
            player.controlView.replayButton.isHidden = true
        case .error:
            UIApplication.shared.keyWindow!.makeToast(message: "Kết nối mạng có vấn đề hoặc video bạn đang xem đã bị xóa!")
        default:
            break
        }
    }
    
    func bmPlayer(player: BMPlayer, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
        
        let url = player.resource.definitions[player.currentDefinition].url.absoluteString
        guard let viewsituation = self.currentCellNative.viewSituations, let situation = player.videoMeta[url]?.situation, situation.count > 0 else {
            return
        }

        if let idx = situation.firstIndex(where: { TimeInterval($0.position) > currentTime})
        {
            if idx < 1, currentSeekTime != 0, currentTime > 0 {
                viewsituation.resetCell()
                return
            }
            if idx - 1 < 0 {
                return
            }
            let idp = IndexPath(item: idx - 1, section: 0)
            self.currentSeekTime = Int(situation[idx].position)
            viewsituation.reloadCell(indexPath: idp)
        } else {
            if let last = situation.last, currentTime > TimeInterval(last.position) {
                let idp = IndexPath(item: situation.count - 1, section: 0)
                viewsituation.reloadCell(indexPath: idp)
            }
        }
    }
    
    func bmPlayer(player: BMPlayer, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {
    }
    
    func bmPlayer(player: BMPlayer, playerIsMute isMute: Bool) {
        UserDefaults.standard.set(isMute, forKey: "mute")
//        let av = AVAudioSession.sharedInstance()
//        if isMute {
//            do {
//                try av.setCategory(.playback, options: .mixWithOthers)
//                try av.setActive(true)
//            } catch {
//
//            }
//        } else {
//            do {
//                try av.setCategory(.soloAmbient, options: .defaultToSpeaker)
//                try av.setActive(true)
//            } catch {
//
//            }
//        }
    }
    
    func bmPlayer(player: BMPlayer, didChangeDefinition currentIndex: Int) {
        if player.isPlaying {
            currentSeekTime = 0
        }
        
        if currentCellNative.videoIndex != currentIndex {
            currentCellNative.videoIndex = currentIndex
            if currentCellNative.viewSituations != nil {
                currentCellNative.viewSituations.currentSelectedCell = nil
                currentCellNative.viewSituations.collectionView.reloadWithoutAnimation()
            }
        }
    }
    
    func bmPlayerDidClickClose() {
        playerView.alpha = 0
    }
}

extension DetailVideoViewController : ModeControlArticleDelegate {
    func actionNightMode() {
        self.circleAnim(duration: 0.3, above: collectionArticle!)
        NightNight.toggleNightTheme()
        let isReadBlack = NightNight.currentTheme == NightNight.Theme.normal ? false : true
        
        if viewSettingControl.switchNightMode.isOn != true &&  isReadBlack != true {
            UserDefault.sharedInstance.setSettingModeRead(modeRead: "readWhite")
        } else {
            UserDefault.sharedInstance.setSettingModeRead(modeRead: "readBlack")

            //thong ke setting darkmode
            FirebaseAnalyticLog.sharedInstance.logEvent(eventName: SETTING, itemID: "", itemName: SETTING_NIGHT_MODE, itemCategory: "")
        }
        
        viewSettingControl.updateSlider()
        
        self.view.layoutIfNeeded()
        self.viewWillAppear(true)
    }
    
    func actionAutoPlay() {
        if viewSettingControl.switchAutoPlay.isOn != true {
            UserDefault.sharedInstance.setSettingAutoPlayVideo(mode: "0")
        } else {
            UserDefault.sharedInstance.setSettingAutoPlayVideo(mode: "1")
        }
    }
    
    func actionReport() {
        self.actionClosePopupSetting()
        
        self.viewInteract.lid = self.infoArticleProto.video.lid
        self.viewInteract.actionOpen()
    }
    
    func actionFontSize(sizeFont: Int) {
        if sizeFont < 4 {
            increase = -6
        } else if sizeFont > 10 {
            increase = 6
        } else {
            increase = CGFloat((sizeFont - 7)*2)
        }
        UserDefault.sharedInstance.setFontSizeNative(fontSize: increase)
        reloadFontSize()
    }
}

//extension DetailVideoViewController : FBSDKSharingDelegate {
//    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
//
//    }
//
//    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
//
//    }
//
//    func sharerDidCancel(_ sharer: FBSDKSharing!) {
//
//    }
//}

extension DetailVideoViewController : ViewPopupLoginDelegate
{
    func loginFailed() {
        self.clickHiddenKeyboard()
    }
    
    func loginSuccess(messageText:String) {
        self.textInput.refreshAvatar()
        self.showNotificationComment(str: messageText)
        
        self.clickHiddenKeyboard()
    }
}

extension DetailVideoViewController : ACThumbnailGeneratorDelegate
{
    func generator(_ generator: ACThumbnailGenerator, didCapture image: UIImage, at position: Double) {
        
        let url = generator.strUrl
        print("url:", url)
        
        if(dictUrl_ContributorVideo.object(forKey: url) != nil)
        {
            let newContributors = dictUrl_ContributorVideo.object(forKey: url) as! NSMutableDictionary
            let index = arrayContent.index(of: newContributors)
            arrayContent.remove(newContributors)
            newContributors.setObject(image, forKey: "imgThumnail" as NSCopying)
            newContributors.setObject(image.size.height/image.size.width, forKey: "height" as NSCopying)
            arrayContent.insert(newContributors, at: index)
            self.collectionArticle?.reloadData()
        }
    }
    
    func generatorFail(_ generator: ACThumbnailGenerator) {
        
    }
}

extension DetailVideoViewController : ViewOriginArticleCollectionViewCellDelegate
{
    func actionClickOriginPaper() {
        self.pushViewAds(url: self.infoArticleProto.video.url)
    }
    
    func actionReportArticle() {
        self.actionClosePopupSetting()
        
        self.viewInteract.lid = self.infoArticleProto.video.lid
        self.viewInteract.actionOpen()
    }
    
    func actionLikeArticle() {
        let arrayArticleLiked = UserDefault.sharedInstance.getArrayArticleLiked()
        let lid = self.infoArticleProto.video.lid
        //print("lid: ", lid)
        
        if(arrayArticleLiked?.contains(lid) == false)
        {
            arrayArticleLiked?.add(lid)
            
            let arrayArticleDisliked = UserDefault.sharedInstance.getArrayArticleDisliked()
            let lid = self.infoArticleProto.video.lid
            //print("lid: ", lid)
            
            if(arrayArticleDisliked?.contains(lid) == true)
            {
                arrayArticleDisliked?.remove(lid)
            }
            UserDefault.sharedInstance.setArrayArticleDisliked(arrayArticleDisliked: arrayArticleDisliked!)
        }
        else
        {
            arrayArticleLiked?.remove(lid)
        }
        UserDefault.sharedInstance.setArrayArticleLiked(arrayArticleLiked: arrayArticleLiked!)
        
        
        self.collectionArticle?.reloadSections(IndexSet(integer: 1))
        
    }
}

extension DetailVideoViewController : CriticalOfCriticalCollectionViewCellDelegate
{
    func CriticalOfCriticalCollectionViewCell_ClickReply(button: UIButton) {
        
        if let dictData = self.arrayCommentArticle.object(at: button.tag) as? NSDictionary
        {
            FirebaseAnalyticLog.sharedInstance.logEvent(eventName: INTERACTION, itemID: "", itemName: REPLY_COMMENT, itemCategory: "")
            let storyboard = Global.sharedInstance.getMainStoryboard()
                    
            let replyViewController = storyboard.instantiateViewController(withIdentifier: "ReplyCriticalViewController") as! ReplyCriticalViewController
            replyViewController.lid = self.infoArticleProto.video.lid
            replyViewController.offset = "0"
            if let id = dictData.object(forKey: "id") as? String
            {
                replyViewController.parentid = id
            }
            replyViewController.commentParent = dictData
            replyViewController.infoArticleProto = self.infoArticleProto
                        
            self.navigationController?.pushViewController(replyViewController, animated: true)
        }
    }
    
    func CriticalOfCriticalCollectionViewCell_ClickLike(button: UIButton) {
        if(UserDefault.sharedInstance.getIdComment() == "")
        {
            self.showViewLogin(text: TEXT_LOGINFB_COMMENT, textResult: TEXT_LOGINFB_COMMENT_RESULT)
        }
        else
        {
            //thong ke
            FirebaseAnalyticLog.sharedInstance.logEvent(eventName: INTERACTION, itemID: "", itemName: LIKE_COMMENT, itemCategory: "")
            
            let dict = self.arrayCommentArticle.object(at: button.tag) as! NSDictionary
            
            button.isEnabled = false
            if(dicLidComment.object(forKey: dict.object(forKey: "id") as Any) != nil)
            {
                let id_User = UserDefault.sharedInstance.getIdComment()
                let parameter = ["cmtid" : dict.object(forKey: "id")!, "content": textInput.textView.text,"id": id_User, "lid": self.infoArticleProto.video.lid, "vote":"0"] as Parameters
                
                APIRequest.sharedInstance.postLikeComment(parameter: parameter) { [weak self] (result, error) in
                    guard let strongSelf = self else { return }
                    if(result != nil && error == nil)
                    {
                        let dic = NSMutableDictionary.init()
                        dic.addEntries(from: dict as! [AnyHashable : Any])
                        if(dict.object(forKey: "like") as! Int - 1 >= 0 )
                        {
                            dic.setObject(dict.object(forKey: "like") as! Int - 1, forKey: "like" as NSCopying)
                        }
                        else
                        {
                            dic.setObject("0", forKey: "like" as NSCopying)
                        }
                        
                        UserDefault.sharedInstance.setArrayArticleLike(str: dict.object(forKey: "id") as! String)
                        strongSelf.dicLidComment = UserDefault.sharedInstance.getArrayArticleLike()
                    }
                    button.isEnabled = true
                    strongSelf.collectionArticle?.reloadData()
                }
            }
            else
            {
                let id_User = UserDefault.sharedInstance.getIdComment()
                let parameter = ["cmtid" : dict.object(forKey: "id")!, "content": textInput.textView.text,"id": id_User, "lid": self.infoArticleProto.video.lid, "vote":"1"] as Parameters
                
                APIRequest.sharedInstance.postLikeComment(parameter: parameter) { [weak self] (result, error) in
                    guard let strongSelf = self else { return }
                    if(result != nil && error == nil)
                    {
                        let dic = NSMutableDictionary.init()
                        dic.addEntries(from: dict as! [AnyHashable : Any])
                        dic.setObject(dict.object(forKey: "like") as! Int + 1, forKey: "like" as NSCopying)
                        
                        UserDefault.sharedInstance.setArrayArticleLike(str: dict.object(forKey: "id") as! String)
                        strongSelf.dicLidComment = UserDefault.sharedInstance.getArrayArticleLike()
                    }
                    button.isEnabled = true
                    strongSelf.collectionArticle?.reloadData()
                }
            }
        }
    }
    
    func CriticalOfCriticalCollectionViewCell_ClickLink(link: String) {
        self.actionClickLink(link: link)
    }
}

extension DetailVideoViewController: SKPhotoBrowserDelegate {
    func activetyDidClick(activity: UIActivity.ActivityType, success: Bool) {
        if(activity == UIActivity.ActivityType.saveToCameraRoll)
        {
            UIApplication.shared.keyWindow!.makeToast(message: "Ảnh đã được lưu thành công!", duration: 1, position: HRToastPositionDefault as AnyObject)
        }
        else if activity == UIActivity.ActivityType.copyToPasteboard
        {
            UIApplication.shared.keyWindow!.makeToast(message: "Copy ảnh thành công!", duration: 1, position: HRToastPositionDefault as AnyObject)
        }
        else
        {
            UIApplication.shared.keyWindow!.makeToast(message: "Thao tác thành công!", duration: 1, position: HRToastPositionDefault as AnyObject)
        }
    }
}

extension DetailVideoViewController : AdsGoogleDFPDelegate
{
    func AdsGoogleDFP_didReceiveBanner(adsGoogleObject: AdsGoogleObject, isAdsCenter: AdPosition) {
        print("AdsGoogleDFP_didReceiveBanner")
        let adView = adsGoogleObject.typeAdsGoogle == .XKBannerView ? adsGoogleObject.bannerViewDFP! : adsGoogleObject.bannerViewGAD!
        if isAdsCenter == .adEndContent {
            self.arrayAdsLastArticle.removeAllObjects()
            self.arrayAdsLastArticle.add(adView)
            self.collectionArticle?.reloadData()
        }
        else {
           self.arrayAdsCenter2.removeAllObjects()
           self.arrayAdsCenter2.add(adView)
        }
        main {
            UIView.performWithoutAnimation {
                self.collectionArticle?.reloadData()
            }
        }
        
    }
    
    func AdsGoogleDFP_didReceiveNative(nativeAd: GADNativeAd, isAdsCenter: AdPosition) {
        let adsGoogleObject = AdsGoogleObject.init()
        adsGoogleObject.nativeAd = nativeAd
        adsGoogleObject.typeAdsGoogle = XKTypeAdsGoogle.XKUnifiedNative
        
        if isAdsCenter == .adEndContent {
            self.arrayAdsLastArticle.removeAllObjects()
            self.arrayAdsLastArticle.add(adsGoogleObject)
            self.collectionArticle?.reloadData()
        }
        else {
           self.arrayAdsCenter2.removeAllObjects()
           self.arrayAdsCenter2.add(adsGoogleObject)
        }
        
        main {
            UIView.performWithoutAnimation {
                self.collectionArticle?.reloadData()
            }
        }
    }
    
    func AdsGoogleDFP_didFailToReceiveAdWithError(error: Error, isAdsCenter: AdPosition) {
        print("AdsGoogleDFP_didFailToReceiveAdWithError")
    }
}

extension DetailVideoViewController : ViewInteractDelegate
{
    func actionLogin() {
        self.showViewLogin(text: TEXT_LOGINFB_REPORT, textResult: TEXT_LOGINFB_REPORT_RESULT)
    }
    
    func actionViewInteract(text: String) {
        UIApplication.shared.keyWindow!.makeToast(message: text)
    }
}

extension DetailVideoViewController : ListNewsUtilityCollectionViewCellDelegate
{
    func ListNewsUtilityCollectionViewCell_DidSelectUtility(indexPath: IndexPath) {
        if(indexPath.section == 3 || indexPath.section == 7)
        {
            //print("co vao 36")
            var fromSource:String = READ_RELATIVE_ARTICLE
            var arrayArticle = arrayArticleRelated
            var appType:Model_EAppType = .appRelative
            if(indexPath.section == 7)
            {
                fromSource = READ_POPULAR_ARTICLE
                arrayArticle = arrayArticleTopRead
                appType = .appTopread
            }
            
            self.gotoContentDocument(document: arrayArticle[indexPath.row], indexPath: indexPath, fromSource: fromSource, appType: appType)
        }
     }
}

extension DetailVideoViewController : WKNavigationDelegate
{
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if(self.webView == webView)
        {
//            print("url: ", navigationAction.request.url?.absoluteString)
            
            requestUrlImage = String(format: "%@", navigationAction.request.url!.absoluteString)
            print("requestUrlImage: ", requestUrlImage)
            
            print("arrayListImage: ", arrayListImage)
            
            print("eeee: ", requestUrlImage)
            
            if(stopVideo == false)
            {
                if(requestUrlImage.hasSuffix(".jpeg") || requestUrlImage.hasSuffix(".jpg") ||
                    requestUrlImage.hasSuffix(".png") ||
                    requestUrlImage.hasSuffix(".gif") || requestUrlImage.hasSuffix(".JPEG"))
                {
                    //webView.dataDetectorTypes = UIDataDetectorTypes.all
                    if(arrayListImage.contains(requestUrlImage) == true)
                    {
                        var images = [SKPhoto]()
                        for item in arrayListImage {
                            let photo = SKPhoto.photoWithImageURL(item as! String)
                            photo.shouldCachePhotoURLImage = true
                            images.append(photo)
                        }
                        
                        let browser = SKPhotoBrowser(photos: images)
                        if arrayListImage.contains(requestUrlImage) {
                            let index = arrayListImage.index(of: requestUrlImage)
                            browser.initializePageIndex(index)
                        } else {
                            browser.initializePageIndex(0)
                        }
                        browser.delegate = self
                        present(browser, animated: true, completion: {})
                        webView.stopLoading()
                        decisionHandler(.cancel)
                        return
                    }
                    webView.stopLoading()
                }
            }
            
            if (navigationAction.navigationType == .linkActivated){
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
        else
        {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        print("abcde")
        if(self.websiteApp == webView)
        {
            if progressView.isHidden {
                // Make sure our animation is visible.
                progressView.isHidden = false
            }
            
            UIView.animate(withDuration: 0.33,
                           animations: {
                            self.progressView.alpha = 1.0
            })
        }
    }
    
    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        print("bbbbb")
        if(self.webView == webView)
        {
            if(stopVideo == false)
            {
                if(webView.isLoading == false)
                {
                    self.getRelateArticle()
                }
            }
        }
        else if(self.websiteApp == webView)
        {
            UIView.animate(withDuration: 0.33,
                           animations: {
                            self.progressView.alpha = 0.0
            },
                           completion: { isFinished in
                            // Update `isHidden` flag accordingly:
                            //  - set to `true` in case animation was completly finished.
                            //  - set to `false` in case animation was interrupted, e.g. due to starting of another animation.
                            self.progressView.isHidden = true
                            self.progressView.progress = 0
            })
        }
    }
}

extension DetailVideoViewController : ReloadInternetViewDelegate
{
    func actionReloadInternet() {
        if(AppDelegate.sharedInstance.reloadInternetView.isBack == true)
        {
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            if(self.lidArticleLoad.count > 0)
            {
                ///reload lai data (truong hop push, truong hop bai is_live = 1)
                
                AppDelegate.sharedInstance.reloadInternetView.isHidden = true
                APIRequest.sharedInstance.getArticleWidthIdPush(lid: self.lidArticleLoad, typeToDetail: self.typeToDetail,isPushLive: false, isDecrease: false) { [weak self] (result, error) in
                    
                    guard let strongSelf = self else { return }
                              
                    var isSuccess = false
                    if(result != nil)
                    {
                        
                        print("resultData: ", result as Any)
                        if let resultData = result as? Data
                        {
                            do
                           {
                               let data = try Model_ArticleDetailResponses(serializedData: resultData)
                               let sid = data.linfo.sid
                               let cid = data.linfo.cid

                               strongSelf.sID = Int(sid)
                                strongSelf.infoArticleProto = Model_Document()
                                strongSelf.infoArticleProto.type = .contentTypeArticles
                                strongSelf.infoArticleProto.art = data.linfo

                               strongSelf.nameCategory =  Global.sharedInstance.getTopic(sid: Int(sid), cid: Int(cid))!

                               strongSelf.nameWebsite = Global.sharedInstance.getNameWebsite(sid: Int(sid))!

                               strongSelf.createViewAndReloadData()
                               isSuccess = true
                           }
                           catch let error {
                               print(error.localizedDescription)
                           }
                        }
                    }
                    
                    if(isSuccess == false)
                    {
                        AppDelegate.sharedInstance.reloadInternetView.refreshData()
                        if(error != nil)
                        {
                            if(error!._code == 404)
                            {
                                AppDelegate.sharedInstance.reloadInternetView.Data404()
                            }
                        }
                        
                        AppDelegate.sharedInstance.reloadInternetView.isHidden = false
                        AppDelegate.sharedInstance.reloadInternetView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - 44 - Global.sharedInstance.marginBottomBarHeight() - 60, width: strongSelf.view.frame.width, height: 50)
                        strongSelf.view.addSubview(AppDelegate.sharedInstance.reloadInternetView)
                        AppDelegate.sharedInstance.reloadInternetView.delegate = self
                    }
                }
            }
        }
    }
}
extension DetailVideoViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let header = collectionArticle?.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 8)) as? PopVCCollectionReusableView else {return}
        var height:CGFloat = IS_IPAD ? 75 : 54
        if iOS_VERSION_LESS_THAN(version: "11.0") {
            height *= 3/2
        }
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
        if (bottomEdge >= scrollView.contentSize.height)
        {
            let spacing = bottomEdge - scrollView.contentSize.height
            if spacing >= height {
                header.lbTitle.text = "Thả ra để đóng tin"
                header.imgContent.image = UIImage(named: "ic_close_detail")
            } else {
                header.lbTitle.text = "Kéo lên tiếp để đóng tin"
                header.imgContent.image = UIImage(named: "ic_up_detail")
            }
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
       var height:CGFloat = IS_IPAD ? 75 : 54
       if iOS_VERSION_LESS_THAN(version: "11.0") {
           height *= 3/2
       }
       let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
       let spacing = bottomEdge - scrollView.contentSize.height
       if spacing >= height {
           self.navigationController?.popViewController(animated: true)
       }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        detectDataTracking()
    }
    func calcPlayVideo()
    {
        let strAutoVideo = UserDefault.sharedInstance.getSettingAutoPlayVideo()
        if strAutoVideo != "1" {return}
        for cell in collectionArticle!.visibleCells {
            if let cellVideo = cell as? ContentNativeCollectionViewCell {
                if cellVideo.isHasVideo == true {
                    self.startPlayVideo(btn: cellVideo.playBtn)
                    return
                }
            }
        }
    }
    func detectDataTracking()
    {
        for cellDetect in collectionArticle!.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader)
        {
            print("cot : ", cellDetect)
            if cellDetect is ViewOriginArticleCollectionViewCell
            {
                let data = self.infoArticleProto
                if(self.isSendTrackingReaded == false)
                {
                    var trackingData = Model_TrackingMsg.init()
                    trackingData.trackingType = .trackingRead
                    trackingData.docType = .contentTypeArticles
                    
                    trackingData.id = data.art.lid
                    
                    trackingData.tsStart = self.tsStart
                    trackingData.tsEnd = Date.currentTimeInMillis()
                    
                    DataTracking.sharedInstance.arrDataTracking.bulkTracking.append(trackingData)
                    self.isSendTrackingReaded = true
                }
            }
            
            for cellDetect in collectionArticle!.visibleCells
            {
                print("cot  : ", cellDetect)
                
                if((cellDetect as? ListNewsCollectionViewCell1) != nil ||
                (cellDetect as? ListNewsUtilityCollectionViewCell) != nil ||
                (cellDetect as? ListNewsSponserCollectionViewCell) != nil ||
                (cellDetect as? GoogleAdsBannerCollectionViewCell) != nil ||
                (cellDetect as? GoogleAdsUnifiedCollectionViewCell) != nil ||
                (cellDetect as? PollCollectionViewCell) != nil ||
                (cellDetect as? FootballUtilityCollectionViewCell) != nil ||
                (cellDetect as? CovidCollectionViewCell) != nil
                )
                {
                    var sectionCell = 0
                    var tagCell = 0
                    
                    if let cell = cellDetect as? ListNewsCollectionViewCell1
                    {
                        sectionCell = cell.indexPath!.section
                        tagCell = cell.tag
                    }
                    else if let cell = cellDetect as? ListNewsUtilityCollectionViewCell
                    {
                        sectionCell = cell.indexPath!.section
                        tagCell = cell.tag
                    }
                    else if let cell = cellDetect as? ListNewsSponserCollectionViewCell
                    {
                        sectionCell = cell.indexPath!.section
                        tagCell = cell.tag
                    }
                    else if let cell = cellDetect as? GoogleAdsBannerCollectionViewCell
                    {
                        sectionCell = cell.indexPath!.section
                        tagCell = cell.tag
                    }
                    else if let cell = cellDetect as? GoogleAdsUnifiedCollectionViewCell
                    {
                        sectionCell = cell.indexPath!.section
                        tagCell = cell.tag
                    }
                    else if let cell = cellDetect as? PollCollectionViewCell
                    {
                        sectionCell = cell.indexPath!.section
                        tagCell = cell.tag
                    }
                    else if let cell = cellDetect as? FootballUtilityCollectionViewCell
                    {
                        sectionCell = cell.indexPath!.section
                        tagCell = cell.tag
                    }
                    else if let cell = cellDetect as? CovidCollectionViewCell
                    {
                        sectionCell = cell.indexPath!.section
                        tagCell = cell.tag
                    }
                    
                    if(sectionCell == 3 || sectionCell == 6)
                    {
                        var arrayArticle = arrayArticleRelated
                        if(sectionCell == 6)
                        {
                            arrayArticle = arrayArticleTopRead
                        }
                        
                        if(arrayArticle.count > tagCell)
                        {
                            if let data = arrayArticle.object(at: tagCell) as? Model_Document
                            {
                                var trackingData = Model_TrackingMsg.init()
                                trackingData.trackingType = .trackingImpression
                                if(sectionCell == 3)
                                {
                                    trackingData.appType = .appRelative
                                }
                                else
                                {
                                    trackingData.appType = .appTopread
                                }
                                
                                trackingData.docType = data.type
                                trackingData.pos = UInt32(tagCell)
                                if(data.type == .contentTypeArticles)
                                {
                                    trackingData.id = data.art.lid
                                }
                                else if(data.type == .contentTypeVideos)
                                {
                                    trackingData.id = data.video.lid
                                }
                                else if(data.type == .contentTypeSponsors)
                                {
                                    trackingData.id = String(format: "%i", data.sponsor.id)
                                }
                                else if(data.type == .contentTypeUtilities)
                                {
                                    trackingData.id = String(format: "%i", data.utility.id)
                                }
                                else if(data.type == .contentTypeVote)
                                {
                                    trackingData.id = String(format: "%i", data.vote.id)
                                }
                                else if(data.type == .contentTypeGoogleAds)
                                {
                                    trackingData.id = data.gAds.id
                                }
                                else if(data.type == .contentTypePoll)
                                {
                                    trackingData.id = String(format: "%i", data.poll.id)
                                }
                                else if(data.type == .contentTypeCollection)
                                {
                                    trackingData.id = String(format: "%i", data.collection.id)
                                }
                                else if(data.type == .contentTypeNotice)
                                {
                                    trackingData.id = String(format: "%i", data.notice.id)
                                }
                                
                                trackingData.tsStart = Date.currentTimeInMillis()
                                DataTracking.sharedInstance.arrDataTracking.bulkTracking.append(trackingData)
                            }
                        }
                    }
                }
            }
        }
        
        DataTracking.sharedInstance.postDataTracking()
    }
}

extension DetailVideoViewController : ListNewsCollectionViewCell1Delegate
{
    func ListNewsCollectionViewCell1_InteractArticle(indexPath: IndexPath) {
        if(indexPath.section == 3 || indexPath.section == 7)
        {
            var arrayArticle = arrayArticleRelated
            if(indexPath.section == 7)
            {
                arrayArticle = arrayArticleTopRead
            }
            
            if let data = arrayArticle[indexPath.row] as? Model_Document
            {
                self.actionClosePopupSetting()
                var lid = ""
                if(data.type == .contentTypeArticles)
                {
                    lid = data.art.lid
                }
                else if(data.type == .contentTypeVideos)
                {
                    lid = data.video.lid
                }
                
                if(lid.count > 0)
                {
                    self.viewInteract.lid = lid
                    self.viewInteract.actionOpen()
                }
            }
        }
    }
    
    func ListNewsCollectionViewCell1_DidSelectArticle(indexPath: IndexPath) {
        if(indexPath.section == 3 || indexPath.section == 7)
        {
            //print("co vao 36")
            var fromSource:String = READ_RELATIVE_ARTICLE
            var arrayArticle = arrayArticleRelated
            var appType:Model_EAppType = .appRelative
            if(indexPath.section == 7)
            {
                fromSource = READ_POPULAR_ARTICLE
                arrayArticle = arrayArticleTopRead
                appType = .appTopread
            }
            
            self.gotoContentDocument(document: arrayArticle[indexPath.row], indexPath: indexPath, fromSource: fromSource, appType: appType)
        }
    }
}

extension DetailVideoViewController : ListNewsSponserCollectionViewCellDelegate
{
    func ListNewsSponserCollectionViewCell_DidSelectSponser(indexPath: IndexPath) {
        //print("co vao 36")
        var fromSource:String = READ_RELATIVE_ARTICLE
        var arrayArticle = arrayArticleRelated
        var appType:Model_EAppType = .appRelative
        if(indexPath.section == 7)
        {
            fromSource = READ_POPULAR_ARTICLE
            arrayArticle = arrayArticleTopRead
            appType = .appTopread
        }
        
        self.gotoContentDocument(document: arrayArticle[indexPath.row], indexPath: indexPath, fromSource: fromSource, appType: appType)
     }
}
extension DetailVideoViewController {
    fileprivate func setUpInputAction() {
        textInput.textViewDidChangeText = { [weak self] text in
            guard let `self` = self else {
                return
            }
            if self.textInput.textView.text != "" {
                self.currentText = self.textInput.textView.text
            }
        }
        textInput.commentClick = { [weak self] in
            guard let `self` = self else {return}
            let storyboard = Global.sharedInstance.getMainStoryboard()
            let pageCriticalViewController = storyboard.instantiateViewController(withIdentifier: "PageCriticalViewController") as! PageCriticalViewController
            pageCriticalViewController.infoArticleCommentProto = self.infoArticleProto
            self.navigationController?.pushViewController(pageCriticalViewController, animated: true)
        }
        textInput.saveClick = { [weak self] in
            guard let `self` = self else {
                return
            }
            if(self.isMarked == false)
            {
                self.isMarked = true
                self.textInput.btnSave.isSelected = self.isMarked
//                UserDefault.sharedInstance.setArrayDocumentMark(modelDocument: self.infoArticleProto, isMarked: self.isMarked)
                DBManagement.share.saveArticleMarkedToDB(model: self.infoArticleProto)
    
                UIApplication.shared.keyWindow!.makeToast(message: "Đã đánh dấu bài này!", duration: 1, position: HRToastPositionDefault as AnyObject)
    
            }
            else
            {
                self.isMarked = false
                self.textInput.btnSave.isSelected = self.isMarked
//                UserDefault.sharedInstance.setArrayDocumentMark(modelDocument: self.infoArticleProto, isMarked: self.isMarked)
                DBManagement.share.saveArticleMarkedToDB(model: self.infoArticleProto)
    
                UIApplication.shared.keyWindow!.makeToast(message: "Bỏ đánh dấu bài này!", duration: 1, position: HRToastPositionDefault as AnyObject)
            }
        }
        textInput.shareClick = { [weak self] in
            guard let `self` = self else {
                return
            }
            var strUrl = self.infoArticleProto.video.fplayurl
            if(Global.sharedInstance.getModeInReview() == true)
            {
                strUrl = self.infoArticleProto.video.url
            }
    
            if(strUrl.count > 0)
            {
                //print("strUrl: ", strUrl)
                if let myWebsite = NSURL(string: strUrl) {
                    let objectsToShare = [myWebsite] as [Any]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

                    //New Excluded Activities Code
                    activityVC.excludedActivityTypes =  [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]

                    activityVC.popoverPresentationController?.sourceView = self.textInput
                    self.present(activityVC, animated: true, completion: nil)
                }
            }
        }
        textInput.sendClick = { [weak self] in
            guard let `self` = self else {
                return
            }
            DispatchQueue.global(qos: .default).async {
                if(UserDefault.sharedInstance.getIdComment() == "")
                {
                    main {
                        self.textInput.textView.resignFirstResponder()
                        self.showViewLogin(text: TEXT_LOGINFB_COMMENT, textResult: TEXT_LOGINFB_COMMENT_RESULT)
                    }
                }
                else
                {
                    FirebaseAnalyticLog.sharedInstance.logEvent(eventName: INTERACTION, itemID: "", itemName: SEND_COMMENT, itemCategory: "")
                    main {
                        if self.textInput.textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                            UIApplication.shared.keyWindow!.makeToast(message: "Vui lòng nhập bình luận!")
                            return
                        }
                        
                        self.showNotificationComment(str: "Đang gửi bình luận!")
                        
                        let id_User = UserDefault.sharedInstance.getIdComment()
                        let lid:String = self.infoArticleProto.video.lid
                        let content: String = self.textInput.textView.text

                        let parameter = ["content": content,"id": id_User, "lid": lid] as Parameters
                        
                        APIRequest.sharedInstance.postCommentToServer(parameter: parameter) { [weak self] (result, error) in
                            guard let strongSelf = self else { return }
                            main {
                                strongSelf.currentText = ""
                                strongSelf.textInput.textView.text = ""
                                strongSelf.textInput.textView.resignFirstResponder()
                                if(error != nil)
                                {
                                    strongSelf.showNotificationComment(str: "Có lỗi xảy ra!")
                                }
                                else
                                {
                                    if let flagResult = result as? String
                                    {
                                        if(flagResult == "false")
                                        {
                                            strongSelf.showNotificationComment(str: "Bình luận đang đợi kiểm duyệt!")
                                        }
                                        else
                                        {
                                            strongSelf.showNotificationComment(str: "Bình luận thành công!")
                                        }
                                    }
        
                                    //luu tin da binh luan
//                                    UserDefault.sharedInstance.setArrayDocumentComment(modelDocument: strongSelf.infoArticleProto)
                                    DBManagement.share.saveArticleCommentToDB(model: strongSelf.infoArticleProto)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

//Video Situation
extension DetailVideoViewController: VideoCollectionViewDelegate, DetailCollectionViewCellDelegate {
    
    func reloadVideoCollectionViewCellSituasions(at indexPath: IndexPath, with indexVideo: Int) {
        collectionArticle?.collectionViewLayout.invalidateLayout()
    }
    
    func DetailCollectionViewCell_DidSelectArticle(indexPath: IndexPath) {
        print(indexPath)
    }
    
}
