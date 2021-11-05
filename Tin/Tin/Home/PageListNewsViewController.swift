import UIKit
import Parchment


let constantTop:CGFloat = -10

final class PageListNewsViewController: UIViewController {
    
    @IBOutlet weak var imgSearch: UIImageView!
    
    var jumpPageWithDeepLink:Int = 0
    
    var pagingViewController = PagingViewController()
    let listData = [NSDictionary]()
    
    @IBOutlet weak var logoApp: UIImageView!
    
    var arrChildren = [UIViewController]()
    
    @IBOutlet weak var lblHeader:UILabel!
    @IBOutlet weak var viewRightTitle:UIView!
    
    @IBOutlet weak var viewStatus:UIView!
    @IBOutlet weak var viewHeader:UIView!
    
    @IBOutlet weak var viewHeaderFirst:UIView!
    @IBOutlet weak var viewHeaderSecond:UIView!
    @IBOutlet weak var viewChildOfHeaderSecond:UIView!
    var isChildViewController = false
    
    @IBOutlet weak var viewTitle:UIView!
    var dictArticle:NSDictionary?
    
    @IBOutlet weak var heightHeader:NSLayoutConstraint!
    
    // weather
    @IBOutlet weak var weatherView: UIView!
    
    var topPagingConstraint: NSLayoutConstraint?
    let viewLogo = UIView()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    

    @IBAction func actionMenu()
    {
        //print("menu Button")
//        slideMenuController?.toggleLeft()
        NotificationCenter.default.post(name: Notification.Name("reloadMenuLeft"), object: nil, userInfo:nil)
    }
    
