//
//  ListVideoShowViewController.swift
//  Tin
//
//  Created by vietnb on 6/17/19.
//  Copyright © 2019 vietnb. All rights reserved.
//

import AVFoundation
import UIKit
import GoogleInteractiveMediaAds
//import FBSDKShareKit
import MessageUI
import GoogleMobileAds

///them like video
import FBSDKCoreKit
//import FacebookLogin
import Alamofire

class ListVideoShowViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(section == 0)
        {
            return self.arrayDicVideo.count
        }
        else if(section == 1)
        {
            return 1
        }
        
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print(indexPath.row)
        if let _cell = cell as? ListVideoShowCollectionViewCell
        {
            if(_cell.btnPlayVideo.tag == self.tagCellPlay)
            {
                UIView.animate(withDuration: 0.5, animations: {
                    self.playerView.alpha = 0
                    self.playerView.pause()

                    _cell.coverVideo.alpha = 1
                    _cell.modeNight()
                    _cell.imgPlayVideo.alpha = 1
                }) { (result) in

                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(indexPath.section == 0)
        {
            if let dictData = self.arrayDicVideo.object(at: indexPath.row) as? Model_Document
            {
                //load more
                let a = indexPath.row as Int
                if(a == self.arrayDicVideo.count - 1)
                {
                    if(self.loadMore == true)
                    {
                        self.loadMore = false
                        let lid = dictData.video.lid

                        FirebaseAnalyticLog.sharedInstance.logEvent(eventName: APP_LOAD_MORE, itemID: "", itemName: "", itemCategory: "")

                        APIRequest.sharedInstance.getListVideoShow(lid: lid, isPush: false, realsize: self.arrayDicVideo.count, situation: self.situation) { [weak self] (result, error) in
                            guard let strongSelf = self else { return }
                            strongSelf.loadMoreSubCategoryVideoDataFromServer(error: error, dataResponse: result, lid: lid)
                        }
                    }
                }
                
                if(dictData.type == .contentTypeVideos)
                {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListVideoShowCollectionViewCell", for: indexPath) as! ListVideoShowCollectionViewCell
                    cell.setDataDocumentToCell(data: dictData, indexPath: indexPath)
                    cell.delegate = self
                    return cell
                }
                else if dictData.type == .contentTypeCollection {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FootballUtilityCollectionViewCell", for: indexPath) as! FootballUtilityCollectionViewCell
                    cell.isDefaultNightMode = true
                    cell.setDataToCell(model: dictData.collection, indexPath: indexPath)
                    cell.delegate = self
                    return cell
                }
                else if(dictData.type == .contentTypeUtilities || dictData.type == .contentTypeVote)
                {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IdentifierCellUtility, for: indexPath) as! ListNewsUtilityCollectionViewCell
                    cell.setDataProtoToCell(data: dictData, indexPath: indexPath)
                    cell.lblTitle.textColor = .white
                    cell.viewLineCell.isHidden = true
                    cell.delegate = self
                    return cell
                }
                else if dictData.type == .contentTypeNotice {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CovidCollectionViewCell", for: indexPath) as! CovidCollectionViewCell
                    
                    cell.setDataToCell(model: dictData.notice, indexPath: indexPath)
                    cell.addTapGestureRecognizer { [weak self] in
                        guard let `self` = self else { return }
                        
                        DataTracking.sharedInstance.detectDataTrackingClick(dataDetect: dictData, pos: UInt32(indexPath.row), appLocat: "", appType: .appVideos)
                        
                        switch dictData.notice.type.rawValue {
                        case 0: /// nothing
                            break
                        case 1: /// nhảy vào event
                            let storyboard = Global.sharedInstance.getMainStoryboard()
                            let listEventViewController = storyboard.instantiateViewController(withIdentifier: "ListEventViewController") as! ListEventViewController
                            let dictEvent = NSDictionary.init(object: dictData.notice.jumpID, forKey: "idevent" as NSCopying)
                            listEventViewController.dicEvent = dictEvent
                            listEventViewController.typeFrom = XKTypeEventFrom.XKFromHomeEvent
                            self.navigationController?.pushViewController(viewController: listEventViewController, animated: true, completion: nil)
                        case 2: /// nhảy vào topic
                            let storyboard = Global.sharedInstance.getMainStoryboard()
                            let listEventViewController = storyboard.instantiateViewController(withIdentifier: "ListEventViewController") as! ListEventViewController
                            listEventViewController.typeFrom = XKTypeEventFrom.XKFromTopicFollow
                            listEventViewController.topicID = dictData.notice.jumpID
                            self.navigationController?.pushViewController(viewController: listEventViewController, animated: true, completion: nil)
                            break
                        case 3: /// nhảy ra webview in app với jump_id là url link
                            let storyboard = Global.sharedInstance.getMainStoryboard()
                            let webKitViewController = storyboard.instantiateViewController(withIdentifier: "WebKitViewController") as! WebKitViewController
                            webKitViewController.url = dictData.notice.jumpID
                            webKitViewController.strTitle = dictData.notice.title
                            
                            self.navigationController?.pushViewController(webKitViewController, animated: true)
                        case 4: /// nhảy vào màn hình setting -> enable push
                            let storyboard = Global.sharedInstance.getMainStoryboard()
                            let vc = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
                            vc.isSetting = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        default:
                            break
                        }
                    }
                    return cell
                }
                else if(dictData.type == .contentTypeSponsors)
                {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IdentifierCellSponser, for: indexPath) as! ListNewsSponserCollectionViewCell
                    cell.delegate = self
                    cell.setDataToCell(data: dictData, indexPath: indexPath)
                    return cell
                }
                else if(dictData.type == .contentTypeGoogleAds)
                {
                    if self.arrayIndexPathAd.contains(indexPath) == false {
                        self.arrayIndexPathAd.append(indexPath)
                    }
                    if let adsGoogleObject = self.getAdsOfGoogle(keyDetect:String(format: "row_%i", indexPath.row))
                    {
                        if(adsGoogleObject.typeAdsGoogle == XKTypeAdsGoogle.XKBannerView || adsGoogleObject.typeAdsGoogle == XKTypeAdsGoogle.XKBannerViewGAD)
                        {
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IdentifierCellGoogleAdsBanner, for: indexPath) as! GoogleAdsBannerCollectionViewCell
                            cell.setDataToCell(adsGoogle:adsGoogleObject, indexPath: indexPath)
                            cell.backgroundColor = Constant.Color.lineColorDarkMode
                            cell.delegate = self
                            return cell
                        }
                        else if(adsGoogleObject.typeAdsGoogle == XKTypeAdsGoogle.XKUnifiedNative)
                        {
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IdentifierCellGoogleAdsUnified, for: indexPath) as! GoogleAdsUnifiedCollectionViewCell
                            cell.delegate = self
                            cell.setDataToCell(adsGoogle: adsGoogleObject, viewController: self, indexPath: indexPath, modeNight: true)
                            cell.setColorAdsVideoShow()
                            return cell
                        }
                    }
                }
            }
            
            //tin video
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListVideoShowCollectionViewCell", for: indexPath) as! ListVideoShowCollectionViewCell
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingMoreCollectionViewCell", for: indexPath) as! LoadingMoreCollectionViewCell
        cell.startAnimation()
        return cell

    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let _ = collectionView.cellForItem(at: indexPath) as? ListVideoShowCollectionViewCell {
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn, animations: {
                self.collectionVideo.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            }) { (result) in
                self.calcPlayVideo(isAutoPlay: true)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(indexPath.section == 0)
        {
            if let dictData = self.arrayDicVideo.object(at: indexPath.row) as? Model_Document
            {
                if(dictData.type == .contentTypeVideos)
                {
                    let heightVideo = ((self.view.frame.size.width - 32)*9)/16
                    var heightText = self.getHeightText(title: dictData.video.title, font: TITLE_FONT_ARTICLE)
                    if(heightText > (IS_IPHONE ? 78 : 100))
                    {
                        heightText = IS_IPHONE ? 78 : 100
                    }
                    let heightCell = heightVideo + heightText + 16 + 31.5 + (IS_IPHONE ? 44 : 60)
                    return CGSize(width: self.view.frame.width, height: heightCell)
                }
                else if dictData.type == .contentTypeCollection {
                    return CGSize(width: SCREEN_WIDTH, height: IS_IPHONE ? 192 : 206)
                }
                else if dictData.type == .contentTypeNotice {
                    return CGSize.init(width: SCREEN_WIDTH, height: IS_IPHONE ? 110:130)
                }
                else if(dictData.type == .contentTypeSponsors)
                {
                    if(SCREEN_WIDTH <= 320 && SCREEN_HEIGHT <= 568)
                    {
                        return CGSize.init(width: checkLandScapel, height: ((SCREEN_WIDTH - 44)/3)*3/4 + 38)
                    }
                    
                    return CGSize.init(width: checkLandScapel, height: ((SCREEN_WIDTH - 44)/3)*3/4 + 29)
                }
                else if(dictData.type == .contentTypeGoogleAds)
                {
                    if let adsGoogleObject = self.getAdsOfGoogle(keyDetect:String(format: "row_%i", indexPath.row))
                    {
                        if(adsGoogleObject.typeAdsGoogle == XKTypeAdsGoogle.XKBannerView || adsGoogleObject.typeAdsGoogle == XKTypeAdsGoogle.XKBannerViewGAD)
                        {
                            let heightAds = Int(adsGoogleObject.heightBannerView)
                            return CGSize(width: checkLandScapel, height: CGFloat(heightAds + 32))
                        }
                        else if(adsGoogleObject.typeAdsGoogle == XKTypeAdsGoogle.XKUnifiedNative)
                        {
                            return CGSize.init(width: checkLandScapel, height: ((checkLandScapel - 30)*9)/16 + 141)
                        }
                    }
                    return CGSize(width: checkLandScapel, height: 0)
                }
                else if(dictData.type == .contentTypeUtilities || dictData.type == .contentTypeVote)
                {
                    var title = ""
                    if(dictData.type == .contentTypeUtilities)
                    {
                        title = dictData.utility.title
                    }
                    else if(dictData.type == .contentTypeVote)
                    {
                        title = dictData.vote.title
                    }
                    
                    
                    let heightText = title.height(constraintedWidth: SCREEN_WIDTH - 32, font: TITLE_FONT_ARTICLE)
                    let heightVideo = ((SCREEN_WIDTH - 32)*392)/1320
                    let heightCell = 8 + 14 + heightVideo + heightText + (IS_IPHONE ? 38 : 58)
                    return CGSize(width: SCREEN_WIDTH, height: heightCell)
                }
            }
            
            if(IS_IPAD)
            {
                var heightCell = ((self.view.frame.size.width - 30)*9)/16
                heightCell = heightCell + 165 + 15
                return CGSize(width: self.view.frame.width, height: heightCell)
            }
            var heightCell = ((self.view.frame.size.width - 30)*9)/16
            heightCell = heightCell + 115 + 15
            return CGSize(width: self.view.frame.width, height: heightCell)
        
        }
        else if(indexPath.section == 1)
        {
            if(self.disableLoadingMore == true)
            {
                return CGSize(width: checkLandScapel, height: 0)
            }
            return CGSize(width: checkLandScapel, height: 35)
        }
        
        return CGSize(width: checkLandScapel, height: 0)
    }
    
    public func getHeightText(title: String, font: UIFont)->CGFloat {
        //print("title: ", title)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        paragraphStyle.alignment = .left
        
        let attributedString = NSMutableAttributedString(string: title as String, attributes:
            [NSAttributedString.Key.paragraphStyle:paragraphStyle,
             NSAttributedString.Key.font:font]
        )
        
        //print("aa:", self.view.frame.width)
        
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let sizeOfString = attributedString.boundingRect(with: CGSize(width: checkLandScapel - 16*2, height: 10000), options: options, context: nil)
        
        return CGFloat(sizeOfString.height + 0.5)
    }
    
    @IBOutlet weak var imgLoadError: UIImageView!
    var tagCellPlay:Int = -1
