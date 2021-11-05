//
//  TabbarViewController.swift
//  Tin
//
//  Created by Admin on 1/3/19.
//  Copyright © 2019 vietnb. All rights reserved.
//

import UIKit

enum XKTypeEvent: Int {
    case XKNothing = 0
    case XKCovid = 1
    case XKBall = 2
}

enum TagPageNav: Int {
    case pageList = 1
    case pageVideo = 2
    case pageEventDynamic = 3
    case pageBall = 4
    case explore = 5
    case setting = 6
}

class TabbarViewController: UITabBarController, UITabBarControllerDelegate {
    var typeEvent:XKTypeEvent?
    
    var indexTab = -1
    var indexShowNoti = 0
    
    var notiTabbarView = UIView()
    var notiTabbarRedDotView = UIView()
    var notiTabbarText = UILabel()
    var contentView = UIView()
    var isShowRedDot: Bool = true
    deinit {
        print("goi ham deinit tabbarviewcontroller")
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.typeEvent = .XKNothing
        self.tabBar.isHidden = true
        // Do any additional setup after loading the view.
        
        initViewControllers()
    }
    func initViewControllers() {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let pageList = main.instantiateViewController(withIdentifier: "PageListNewsViewController") as! PageListNewsViewController
        let pageListNav = RootNavigationController(rootViewController: pageList)
        pageListNav.tagPage = TagPageNav.pageList.rawValue
        
        pageListNav.navigationBar.isHidden = true
        
        self.viewControllers = [pageListNav]
    }
}

class RootNavigationController: UINavigationController, UINavigationControllerDelegate {
    var tagPage = 0
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: true)
        
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
       
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {

        if let topVC = viewControllers.last {
            return topVC.preferredStatusBarStyle
        }
        return .default
    }
    
    override var prefersStatusBarHidden: Bool {
        if let topVC = viewControllers.last {
            return topVC.prefersStatusBarHidden
        }
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.perform(#selector(callDidFinish), with: nil, afterDelay: 2.0)
    }
    
    @objc func callDidFinish(){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarHidden(true, animated: false)
        self.setNeedsStatusBarAppearanceUpdate()
        setupFullWidthBackGesture()
        self.delegate = self
    }

    lazy var fullWidthBackGestureRecognizer = UIPanGestureRecognizer()

    private func setupFullWidthBackGesture() {
        guard
            let interactivePopGestureRecognizer = interactivePopGestureRecognizer,
            let targets = interactivePopGestureRecognizer.value(forKey: "targets")
        else {
            return
        }

        fullWidthBackGestureRecognizer.setValue(targets, forKey: "targets")
//        fullWidthBackGestureRecognizer.delegate = self
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        swipe.direction = .left
        view.addGestureRecognizer(swipe)
        fullWidthBackGestureRecognizer.require(toFail: swipe)
        view.addGestureRecognizer(fullWidthBackGestureRecognizer)
    }
    @objc func swipeAction() {}
}

extension RootNavigationController {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let isSystemSwipeToBackEnabled = interactivePopGestureRecognizer?.isEnabled == true
        let isThereStackedViewControllers = viewControllers.count > 1
        return isSystemSwipeToBackEnabled && isThereStackedViewControllers
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

        if let coordinator = navigationController.topViewController?.transitionCoordinator {
            coordinator.notifyWhenInteractionChanges { (context) in
                print("vuốt back failed: \(context.isCancelled)")
                if context.isCancelled == false {
                    NotificationCenter.default.post(name: Notification.Name("swipeBackNavigation"), object: nil)
                }
            }
        }
    }
    
}