    @IBAction func actionBack()
    {
        //print("action Back")
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionCategoryOrder()
    {
        //print("action CategoryOrder")
//        let categoryOrderViewController = CategoryOrderViewController(nibName: "CategoryOrderViewController", bundle: nil)
//        self.navigationController?.pushViewController(categoryOrderViewController, animated: true)
    }
    
    @IBAction func actionRight()
    {
//        FirebaseAnalyticLog.sharedInstance.logEvent(eventName: APP_SEARCH, itemID: "", itemName: "", itemCategory: "")

//        let storyboard = Global.sharedInstance.getMainStoryboard()
//        let searchViewController = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
//        self.navigationController?.pushViewController(searchViewController, animated: true)
    }
    
    private func loadPaging() {
        
        for i in 0..<20 {
            let list = ListNewsViewController()
            list.title = "tab \(i)"
            list.parentVC = self
            list.delegate = self
            arrChildren.append(list)
        }
        
        view.backgroundColor = .white
        
        pagingViewController = PagingViewController(viewControllers: arrChildren)
        pagingViewController.menuItemSize = .selfSizing(estimatedWidth: 20, height: 44)
        pagingViewController.menuItemSpacing = 16
        pagingViewController.menuItemLabelSpacing = 0
        pagingViewController.borderColor = UIColor(white: 0, alpha: 0.1)
        pagingViewController.indicatorColor = UIColor(rgb:0xF85959)
        pagingViewController.selectedTextColor = UIColor(rgb:0xF85959)//.white
        pagingViewController.delegate = self
        
        pagingViewController.indicatorOptions = .visible(
            height: 3,
            zIndex: Int.max,
            spacing: UIEdgeInsets.zero,
            insets: UIEdgeInsets.zero
        )
    
        pagingViewController.borderOptions = .hidden
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
        
        pagingViewController.didMove(toParent: self)
        if dictArticle == nil {
            pagingViewController.view.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            topPagingConstraint = pagingViewController.view.topAnchor.constraint(equalTo: viewHeader.bottomAnchor, constant: constantTop)
            topPagingConstraint?.isActive = true
            
            //MARK: Btn search
            view.addSubview(btnSearch)
            btnSearch.setImage(UIImage(named: "Search"), for: .normal)
            btnSearch.addTarget(self, action: #selector(actionRight), for: .touchUpInside)
            btnSearch.mixedBackgroundColor = .init(normal: .white, night: .black)
            btnSearch.imageView?.contentMode = .scaleAspectFit
            btnSearch.imageEdgeInsets = .init(top: 8, left: 0, bottom: 8, right: 0)
            btnSearch.contentHorizontalAlignment = .left
            btnSearch.snp.makeConstraints { (make) in
                make.width.equalTo(34)
                make.height.equalTo(34)
                make.centerY.equalTo(pagingViewController.collectionView.snp.centerY)
            }
            rightAnchorBtnSearch = btnSearch.rightAnchor.constraint(equalTo: view.rightAnchor, constant: IS_IPHONE ? 34 : 44)
            rightAnchorBtnSearch?.isActive = true

            
            //MARK: btn more category
            view.addSubview(btnAdd)
            btnAdd.setImage(UIImage(named: "Plus"), for: .normal)
            btnAdd.addTarget(self, action: #selector(actionCategoryOrder), for: .touchUpInside)
            btnAdd.mixedBackgroundColor = .init(normal: .white, night: .black)
            btnAdd.imageView?.contentMode = .scaleAspectFit
            btnAdd.snp.makeConstraints { (make) in
                make.right.equalTo(btnSearch.snp.left)
                make.width.equalTo(IS_IPHONE ? 34 : 44)
                make.height.equalTo(IS_IPHONE ? 34 : 44)
                make.centerY.equalTo(pagingViewController.collectionView.snp.centerY)
            }
            
            let viewShadow = UIView()
            view.addSubview(viewShadow)
            viewShadow.mixedBackgroundColor = .init(normal: .groupTableViewBackground, night: .darkGray)
            viewShadow.snp.makeConstraints { (make) in
                make.top.equalTo(pagingViewController.view.snp.top).offset(IS_IPHONE ? 44 : 60)
                make.height.equalTo(0.5)
                make.left.right.equalToSuperview()
            }
            if let pagingView = self.pagingViewController.view as? PagingView {
                pagingView.leftMenuAnchor?.constant = 16
                pagingView.rightMenuAnchor?.constant = IS_IPHONE ? -34 : -44
            }
            
            if viewLogo.superview != nil {
                viewLogo.removeFromSuperview()
            }
            view.addSubview(viewLogo)
            viewLogo.snp.makeConstraints { make in
                make.edges.equalTo(logoApp)
            }
            
        } else {
            pagingViewController.view.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(viewHeader.snp.bottom).offset(constantTop)
                make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
            }
            let viewShadow = UIView()
            view.addSubview(viewShadow)
            viewShadow.mixedBackgroundColor = .init(normal: .groupTableViewBackground, night: .darkGray)
            viewShadow.snp.makeConstraints { (make) in
                make.top.equalTo(viewHeader.snp.bottom).offset(IS_IPHONE ? 34 : 50)
                make.height.equalTo(0.5)
                make.left.right.equalToSuperview()
            }
            if let pagingView = self.pagingViewController.view as? PagingView {
                pagingView.leftMenuAnchor?.constant = 16
                pagingView.rightMenuAnchor?.constant = -16
            }
        }
    }
    
    var rightAnchorBtnSearch: NSLayoutConstraint?
    let btnAdd = UIButton()
    let btnSearch = UIButton()
    
    @IBAction func actionClimate(_ sender: UIButton) {
//        let listWebsite = ListWebsiteViewController()
//        self.navigationController?.pushViewController(listWebsite, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
//        bottomView.viewTabByIndex(index: 0)
        self.setNeedsStatusBarAppearanceUpdate()
        
//        if isChildViewController {
//            self.hideRedDotBall()
//        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        let window = UIApplication.shared.keyWindow
        for s in window!.subviews {
            if s.tag == 99 {
                s.removeFromSuperview()
                break
            }
        }
    }
    //test
    //var popupGeneralView = PopupGeneralView()
    
    deinit {
        print("goi ham deinit pagelistnewsviewcontroller")
        NotificationCenter.default.removeObserver(self)
    }
    
    var isActive = true
    var currentIdx = 0
    @objc func applicationDidBecomeActive() {

    }
    
    @objc func singleTapLogo() {
        if(currentIdx == 0)
        {
            if let vc = arrChildren[0] as? ListNewsViewController {
                vc.collectionArticle.setContentOffset(.init(x: 0, y: 1), animated: true)
            }
        } else {
            self.pagingViewController.select(index: 0, animated: true)
            currentIdx = 0
        }
    }
    @objc func doubleTapLogo() {
        self.pagingViewController.select(index: 0, animated: true)
        currentIdx = 0
        if let vc = arrChildren[0] as? ListNewsViewController {
            vc.collectionArticle.setContentOffset(.init(x: 0, y: 1), animated: true)
        }
    }
//    var darkModeView = DarkModeViewGuide()
//    let permission = ViewPermission()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        loadMoreCategory()
//        self.perform(#selector(removeLoading), with: self, afterDelay: 1)
        
    }
    
    @objc func removeLoading(){
        if let window = self.view.window
        {
            for i in 0..<window.subviews.count{
                let _view = window.subviews[i]
                if(_view.tag == 300)
                {
                    _view.removeFromSuperview()
                    break
                }
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapLogo))
        singleTap.numberOfTapsRequired = 1
        
        let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapLogo))
        doubleTap.numberOfTapsRequired = 2
        singleTap.require(toFail: doubleTap)
        singleTap.delaysTouchesBegan = true
        doubleTap.delaysTouchesBegan = true
        
        viewLogo.isUserInteractionEnabled = true
        viewLogo.addGestureRecognizer(singleTap)
        viewLogo.addGestureRecognizer(doubleTap)
        

        var heightBottom:CGFloat = 0
        if(self.dictArticle == nil)
        {
            heightBottom = 52
            if(IS_IPAD)
            {
                heightBottom = 66
            }
            self.viewHeaderFirst.isHidden = false
            self.viewHeaderSecond.isHidden = true
            
            self.viewChildOfHeaderSecond.layer.masksToBounds = true
            self.viewChildOfHeaderSecond.layer.cornerRadius = 8
            
        }
        else
        {
            if(self.dictArticle?.object(forKey: "name") != nil)
            {
                self.lblHeader.text = (self.dictArticle?.object(forKey: "name") as! String)
            }
            self.viewHeaderFirst.isHidden = true
            self.viewHeaderSecond.isHidden = false
            
            self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        }
        
