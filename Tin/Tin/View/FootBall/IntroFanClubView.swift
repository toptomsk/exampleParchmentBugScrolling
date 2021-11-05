//
//  IntroFanClubView.swift
//  Tin
//
//  Created by hoanglinh on 03/11/2021.
//

import UIKit
import WebKit

@objc protocol IntroFanClubViewDelegate: AnyObject {
    
}

class IntroFanClubView: UIView {
    weak var delegate : IntroFanClubViewDelegate?
    
    var isShowing:Bool = false
    @IBOutlet weak var bottomInteract: NSLayoutConstraint!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnHidden: UIButton!
    @IBOutlet weak var viewContainer:UIView!
    
    var url : String? {
        didSet {
            guard let _url = url else {return}
            
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            let id = UserDefault.sharedInstance.getIdComment() == "" ? "" : "&user_id=\(UserDefault.sharedInstance.getIdComment())"
            let prefixCheckLogin = "&app_version=\(version)" + id
            
            if(_url.contains("tinmoi24.vn") || _url.contains("5play.mobi") ||
                _url.contains("appnews24h.com") || _url.contains("24h.com.vn")) {
                if(_url.contains("?") == true) {
                    url = _url + "&platform=ios&device_id=" + APIRequest.sharedInstance.getDeviceID() + prefixCheckLogin
                } else {
                    url = _url + "?platform=ios&device_id=" + APIRequest.sharedInstance.getDeviceID() + prefixCheckLogin
                }
            }
        }
    }
    
    @IBOutlet weak var heightViewContainer: NSLayoutConstraint!
    
    //Webview
    var webView: WKWebView!
    let reachability = try! Reachability()
    var noMoreDataView: NoMoreDataView = NoMoreDataView()
    private var bgView = UIView()
    let progressView = UIProgressView(progressViewStyle: .bar)
    private var estimatedProgressObserver: NSKeyValueObservation?
    
    deinit {
        if(self.webView != nil) {
            self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "jsHandler")
        }
        