//    var textView = rskg
//    let addTextCriticalView: AddTextCritical = {
//        let container: AddTextCritical = .fromNib()
//        container.frame = .init(x: 0, y: 0, width: SCREEN_WIDTH, height: IS_IPHONE ? 141 : 200)
//        if(IS_IPAD)
//        {
//            textView.frame = CGRect(x: 6, y: 65, width: self.view.frame.width - 12, height: 75)
//        }
//        else
//        {
//            if(checkLandScapeHeight > 480)
//            {
//                textView.frame = CGRect(x: 6, y: 50, width: self.view.frame.width - 12, height: 100)
//            }
//            else
//            {
//                textView.frame = CGRect(x: 6, y: 44, width: self.view.frame.width - 12, height: 80)
//            }
//        }
//        return container
//    }()
//    override var inputAccessoryView: UIView? {
//        get {
//            return addTextCriticalView
//        }
//    }
    var isLoadedRefresh:Bool = false
    
    var showErrorVideo:Bool = true
    
    var disableLoadingMore:Bool = true
    
    weak var viewParentController:UIViewController?
    var indexLoadAds:Int = 0
    var isLoadedMore:Bool = false
    
    var queue: [BMPlayerResourceDefinition] = []
    var playerView = BMPlayer()
    
    var arrayCatOfVideo = NSMutableArray()
    var arrayDicVideo = NSMutableArray()
    var indexPage: NSInteger = 0
    var detectAdsOfGoogle = NSMutableDictionary()
    //them
    var subcid:Int = 0
    var child_id:Int = 0
    //them lid
    var documentDefault:Model_Document?
    
    @IBOutlet weak var collectionVideo:UICollectionView!
    var refreshControl = UIRefreshControl()
    
    var isFirstLoadScreen:Bool = false
    
    //var wmPlayer
    var checkLandScapel:CGFloat = 0
    var checkLandScapelHeight:CGFloat = 0
    var isSmallScreen:Bool = false

    var indexSmallVideo:NSInteger = 0
    var rowSelected:NSInteger = 0
    var loadMore:Bool = false
    var activeView = UIActivityIndicatorView()
    var arrAdsGoogleWillRequest = NSMutableArray()
    var viewLoading = UIView()
            
    var isPlayedVideo:Bool = false
    var labelNotifiSaveArticle = UILabel()
    let adsGoogleDFP = AdsGoogleDFP()
    var currentCellOfCollectionVideo = ListVideoShowCollectionViewCell()
    @IBOutlet weak var viewSetting: UIView!
        
    var currentIndexPath = IndexPath()
    
    ///
    @IBOutlet weak var imgBack:UIImageView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var viewStatus:UIView!
    @IBOutlet weak var viewTitle:UIView!
    
    var viewInteract: ViewInteract = .fromNib()
    
    ///them like video
    let viewLogin: ViewPopupLogin = .fromNib()
    let buttonShowKeyboard = UIButton()
    var statePlayer = BMPlayerState.notSetURL
    var playerIsPlaying = false
    
    @objc func applicationDidEnterBackground()
    {
        self.playerView.pause()
    }
    @objc func applicationBecomeActiveListVideoShow()
    {
        if let _ = UIApplication.getTopViewController() as? ListVideoShowViewController {
            if(Global.sharedInstance.isVideoShowScreen == true && self.playerView.alpha == 1)
            {
                if !(statePlayer == .playedToTheEnd) && playerIsPlaying {
                    playerView.play()
                }
            }
        }
    }
    
    @objc func monitorNetworkChangeStatus(notification: NSNotification)
    {
        if let isConnected = notification.userInfo?["isConnected"] as? Bool {
            // do something with your image
            //print("isConnected: ", isConnected)
            if(self.arrayDicVideo.count == 0 && isConnected == true)
            {
                self.refreshData(control: nil)
            }
        }
    }
    
    @objc func actionTap(notification: NSNotification)
    {
        if let index = notification.userInfo?["tapIndex"] as? Int {
            // do something with your image
            if(index == 1)
            {
                collectionVideo.setContentOffset(.zero, animated: true)
            }
        }
    }
    
    deinit {
        print("goi ham deinit listviewviewcontroller")
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var isHiddenStatusBar:Bool = false
    override var prefersStatusBarHidden: Bool {
        print("isHidden: ", isHiddenStatusBar)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @IBAction func actionBack()
    {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func reloadAvatar() {
        for cell in collectionVideo.visibleCells {
            if let cellVideo = cell as? ListVideoShowCollectionViewCell {
                cellVideo.imgLike.sd_setImage(with: URL(string: UserDefault.sharedInstance.getAvatarComment().reduceStringURLImage()), placeholderImage: UIImage.init(named: "avatar"))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let document = self.documentDefault
        {
            DBManagement.share.saveArticleReadedToDB(model: document)
        }
        
        self.lblTitle.text = ""
                
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(actionTap(notification:)), name: Notification.Name("actionTapDoubleBottom"), object: nil)
        nc.addObserver(self, selector: #selector(reloadAvatar), name: NSNotification.Name("didLoginFacebook"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(monitorNetworkChangeStatus(notification:)), name: Notification.Name("monitorNetworkChangeStatus"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationBecomeActiveListVideoShow), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeBackGroundColor), name: Notification.Name("changeBackGroundColor"), object: nil)
                        
        // Do any additional setup after loading the view.
                
        labelNotifiSaveArticle.center = self.view.center
        labelNotifiSaveArticle.backgroundColor = .black
        labelNotifiSaveArticle.textColor = .white
        self.view.addSubview(labelNotifiSaveArticle)
        labelNotifiSaveArticle.textAlignment = .center
        labelNotifiSaveArticle.font = UIFont.init(name: FONT_UITEXT_SEMIBOLD, size: IS_IPHONE ? 14 : 20)
        
        var heightBottom:CGFloat = 52
        if(IS_IPAD)
        {
            heightBottom = 66
        }
        self.collectionVideo.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: heightBottom, right: 0)
        
        if(child_id == 0)
        {
            self.collectionVideo.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: heightBottom, right: 0)
        }
                
        self.activeView = UIActivityIndicatorView.init(style: .gray)
        self.activeView.center = self.view.center
        self.activeView.isHidden = true
        self.view.addSubview(self.activeView)
        
        checkLandScapel = UIScreen.main.bounds.size.width
        checkLandScapelHeight = UIScreen.main.bounds.size.height
        
        createButtonScrollUp()
        self.collectionVideo.register(UINib.init(nibName: "ListVideoShowCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ListVideoShowCollectionViewCell")
        self.collectionVideo.register(UINib.init(nibName: "LoadingMoreCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LoadingMoreCollectionViewCell")
        collectionVideo.register(UINib.init(nibName: IdentifierCellUtility, bundle: nil), forCellWithReuseIdentifier: IdentifierCellUtility)
        
        collectionVideo.register(UINib.init(nibName: "FootballUtilityCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FootballUtilityCollectionViewCell")
        
        collectionVideo.register(UINib.init(nibName: "CovidCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CovidCollectionViewCell")
        
        collectionVideo.register(UINib.init(nibName: IdentifierCellSponser, bundle: nil), forCellWithReuseIdentifier: IdentifierCellSponser)
        
        collectionVideo.register(UINib.init(nibName: IdentifierCellGoogleAdsBanner, bundle: nil), forCellWithReuseIdentifier: IdentifierCellGoogleAdsBanner)
        
        collectionVideo.register(UINib.init(nibName: IdentifierCellGoogleAdsUnified, bundle: nil), forCellWithReuseIdentifier: IdentifierCellGoogleAdsUnified)
        
        self.collectionVideo.delegate = self
        self.collectionVideo.dataSource = self
        
//        self.refreshControl.tintColor = UIColor(rgb: 0xebebeb)
//        self.refreshControl.addTarget(self, action: #selector(refreshData(control:)), for: .valueChanged)
//        if #available(iOS 10.0, *) {
//            self.collectionVideo.refreshControl = refreshControl
//        } else {
//            self.collectionVideo.addSubview(refreshControl)
//        }
        self.adsGoogleDFP.delegate = self
        self.refreshData(control: nil)
        
        self.changeBackGroundColor()
        
        ///them like video
        self.buttonShowKeyboard.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        self.buttonShowKeyboard.addTarget(self, action: #selector(clickHiddenKeyboard), for: .touchUpInside)
        self.view.addSubview(buttonShowKeyboard)
        buttonShowKeyboard.isHidden = true
        viewLogin.delegate = self
        viewLogin.viewController = self
        
        ///them interact
        self.viewInteract.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        self.viewInteract.delegate = self
        let slideMenuController = UIApplication.shared.keyWindow!.rootViewController as! UINavigationController
        slideMenuController.view.addSubview(self.viewInteract)
        
        let viewbottomSafeArea = UIView()
        viewbottomSafeArea.backgroundColor = .black
        self.view.addSubview(viewbottomSafeArea)
        viewbottomSafeArea.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(bottomLayoutGuide.snp.top)
        }
    }
    
    var btnUp: UIButton = UIButton()
    var bottomConstraint: NSLayoutConstraint?
    private func createButtonScrollUp() {
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.itemSize = CGSize(width: 10, height: 10)
        flowLayout.scrollDirection = .vertical
        
        self.collectionVideo.setCollectionViewLayout(flowLayout, animated: false)
        self.view.insertSubview(self.btnUp, at: 1000)
        btnUp.setImage(UIImage(named: "icon_muiten_up"), for: .normal)
        self.btnUp.translatesAutoresizingMaskIntoConstraints = false
        btnUp.addTarget(self, action: #selector(actionUp), for: .touchUpInside)
        NSLayoutConstraint.activate([
            btnUp.rightAnchor.constraint(equalTo: view.rightAnchor, constant: IS_IPHONE ? -16 : -30),
            btnUp.widthAnchor.constraint(equalToConstant: IS_IPHONE ? 30 : 50),
            btnUp.heightAnchor.constraint(equalToConstant: IS_IPHONE ? 30 : 50)
        ])
        bottomConstraint = btnUp.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: IS_IPHONE ? 64 : 84)
        bottomConstraint?.isActive = true
    }
    
    @objc func actionUp() {
        collectionVideo.setContentOffset(.zero, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            if let _ = self.collectionVideo.cellForItem(at: IndexPath(item: 0, section: 0)) as? ListVideoShowCollectionViewCell {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                    self.collectionVideo.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredVertically, animated: false)
                }) { (result) in
                    self.calcPlayVideo(isAutoPlay: false)
                }
            }
        }
    }
    
    func preloadData()
    {
        if(self.arrayDicVideo.count == 0)
        {
            self.refreshData(control: nil)
        }
    }
    
    var isPush:Bool = false
    var arrayIndexPathAd = [IndexPath]()
    var situation:String = ""
    
    @objc func refreshData(control:UIControl?)
    {
        self.arrayDicVideo.removeAllObjects()
        if let document = self.documentDefault
        {
            //truong hop quick action: lid = hightlight
            //truong hop vao tu push: lid = news...
            if document.video.title.count > 0
            {
                self.arrayDicVideo.add(document)
                self.collectionVideo?.reloadData()
                self.collectionVideo?.performBatchUpdates(nil, completion: {
                    (result) in
                    // ready

                    self.playVideoWhenAppear()
                })
            }
        }
        
        var lid = ""
        if let document = self.documentDefault
        {
            lid = document.video.lid
        }
        
        self.getDataVideo(lid: lid)
    }
    
    func getDataVideo(lid:String)
    {
        APIRequest.sharedInstance.getListVideoShow(lid: lid, isPush: self.isPush, realsize: 0, situation: self.situation) { [weak self] (result, error) in
            guard let strongSelf = self else { return }
            
            strongSelf.arrayIndexPathAd.removeAll()
            strongSelf.adsGoogleDFP.arrAds.removeAllObjects()
            strongSelf.detectAdsOfGoogle.removeAllObjects()
            
            if let dataResult = result as? Data
            {
                do {
                    let arrayResult = NSMutableArray.init()
                    let model_ListingResponse = try Model_ListingResponses(serializedData: dataResult)
                    
                    //test banner ads
//                    #if DEBUG
//                        var data = Model_Document.init()
//                        data.type = .contentTypeGoogleAds
//                        data.gAds.id = "/214571812/TM24/TM24-App/TM-App-iOS-VideoPage"
//
//                        if model_ListingResponse.linfos.count > 2 {
//                            model_ListingResponse.linfos.insert(data, at: 2)
//                        }
//                    #endif
                    
                    for i in 0..<model_ListingResponse.linfos.count
                    {
                        let data:Model_Document = model_ListingResponse.linfos[i]
                        if(data.type == .contentTypeGoogleAds)
                        {
                            strongSelf.arrAdsGoogleWillRequest.add(data.gAds)
                        }
                        if(data.type == .contentTypeVideos || data.type == .contentTypeGoogleAds || data.type == .contentTypeUtilities)
                        {
                            arrayResult.add(data)
                        }
                    }
                    strongSelf.requestGoogleDFP()
                    if(arrayResult.count>0)
                    {
                        strongSelf.loadMore = true
                        
                        let resultsSize = strongSelf.arrayDicVideo.count as NSInteger
                        let arrayWithInPath = NSMutableArray.init()
                        strongSelf.arrayDicVideo.addObjects(from: arrayResult as! [Any])
                        for i in resultsSize..<strongSelf.arrayDicVideo.count
                        {
                            arrayWithInPath.add(IndexPath.init(row: i, section: 0))
                        }
                        strongSelf.collectionVideo?.performBatchUpdates({
                            strongSelf.collectionVideo.insertItems(at: arrayWithInPath as! [IndexPath])
                        }, completion: { (result) in
                            
                            if let document = strongSelf.documentDefault
                            {
                                //truong hop quick action: lid = hightlight
                                //truong hop vao tu push: lid = news...
                                if document.video.title.count == 0
                                {
                                    strongSelf.playVideoWhenAppear()
                                }
                            }
                        })
                    }
                } catch {
//                    strongSelf.collectionVideo.reloadData()
                }
            } else {
//                strongSelf.collectionVideo.reloadData()
            }
            
            if(strongSelf.arrayDicVideo.count == 0)
            {
                DispatchQueue.main.async {
                    UIApplication.shared.keyWindow!.makeToast(message: "Không có dữ liệu!")
                }
            }
        }
    }
    
    func loadMoreSubCategoryVideoDataFromServer(error: Error?, dataResponse: Any?, lid: String)
    {
        self.indexLoadAds = 0
        //self.requestGoogleDFP()
        self.loadMore = true
        let arrayResult = NSMutableArray.init()
                
        if let dataResult = dataResponse as? Data
        {
            do {
                let model_ListingResponse = try Model_ListingResponses(serializedData: dataResult)
                
                for i in 0..<model_ListingResponse.linfos.count
                {
                    
                    let data:Model_Document = model_ListingResponse.linfos[i]
                    
                    if(data.type == .contentTypeGoogleAds)
                    {
                        self.arrAdsGoogleWillRequest.add(data.gAds)
                    }
                    if(data.type == .contentTypeVideos)
                    {
                        arrayResult.add(data)
                    }
                }
                self.requestGoogleDFP()
                if(arrayResult.count>0)
                {
                    let resultsSize = self.arrayDicVideo.count as NSInteger
                    
                    let data = NSMutableArray.init()
                    data.addObjects(from: arrayResult as! [Any])
                    
                    self.arrayDicVideo.addObjects(from: data as! [Any])
                    let arrayWithInPath = NSMutableArray.init()
                    for i in resultsSize..<self.arrayDicVideo.count
                    {
                        arrayWithInPath.add(IndexPath.init(row: i, section: 0))
                    }
                    
                    if(data.count > 0)
                    {
                        if(data.count >= 10)
                        {
                            self.disableLoadingMore = false
                        }
                        
                        DispatchQueue.main.async {
                            self.collectionVideo.performBatchUpdates( {
                                UIView.performWithoutAnimation {
                                    self.collectionVideo.insertItems(at: arrayWithInPath as! [IndexPath])
                                }
                            }, completion: nil)
                        }
                    }
                    else
                    {
                        if(error == nil)
                        {
                            self.disableLoadingMore = true
                        }
                        
                        self.collectionVideo.performBatchUpdates({
                            let indexSet = IndexSet(integer: 1)
                            self.collectionVideo.reloadSections(indexSet)
                        }, completion: nil)
                    }
                }
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
        
        if(error != nil && arrayResult.count == 0)
        {
            UIApplication.shared.keyWindow!.makeToast(message: "Kiểm tra lại kết nối mạng!")
        }
    }
    
    func requestGoogleDFP()
    {
        if(self.arrAdsGoogleWillRequest.count > 0)
        {
            if let gAd = self.arrAdsGoogleWillRequest[0] as? Model_GoogleAdsMsg
            {
                self.arrAdsGoogleWillRequest.removeObject(at: 0)
                
                self.adsGoogleDFP.loadGoogleDFP(viewController: self, gAd: gAd)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerView.pause()
        if playerView.isFullScreen {
            playerView.fullScreenButtonPressed()
        } else {
            self.releaseWMPlayer()
        }
    }
    
    func releaseWMPlayer()
    {
//        self.playerView.stop()
        self.playerView.alpha = 0
        self.resetCurrentCell()
    }
    
    @objc func changeBackGroundColor()
    {
        self.view.mixedBackgroundColor = .init(normal: Constant.Color.bgDarkModeColor, night: Constant.Color.bgDarkModeColor)
        self.imgBack.image = UIImage.init(named: "icon_back_white")
        self.lblTitle.textColor = .white
        self.viewStatus.mixedBackgroundColor = .init(normal: Constant.Color.bgStatusBarDark, night: Constant.Color.bgStatusBarDark)
        self.viewTitle.backgroundColor = .black
        
        self.collectionVideo.backgroundColor = .black
        self.collectionVideo.reloadData()
    }

    func checkVolume()
    {
        
    }
    
    func pauseVideo()
    {
        playerView.pause()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Global.sharedInstance.isVideoShowScreen = false
        playerView.pause()
    }
    
    func playVideoWhenAppear()
    {
        let strAutoVideo = UserDefault.sharedInstance.getSettingAutoPlayVideo()
        
        if(currentCellOfCollectionVideo.btnPlayVideo != nil)
        {
            currentCellOfCollectionVideo.modeBright()
            if(strAutoVideo == "1")
            {
                self.ListVideoShowCollectionViewCell_DidPlayVideo(btn: currentCellOfCollectionVideo.btnPlayVideo, method: AUTOMATIC)
            }
            else
            {
                self.ListVideoShowCollectionViewCell_EnableVideoActive(btn: currentCellOfCollectionVideo.btnPlayVideo, method: AUTOMATIC)
            }
        }
        else
        {
            calcPlayVideo(isAutoPlay: false)
        }
    }
    
    func viewDidApprear(activePage:Int)
    {
        preloadData()
        
        self.playVideoWhenAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Global.sharedInstance.isVideoShowScreen = true
        
        if(isLoadedRefresh == false)
        {
            isLoadedRefresh = true
        }
        else
        {
            self.playVideoWhenAppear()
        }
        for cell in collectionVideo.visibleCells {
            if let cel = cell as? ListVideoShowCollectionViewCell {
                cel.updateAvatar()
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        changeVideoPlayerFrame(orientation: UIDevice.current.orientation)
    }
    
    fileprivate func changeVideoPlayerFrame(orientation: UIDeviceOrientation) {
        
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            orientationLandscape()
        case .portrait, .portraitUpsideDown:
            orientationPortrait()
        default: break
        }
        self.view.layoutIfNeeded()
    }
    
    fileprivate func orientationLandscape() {
        if(IS_IPHONE)
        {
            playerView.transform = CGAffineTransform.init(rotationAngle: -CGFloat(Double.pi/2))
            playerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
            
//            playerView.playerLayer!.frame = CGRect(x: 0, y: 0, width: SCREEN_HEIGHT, height: SCREEN_WIDTH)
        }
        else
        {
            playerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT )

//            playerView.playerLayer!.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        }
        UIApplication.shared.keyWindow?.addSubview(playerView)
    }
    
    fileprivate func orientationPortrait() {
        playerView.transform = CGAffineTransform.init(rotationAngle: CGFloat(0))
        playerView.frame = CGRect(x:0, y:0, width: currentCellOfCollectionVideo.coverVideo.frame.size.width, height: currentCellOfCollectionVideo.coverVideo.frame.size.height)
        currentCellOfCollectionVideo.viewOfVideo.addSubview(playerView)
    }
    let viewContainerLoginFB = UIView(frame: UIScreen.main.bounds)
    ///them like video
    func showViewLogin(text: String)
    {
        self.viewContainerLoginFB.backgroundColor = .init(white: 0, alpha: 0.6)
        self.viewContainerLoginFB.isUserInteractionEnabled = true
        self.viewContainerLoginFB.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickHiddenKeyboard)))
        viewLogin.textLogin.text = text
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
        UIView.animate(withDuration: 0.3, animations: {
        }) { (result) in
            self.viewContainerLoginFB.removeFromSuperview()
        }
    }
}

extension ListVideoShowViewController : UICollectionViewDelegateFlowLayout
{
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets (top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension ListVideoShowViewController : ListVideoShowCollectionViewCellDelegate {
    func ListVideoShowCollectionViewCell_DidInteractVideo(btn: UIButton) {
        if let data = self.arrayDicVideo[btn.tag] as? Model_Document
        {
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
    
    func ListVideoShowCollectionViewCell_LikeVideo(cell: ListVideoShowCollectionViewCell) {
        if(UserDefault.sharedInstance.getIdComment() == "")
        {
            self.showViewLogin(text: TEXT_LOGINFB_COMMENT)
        }
        else
        {
            let arrayArticleLiked = UserDefault.sharedInstance.getArrayArticleLiked()
            
            if let dictData = self.arrayDicVideo.object(at: cell.tag) as? Model_Document
            {
                if(dictData.type == .contentTypeVideos)
                {
                    cell.imgLike.sd_setImage(with: URL(string: UserDefault.sharedInstance.getAvatarComment().reduceStringURLImage()), placeholderImage: UIImage.init(named: "avatar"))
//                    let lid = dictData.video.lid
//                    if(arrayArticleLiked?.contains(lid) == false)
//                    {
//                        arrayArticleLiked?.add(lid)
//
//                        // thich
//                        cell.imgLike.image = UIImage.init(named: "Like-article-active")
//                    }
//                    else
//                    {
//                        arrayArticleLiked?.remove(lid)
//
//                        //bo thich
//                        cell.imgLike.image = UIImage.init(named: "Like_video")
//                    }
//                    UserDefault.sharedInstance.setArrayArticleLiked(arrayArticleLiked: arrayArticleLiked!)
                }
            }
        }
    }
    
    func ListVideoShowCollectionViewCell_CommentVideo(indexPath: IndexPath) {
        if let dictData = self.arrayDicVideo.object(at: indexPath.row) as? Model_Document
        {
            if(dictData.type == .contentTypeVideos)
            {
                let storyboard = Global.sharedInstance.getMainStoryboard()
                let pageCriticalViewController = storyboard.instantiateViewController(withIdentifier: "PageCriticalViewController") as! PageCriticalViewController
                pageCriticalViewController.infoArticleCommentProto = dictData
                self.navigationController?.pushViewController(pageCriticalViewController, animated: true)
            }
        }
    }
    
    func ListVideoShowCollectionViewCell_ShareVideo(btn: UIButton) {
        if let dictData = self.arrayDicVideo.object(at: btn.tag) as? Model_Document
        {
            if(dictData.type == .contentTypeVideos)
            {
                let strUrl = dictData.video.fplayurl
                if let myWebsite = NSURL(string: strUrl) {
                    let objectsToShare = [myWebsite] as [Any]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

                    //New Excluded Activities Code
                    activityVC.excludedActivityTypes =  [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
                    

                    activityVC.popoverPresentationController?.sourceView = btn
                    self.present(activityVC, animated: true, completion: nil)
                }
            }
        }
    }
    func gotoContentDocument(document:Any?, indexPath:IndexPath?)
    {
        if let data = document as? Model_Document
        {
//            let dictDataSubCat = self.arrayCatOfVideo.object(at: self.indexPage) as! NSDictionary
//            let idCat = String(format: "%i", dictDataSubCat.object(forKey: "id") as! Int)
//
//            DataTracking.sharedInstance.detectDataTrackingClick(dataDetect: data, pos: UInt32(indexPath!.row), appLocat: "888:" + String(format: "%i", idCat), appType: .appVideos)
            
            if(data.type == .contentTypeSponsors)
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
            else if(data.type == .contentTypeVideos)
            {
                self.gotoContentVideo(data: data, indexPath: indexPath)
            }
        }
    }
    
    func gotoContentVideo(data:Model_Document, indexPath:IndexPath?)
    {
        //vao man hinh detailViewController
        let storyboard = Global.sharedInstance.getMainStoryboard()
        let detailVideoViewController = storyboard.instantiateViewController(withIdentifier: "DetailVideoViewController") as! DetailVideoViewController

        let sid = data.video.sid
        let lid = data.video.lid
        let cid = data.video.cid
        let link = data.video.url
        let itemTopics = data.video.topics

        detailVideoViewController.sID = Int(sid)
        detailVideoViewController.infoArticleProto = data
        //detailViewController.checkClickCid = //dang xu ly

        detailVideoViewController.nameCategory =  Global.sharedInstance.getTopic(sid: Int(sid), cid: Int(cid))!

        detailVideoViewController.nameWebsite = Global.sharedInstance.getNameWebsite(sid: Int(sid))!

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
        FirebaseAnalyticLog.sharedInstance.logEvent(eventName: READ_ARTICLE, itemID: lid, itemName: Global.sharedInstance.getNameWebsite(sid: Int(sid))!, itemCategory: Global.sharedInstance.getTopic(sid: Int(999), cid: Int(data.video.supercid))!, itemTopics: itemTopics)
        
        FirebaseAnalyticLog.sharedInstance.logEvent(eventName: READ_ALL_ARTICLE, itemID: lid, itemName: Global.sharedInstance.getNameWebsite(sid: Int(sid))!, itemCategory: Global.sharedInstance.getTopic(sid: Int(999), cid: Int(data.video.supercid))!, location: READ_LIST_VIDEO_ARTICLE, itemTopics: itemTopics)

        if(self.viewParentController != nil)
        {
            self.viewParentController?.navigationController?.pushViewController(detailVideoViewController, animated: true)
        }
        else
        {
            self.navigationController?.pushViewController(detailVideoViewController, animated: true)
        }
    }
    func ListVideoShowCollectionViewCell_DidSelectArticle(btn: UIButton) {
        //print("tag = ", btn.tag)
                
        if let data = self.arrayDicVideo.object(at: btn.tag) as? Model_Document
        {
            //vao man hinh detailViewController
            let storyboard = Global.sharedInstance.getMainStoryboard()
            let detailVideoViewController = storyboard.instantiateViewController(withIdentifier: "DetailVideoViewController") as! DetailVideoViewController

            let sid = data.video.sid
            let lid = data.video.lid
            let cid = data.video.cid
            let link = data.video.url
            let itemTopics = data.video.topics

            detailVideoViewController.sID = Int(sid)
            detailVideoViewController.infoArticleProto = data

            detailVideoViewController.nameCategory =  Global.sharedInstance.getTopic(sid: Int(sid), cid: Int(cid))!

            detailVideoViewController.nameWebsite = Global.sharedInstance.getNameWebsite(sid: Int(sid))!

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
            let strNameWebsite = Global.sharedInstance.getNameWebsite(sid: Int(sid))!
            let strAutoVideo = UserDefault.sharedInstance.getSettingAutoPlayVideo()
            
            FirebaseAnalyticLog.sharedInstance.logEvent(eventName: READ_ARTICLE, itemID: lid, itemName: strNameWebsite, itemCategory: Global.sharedInstance.getTopic(sid: Int(999), cid: Int(data.video.supercid))!, itemTopics: itemTopics)
            FirebaseAnalyticLog.sharedInstance.logEvent(eventName: READ_ALL_ARTICLE, itemID: lid, itemName: strNameWebsite, itemCategory: Global.sharedInstance.getTopic(sid: Int(999), cid: Int(data.video.supercid))!, location: READ_LIST_VIDEO_ARTICLE, itemTopics: itemTopics)

            FirebaseAnalyticLog.sharedInstance.logEvent(eventName: PLAY_VIDEO, itemID: lid, itemName: strNameWebsite, itemCategory: Global.sharedInstance.getTopic(sid: Int(999), cid: Int(data.video.supercid))!, method: strAutoVideo ?? "", location: IN_LIST_VIDEO, itemTopics: itemTopics)

            self.navigationController?.pushViewController(viewController: detailVideoViewController, animated: true, completion: {

            })
        }
    }
    func getAdsOfGoogle(keyDetect:String)->AdsGoogleObject?
        {
            let arrayFB = self.adsGoogleDFP.arrAds
            
            if(arrayFB.count == 0)
            {
                return nil
            }
            
            //chua co phan tu nao
            if(detectAdsOfGoogle.count == 0)
            {
                let adsGoogleObject = arrayFB.firstObject
                detectAdsOfGoogle.setObject(adsGoogleObject as Any, forKey: keyDetect as NSCopying)
                return (adsGoogleObject as! AdsGoogleObject)
            }
            
            //truong hop trung
            for i in 0..<detectAdsOfGoogle.allKeys.count
            {
                let key = detectAdsOfGoogle.allKeys[i] as! String
                if(key == keyDetect)
                {
                    return (detectAdsOfGoogle.object(forKey: keyDetect) as! AdsGoogleObject)
                }
            }
            
            //truong khong trung
            for i in 0..<arrayFB.count
            {
                let adsGoogleObject = arrayFB[i]
                let arrValue = detectAdsOfGoogle.allValues as NSArray
                if(arrValue.contains(adsGoogleObject) == false)
                {
                    detectAdsOfGoogle.setObject(adsGoogleObject as Any, forKey: keyDetect as NSCopying)
                    return (adsGoogleObject as! AdsGoogleObject)
                }
            }
            
            return nil
            
    //        //exception
    //        var random: UInt32 = 0
    //        random = arc4random() % UInt32(arrayFB.count)
    //
    //        let adsGoogleObject = arrayFB[Int(random)]
    //        detectAdsOfGoogle.setObject(adsGoogleObject as Any, forKey: keyDetect as NSCopying)
    //        return adsGoogleObject as? AdsGoogleObject
        }
    func resetCurrentCell()
    {
        if(currentCellOfCollectionVideo.coverVideo != nil)
        {
            currentCellOfCollectionVideo.coverVideo.alpha = 1
            currentCellOfCollectionVideo.imgPlayVideo.alpha = 1
        }
    }
    
    func ListVideoShowCollectionViewCell_DidPlayVideo(btn: UIButton, method:String)
    {

        let indexPathClick = IndexPath.init(row: btn.tag, section: 0)
        let cellClick = collectionVideo?.cellForItem(at: indexPathClick)
        
        if let cell = cellClick as? ListVideoShowCollectionViewCell {
            
            resetCurrentCell()
            if currentCellOfCollectionVideo.viewFade != nil && currentCellOfCollectionVideo != cell {
                currentCellOfCollectionVideo.modeNight()
            }
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn, animations: {
                self.collectionVideo.scrollToItem(at: indexPathClick, at: .centeredVertically, animated: false)
            })
            currentCellOfCollectionVideo = cell
            playerView.controlView.timeSlider.value = 0.0
            playerView.controlView.hidetopBotViewControl()
            playerView.playerLayer?.resetPlayer()
            playerView.frame = currentCellOfCollectionVideo.btnPlayVideo.frame
            if let dictData = arrayDicVideo.object(at: btn.tag) as? Model_Document
            {
                //print("dictData: ", dictData)
                let listVideos = NSMutableArray.init()
                if(dictData.type == .contentTypeArticles)
                {
                    listVideos.addObjects(from: dictData.art.listVideos)
                }
                if(dictData.type == .contentTypeVideos)
                {
                    listVideos.addObjects(from: dictData.video.listVideos)
                }
                
                if(listVideos.count>0 && currentCellOfCollectionVideo.videoIndex < listVideos.count)
                {
                    queue.removeAll()
                    for path in listVideos
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
                        playerView.videoType = dictData.video.videoType
                        playerView.setVideo(resource: asset, videoMeta: dictData.video.videoMeta)
                        playerView.play()
                    }

//                    playerView.controlView.progressExtra.trackTintColor = .darkGray
                    playerView.delegate = self
                    playerView.controlView.volumeButton.setImage((mute ? UIImage.init(named: "ico-volume-off") : UIImage.init(named: "ico-volume-on")), for: .normal)
                    self.tagCellPlay = btn.tag
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        self.currentCellOfCollectionVideo.btnPlayVideo.addSubview(self.playerView)
                        self.currentCellOfCollectionVideo.coverVideo.alpha = 0
                        self.currentCellOfCollectionVideo.imgPlayVideo.alpha = 0
                        self.currentCellOfCollectionVideo.modeBright()
                        self.playerView.alpha = 1.0
                        self.unhighlightCollectionCell()
                    }) { (result) in
                        
                    }
                }
            }
        }
    }
    
    func highlightCollectionCell() {
        for cell in self.collectionVideo.visibleCells {
            if cell.isKind(of: GoogleAdsUnifiedCollectionViewCell.self) || cell.isKind(of: GoogleAdsBannerCollectionViewCell.self) || cell.isKind(of: ListNewsSponserCollectionViewCell.self) || cell.isKind(of: ListNewsUtilityCollectionViewCell.self) {
                cell.alpha = 1
            }
        }
    }

    func unhighlightCollectionCell() {
        
    }
    
    func ListVideoShowCollectionViewCell_EnableVideoActive(btn: UIButton, method:String)
    {
        let indexPathClick = IndexPath.init(row: btn.tag, section: 0)
        let cellClick = collectionVideo?.cellForItem(at: indexPathClick)
        
        if let cell = cellClick as? ListVideoShowCollectionViewCell {
            resetCurrentCell()
            if currentCellOfCollectionVideo.viewFade != nil  && currentCellOfCollectionVideo != cell {
                currentCellOfCollectionVideo.modeNight()
            }
            currentCellOfCollectionVideo = cell
            if let dictData = arrayDicVideo.object(at: btn.tag) as? Model_Document
            {
                
                let listVideos = NSMutableArray.init()
                if(dictData.type == .contentTypeArticles)
                {
                    listVideos.addObjects(from: dictData.art.listVideos)
                }
                if(dictData.type == .contentTypeVideos)
                {
                    listVideos.addObjects(from: dictData.video.listVideos)
                }
                
                if(listVideos.count>0 && currentCellOfCollectionVideo.videoIndex < listVideos.count)
                {
                    queue.removeAll()
                    for path in listVideos
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
                        playerView.videoType = dictData.video.videoType
                        let strAutoVideo = UserDefault.sharedInstance.getSettingAutoPlayVideo()
                        if strAutoVideo == "1" {
                            playerView.setVideo(resource: asset, shouldAutoPlay: true, videoMeta: dictData.video.videoMeta)
                        } else {
                            playerView.setVideo(resource: asset, videoMeta: dictData.video.videoMeta)
                        }
                    }

                    playerView.delegate = self
                    playerView.controlView.volumeButton.setImage((mute ? UIImage.init(named: "ico-volume-off") : UIImage.init(named: "ico-volume-on")), for: .normal)
                    
                    self.tagCellPlay = btn.tag
                    playerView.pause()
                    self.playerView.removeFromSuperview()
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        self.currentCellOfCollectionVideo.coverVideo.alpha = 1
                        self.currentCellOfCollectionVideo.imgPlayVideo.alpha = 1
                        self.currentCellOfCollectionVideo.modeBright()
                        self.playerView.alpha = 1.0
                    }) { (result) in
                        
                    }
                }
            }
        }
    }
    
    func ListVideoShowCollectionViewCell_DidPlayVideo(btn: UIButton)
    {
        //Thống kê
//        if let data = self.arrayDicVideo.object(at: btn.tag) as? Model_Document {
//            FirebaseAnalyticLog.sharedInstance.logEvent(eventName: PLAY_VIDEO, itemID: "", itemName: "", itemCategory: Global.sharedInstance.getTopic(sid: Int(999), cid: Int(data.video.supercid))!, method: "", location: IN_DARK_THEME)
//        }

        FirebaseAnalyticLog.sharedInstance.logEvent(eventName: PLAY_VIDEO, itemID: "", itemName: "", itemCategory: "", method: "", location: IN_DARK_THEME)

        self.ListVideoShowCollectionViewCell_DidPlayVideo(btn: btn, method: MANUAL)
    }
    
    func ListVideoShowCollectionViewCell_DidPreviousVideo(btn: UIButton) {
        
    }
    
    func ListVideoShowCollectionViewCell_DidNextVideo(btn: UIButton) {
        
    }
    
    func ListVideoShowCollectionViewCell_DidVolumeVideo(btn: UIButton) {
        
    }
}
extension ListVideoShowViewController : ListNewsUtilityCollectionViewCellDelegate
{
    func ListNewsUtilityCollectionViewCell_DidSelectUtility(indexPath: IndexPath) {
        self.gotoContentDocument(document: self.arrayDicVideo.object(at: indexPath.row), indexPath: indexPath)
     }
}
extension ListVideoShowViewController : ListNewsSponserCollectionViewCellDelegate
{
    func ListNewsSponserCollectionViewCell_DidSelectSponser(indexPath: IndexPath) {
        self.gotoContentDocument(document: self.arrayDicVideo.object(at: indexPath.row), indexPath: indexPath)
     }
}

extension ListVideoShowViewController: BMPlayerDelegate {
    
    func bmPlayer(player: BMPlayer, playerOrientChanged isFullscreen: Bool) {
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
        playerIsPlaying = true
    }
    
    func bmPlayer(player: BMPlayer, playerStateDidChange state: BMPlayerState) {
        print("| BMPlayerDelegate | playerStateDidChange | state - \(state)")
        statePlayer = state
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
    }
    
    func bmPlayer(player: BMPlayer, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {
    }
    
    func bmPlayer(player: BMPlayer, playerIsMute isMute: Bool) {
        UserDefaults.standard.setValue(isMute, forKey: "mute")
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
    
}

extension ListVideoShowViewController : AdsGoogleDFPDelegate
{
    func AdsGoogleDFP_didReceiveBanner(adsGoogleObject: AdsGoogleObject, isAdsCenter: AdPosition) {
        self.requestGoogleDFP()
        
        UIView.performWithoutAnimation {
            self.collectionVideo.reloadItems(at: self.arrayIndexPathAd)
        }
    }
    
    func AdsGoogleDFP_didReceiveNative(nativeAd: GADNativeAd, isAdsCenter: AdPosition) {
        self.requestGoogleDFP()
        
        UIView.performWithoutAnimation {
            self.collectionVideo.reloadItems(at: self.arrayIndexPathAd)
        }
    }
    
    func AdsGoogleDFP_didFailToReceiveAdWithError(error: Error, isAdsCenter: AdPosition) {
        self.requestGoogleDFP()
    }
}
extension ListVideoShowViewController : MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            let alert = UIAlertController(title: "Tin nhắn", message: "Huỷ gửi SMS!!!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            break
        case .sent:
            let alert = UIAlertController(title: "Tin nhắn", message: "SMS Đã gửi!!!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            break
        case .failed:
            let alert = UIAlertController(title: "Tin nhắn", message: "SMS Gửi bị lỗi!!!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            break
        default:
            let alert = UIAlertController(title: "Tin nhắn", message: "SMS Không thể gửi đi!!!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension ListVideoShowViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        highlightCollectionCell()
//        if scrollView.isTracking {
//            calcPlayVideo(isAutoPlay: false)
//        }
        if(scrollView.contentOffset.y == 0)
        {
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomConstraint?.constant = IS_IPHONE ? 64 : 84
                self.view.layoutIfNeeded()
            }) { (result) in
                
            }
        }
    }
        
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if(velocity.y > 0)
        {
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomConstraint?.constant = IS_IPHONE ? 64 : 84
                self.view.layoutIfNeeded()
            }) { (result) in
            }
        }
        else
        {
            UIView.animate(withDuration: 0.3, animations: {
                //hien ra
                self.bottomConstraint?.constant = IS_IPHONE ? -30 : -50
                self.view.layoutIfNeeded()
            }) { (result) in
            }
        }
    }
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        if let cell = collectionVideo.cellForItem(at: IndexPath(item: 0, section: 0)) as? ListVideoShowCollectionViewCell {
            playVideo(cell: cell, isAutoPlay: false)
        }
    }
    func calcPlayVideo(isAutoPlay: Bool)
    {
        if collectionVideo.isAtTop {
            self.scrollViewDidScrollToTop(collectionVideo)
            return
        }
        let center = self.view.convert(collectionVideo.center, to: collectionVideo)
        if let index = collectionVideo.indexPathForItem(at: center) {
            if let cell = collectionVideo.cellForItem(at: index) as? ListVideoShowCollectionViewCell {
                playVideo(cell: cell, isAutoPlay: isAutoPlay)
            } else {
                if let centerCell = collectionVideo.cellForItem(at: index) {
                    var playIndexPath: IndexPath?
                    if center.y < centerCell.center.y {
                        playIndexPath = IndexPath(item: index.item - 1, section: index.section)
                    } else {
                        playIndexPath = IndexPath(item: index.item + 1, section: index.section)
                    }
                    if playIndexPath == nil {return}
                    if let cell = collectionVideo.cellForItem(at: playIndexPath!) as? ListVideoShowCollectionViewCell {
                        playVideo(cell: cell, isAutoPlay: isAutoPlay)
                    }
                }
            }
        }
    }
    fileprivate func playVideo(cell: ListVideoShowCollectionViewCell, isAutoPlay: Bool) {
        if currentCellOfCollectionVideo == cell {return}
        let strAutoVideo = UserDefault.sharedInstance.getSettingAutoPlayVideo()
        currentCellOfCollectionVideo.modeNight()
        if let btnPlay = cell.btnPlayVideo {
            if(strAutoVideo == "1" || isAutoPlay == true)
            {
                self.ListVideoShowCollectionViewCell_DidPlayVideo(btn: btnPlay, method: AUTOMATIC)
            } else {
                self.ListVideoShowCollectionViewCell_EnableVideoActive(btn: cell.btnPlayVideo, method: AUTOMATIC)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if playerView.isPlaying {
            self.unhighlightCollectionCell()
        }
        
        calcPlayVideo(isAutoPlay: false)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if playerView.isPlaying {
            self.unhighlightCollectionCell()
        }
        if !decelerate
        {
            calcPlayVideo(isAutoPlay: false)
        }
    }
}

extension ListVideoShowViewController : ViewPopupLoginDelegate
{
    func loginFailed() {
        
    }
    func loginSuccess(messageText:String) {
        UIApplication.shared.keyWindow!.makeToast(message: "Đăng nhập thành công. \n Bạn hãy thích và chia sẻ video nhé!")
        
        self.buttonShowKeyboard.tag = 0
        self.clickHiddenKeyboard()
        for cell in collectionVideo.visibleCells {
            if let cel = cell as? ListVideoShowCollectionViewCell {
                cel.updateAvatar()
            }
        }
    }
}

extension ListVideoShowViewController : ViewInteractDelegate
{
    func actionLogin() {
        self.showViewLogin(text: TEXT_LOGINFB_REPORT)
    }
    
    func actionViewInteract(text: String) {
        UIApplication.shared.keyWindow!.makeToast(message: text)
    }
}

extension ListVideoShowViewController : GoogleAdsBannerCollectionViewCellDelegate
{
    func GoogleAdsBannerCollectionViewCell_ClickAds(indexPath: IndexPath) {
        self.collectionVideo.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
}

extension ListVideoShowViewController : GoogleAdsUnifiedCollectionViewCellDelegate
{
    func GoogleAdsUnifiedCollectionViewCell_ClickAds(indexPath: IndexPath) {
        self.collectionVideo.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
}

extension ListVideoShowViewController: FootBallUtilityDelegate {
    func utilityDidClick(tag: Int, collection: Model_CollectionMsg) {
        if(collection.utilities.count <= tag) {return}
        let obj = collection.utilities[tag]
        if obj.jumpType == 2 {
            let storyboard = Global.sharedInstance.getMainStoryboard()
            let webKitViewController = storyboard.instantiateViewController(withIdentifier: "WebKitViewController") as! WebKitViewController
            webKitViewController.url = obj.jumpLink
            
            webKitViewController.strTitle = obj.title
            
            self.navigationController?.pushViewController(webKitViewController, animated: true)
        } else if obj.jumpType == 1 {
            JumpScreenApp(obj: obj)
        }
    }
}