        imgSearch.mixedImage = .init(normal: "ic_list_website", night: "ic_list_website_white")
        
        loadPaging()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popupSegue" {

        }
    }
}

extension PageListNewsViewController: PagingViewControllerDelegate {

    func pagingViewController(_ pagingViewController: PagingViewController, didScrollToItem pagingItem: PagingItem, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        
    }
}

extension PageListNewsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
extension UIScrollView {
   func scrollToRight(animated: Bool) {
     if self.contentSize.width < self.bounds.size.width { return }
     let rightOffset = CGPoint(x: self.contentSize.width, y: 0)
     self.setContentOffset(rightOffset, animated: animated)
  }
}

extension PageListNewsViewController : UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets (top: 0, left: 0, bottom: 0, right: 0)
    }
}

//MARK: - Animation header menu when scroll
extension PageListNewsViewController: ListNewsVCScrollDelegate {
    
    //Setup lại constraint ko để cho menu ở lưng chừng
    func scrollViewDidEnd() {
        let currentOffset = topPagingConstraint!.constant
        let constantSpace: CGFloat = IS_IPHONE ? 50 : 64
        UIView.animate(withDuration: 0.3) {
            if currentOffset <= -(IS_IPHONE ? 30 : 37) {
                self.topPagingConstraint?.constant = -constantSpace
                self.viewChildOfHeaderSecond.alpha = 0
                self.weatherView.alpha = 0
                if let pagingView = self.pagingViewController.view as? PagingView {
                    pagingView.leftMenuAnchor?.constant = IS_IPHONE ? 56 : 70
                    pagingView.rightMenuAnchor?.constant = IS_IPHONE ? -68 : -88
                }
                self.rightAnchorBtnSearch?.constant = 0
            } else {
                self.topPagingConstraint?.constant = constantTop
                self.weatherView.alpha = 1
                self.viewChildOfHeaderSecond.alpha = 1
                if let pagingView = self.pagingViewController.view as? PagingView {
                    pagingView.leftMenuAnchor?.constant = 16
                    pagingView.rightMenuAnchor?.constant = IS_IPHONE ? -34 : -44
                }
                self.rightAnchorBtnSearch?.constant = IS_IPHONE ? 34 : 44
                
            }
            self.view.layoutIfNeeded()
        }
    }
    
    //Tính toán constraint khi đang thao tác scroll
    func scrollViewDidScroll(scrollView: UIScrollView, offset: CGFloat) {
        if scrollView.contentOffset.y <= 1 {
            if self.topPagingConstraint?.constant != constantTop {
                self.topPagingConstraint?.constant = constantTop
                self.rightAnchorBtnSearch?.constant = IS_IPHONE ? 34 : 44
                self.weatherView.alpha = 1
                self.viewChildOfHeaderSecond.alpha = 1
            }
            if let pagingView = self.pagingViewController.view as? PagingView {
                pagingView.leftMenuAnchor?.constant = 16
                pagingView.rightMenuAnchor?.constant = IS_IPHONE ? -34 : -44
            }
            return
        }
        let constantSpace: CGFloat = IS_IPHONE ? 50 : 64
        let divideConstant = constantSpace - 10
        let newOffset = topPagingConstraint!.constant + offset
        if let pagingView = self.pagingViewController.view as? PagingView {
            let leftOff = 6 + (newOffset >= -constantSpace ? -newOffset : constantSpace)
            if newOffset <= constantTop {
                pagingView.leftMenuAnchor?.constant = leftOff
                pagingView.rightMenuAnchor?.constant = -34 + (newOffset >= -constantSpace ? newOffset : -constantSpace)/2
                self.viewChildOfHeaderSecond.alpha = (newOffset + constantSpace)/divideConstant
                self.weatherView.alpha = (newOffset + constantSpace)/divideConstant
                if newOffset < -constantSpace {
                    self.rightAnchorBtnSearch?.constant = 0
                } else {
                    self.rightAnchorBtnSearch?.constant = (34*newOffset + constantSpace*34)/divideConstant
                }
            } else {
                self.weatherView.alpha = 1
                self.viewChildOfHeaderSecond.alpha = 1
                pagingView.leftMenuAnchor?.constant = 16
                pagingView.rightMenuAnchor?.constant = IS_IPHONE ? -34 : -44
                self.rightAnchorBtnSearch?.constant = IS_IPHONE ? 34 : 44
            }
        }
        if newOffset < -constantSpace {
            self.topPagingConstraint?.constant = -constantSpace
        } else if newOffset > constantTop {
            self.topPagingConstraint?.constant = constantTop
        } else {
            self.topPagingConstraint?.constant = newOffset
        }
        
    }
}