        NotificationCenter.default.removeObserver(self)
        print("goi ham deinit IntroFanClubView")
    }
    
    class func fromNib<T: IntroFanClubView>() -> T {
        let name:String = "IntroFanClubView"
        let introFanClubView = Bundle.main.loadNibNamed(name, owner: nil, options: nil)![0] as! T
        
        introFanClubView.setupView()
        return introFanClubView
    }
    
    
    func setupView() {
        self.heightViewContainer.constant = SCREEN_HEIGHT - 150
        self.viewContainer.mixedBackgroundColor = .init(normal: Constant.Color.bgLightModeColor, night: Constant.Color.backgroundGameColor)
//        self.viewContainer.roundCorners([.topLeft, .topRight], radius: 8)
        self.btnAccept.setMixedTitleColor(.init(normal: .white, night: .white), forState: .normal)
        self.btnAccept.backgroundColor = UIColor(rgb: 0xF85959)
        self.btnAccept.titleLabel!.font = UIFont.init(name: FONT_SFDISPLAY_MEDIUM, size: IS_IPHONE ? 16:24)
        self.btnAccept.setTitle("Tham gia Club", for: .normal)
        
        self.isHidden = true
        btnHidden.layer.zPosition = 0
        btnHidden.backgroundColor = #colorLiteral(red: 0.03137254902, green: 0.03137254902, blue: 0.03137254902, alpha: 0.5)
        btnHidden.alpha = 0.6
        
        //WebView
        webView = WKWebView()
        webView.backgroundColor = .clear
        webView.navigationDelegate = self
        webView.configuration.userContentController.add(
        LeakAvoider(delegate:self), name: "jsHandler")
        
        self.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.equalTo(viewContainer.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(btnAccept.snp.top).offset(-16)
        }
        self.url = "https://lucky.tinmoi24.vn/fc-manchester-united-427?platform=ios&device_id=0601f87e-00b7-4918-818e-917571df050f&app_version=1.0.94&user_id=c9d2e8cf575fe2f29d84d8d07635d892"
        if(self.url != nil)
        {
            //print("url: ", self.url)
            if(self.url!.count > 0 && Global.sharedInstance.verifyUrl(urlString: self.url) == true)
            {
                if let url = URL(string: self.url!)
                {
                    webView.load(URLRequest(url: url))
                }
            }
        }
        
        webView.allowsBackForwardNavigationGestures = true
        
        progressView.frame = CGRect(x: 0, y: 0 + Global.sharedInstance.marginTopBarHeight(), width: SCREEN_WIDTH, height: 3)
        progressView.isHidden = true
        self.addSubview(progressView)
        //progressView.tintColor = UIColor(rgb: 0xF24F29)
        estimatedProgressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            
            guard let strongSelf = self else { return }
            print("goi ham deinit webkitviewcontroller \(webView.estimatedProgress)")
            
            strongSelf.progressView.progress = Float(webView.estimatedProgress)
        }
        
        //Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        refreshControl.mixedTintColor = .init(normal: .darkGray, night: .white)
        refreshControl.addTarget(self, action: #selector(reloadWebView(_:)), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl)
        
        //Lost connect
        let activityView = UIActivityIndicatorView()
        activityView.color = .lightGray
        activityView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        bgView.addSubview(activityView)
        activityView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
        }
        activityView.startAnimating()
        
        self.addSubview(noMoreDataView)
        self.addSubview(bgView)
        noMoreDataView.snp.makeConstraints { (make) in
            make.bottom.top.left.right.equalTo(self.webView)
        }
        bgView.snp.makeConstraints { (make) in
            make.bottom.top.left.right.equalTo(self.webView)
        }
        bgView.mixedBackgroundColor = .init(normal: .white, night: Constant.Color.bgDarkModeColor)
        noMoreDataView.mixedBackgroundColor = .init(normal: .white, night: Constant.Color.bgDarkModeColor)
        noMoreDataView.isHidden = true
        noMoreDataView.setupMessage("Tải lại", image: UIImage(named: "ic_lostconnect")) { [weak self] in
            guard let `self` = self else { return }
            self.loadURLwebView()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            print("Không kiểm tra được tình trạng mạng")
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .unavailable:
            self.noMoreDataView.isHidden = false
            self.bgView.isHidden = true
        default:
            break
        }
    }
    
    @objc private func loadURLwebView() {
        if(Global.sharedInstance.verifyUrl(urlString: self.url) == true)
        {
            if let url = URL(string: self.url)
            {
                self.webView.load(URLRequest(url: url))
            }

        }
    }
    
    @objc func reloadWebView(_ sender: UIRefreshControl) {
        webView.reload()
        sender.endRefreshing()
        self.webView.load(NSURLRequest(url: URL(string: url)!) as URLRequest)
    }
    
    @IBAction func actionButton(btn: UIButton) {
        if(btn.tag == 1) {
            //follow club
            
            self.actionClose {}
        } else {
            self.actionClose {}
        }
    }
    
    func actionOpen()
    {
        self.isHidden = false
        self.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomInteract.constant = 0 //IS_IPHONE_X ? 24 : 0
            self.layoutIfNeeded()

        }) { (finished) in
            self.isUserInteractionEnabled = true
            self.isShowing = true
        }
    }
    
    var offset:CGFloat = 680
    func actionClose(completion: @escaping() -> Void)
    {
        offset = heightViewContainer.constant
        if(IS_IPAD)
        {
            offset = heightViewContainer.constant
        }
        self.isUserInteractionEnabled = false
        
        if(isShowing == true)
        {
            //UIApplication.shared.keyWindow!.makeToast("Bạn đã theo dõi câu lạc bộ " + self.model_GClub.name)
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomInteract.constant = -self.offset
            self.layoutIfNeeded()
        }) { (finished) in
            self.isShowing = false
            self.isUserInteractionEnabled = true
            self.isHidden = true
            //self.delegate?.actionCloseViewFollowInfoClub?()
            completion()
        }
    }
    
    
}

extension IntroFanClubView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "jsHandler" {
            print(message.body)
        }
    }
    
}

extension IntroFanClubView: WKNavigationDelegate {
    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        if progressView.isHidden {
            // Make sure our animation is visible.
            progressView.isHidden = false
        }
        
        UIView.animate(withDuration: 0.33,
                       animations: {
                        self.progressView.alpha = 1.0
        })
    }
    
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        self.noMoreDataView.isHidden = true
        self.bgView.isHidden = true
        
        webView.evaluateJavaScript("<html><head><style>body { font-family: SFUIText-Regular;font-size:18px}</style><meta name='viewport' content='width=device-width,initial-scale=1'></head>", completionHandler: nil)
        UIView.animate(withDuration: 0.33,
                       animations: {
                        self.progressView.alpha = 0.0
        },
                       completion: { isFinished in
                        // Update `isHidden` flag accordingly:
                        //  - set to `true` in case animation was completly finished.
                        //  - set to `false` in case animation was interrupted, e.g. due to starting of another animation.
                        self.progressView.isHidden = isFinished
        })
    }
    
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        guard let url = navigationAction.request.url else {return}
//
//        decisionHandler(.allow)
//    }
}
