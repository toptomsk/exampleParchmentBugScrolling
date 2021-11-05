//
//  ListNewsViewController.swift
//  Tin
//
//  Created by Admin on 1/3/19.
//  Copyright © 2019 vietnb. All rights reserved.
//

import UIKit

protocol ListNewsVCScrollDelegate: class {
    func scrollViewDidEnd()
    func scrollViewDidScroll(scrollView: UIScrollView, offset: CGFloat)
}

class ListNewsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    
    var lastContentOffset: CGFloat = 0
    weak var delegate: ListNewsVCScrollDelegate?
    
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var naviBarHeight: NSLayoutConstraint!
    @IBOutlet weak var naviBar: CustomNavigationBar!
    
    @IBOutlet weak var viewUp:UIView!
    
    var btnUp: UIButton = UIButton()
    var offset:CGFloat = 0
    
    var isMainPage:Bool = true
    weak var parentVC: PageListNewsViewController?
    
    weak var viewParentController:UIViewController!

    @IBOutlet weak var titlePage: UILabel!
        
    @IBOutlet weak var collectionArticle: UICollectionView!
    @IBOutlet weak var imgLoadError: UIImageView!
   
    var bottomConstraint: NSLayoutConstraint?
    func createCollectionArticle()
    {
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.itemSize = CGSize(width: 10, height: 10)
        flowLayout.scrollDirection = .vertical
        
        self.collectionArticle.setCollectionViewLayout(flowLayout, animated: false)
        self.view.addSubview(self.collectionArticle)
        
        collectionArticle.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.bottom.equalToSuperview()
        }
        collectionArticle.backgroundColor = .white
        self.collectionArticle.alwaysBounceVertical = true
        self.view.addSubview(self.viewUp)
        self.view.insertSubview(self.btnUp, at: 1000)
        btnUp.setImage(UIImage(named: "icon_muiten_up"), for: .normal)
        self.btnUp.translatesAutoresizingMaskIntoConstraints = false
        btnUp.addTarget(self, action: #selector(actionUp), for: .touchUpInside)
        NSLayoutConstraint.activate([
            btnUp.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            btnUp.widthAnchor.constraint(equalToConstant: 30),
            btnUp.heightAnchor.constraint(equalToConstant: 30)
        ])
        bottomConstraint = btnUp.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: 64)
            bottomConstraint?.isActive = true
        
        collectionArticle.dataSource = self
        collectionArticle.delegate = self
        collectionArticle.register(UINib(nibName: "CustomCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CustomCollectionViewCell")
    }
    
    @IBAction func actionUp()
    {
        collectionArticle.setContentOffset(.init(x: 0, y: 1), animated: true)
        print("nhay vao set y = 1")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    //MARK: - Viewdidload
    override func viewDidLoad() {
        super.viewDidLoad()
        createCollectionArticle()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as! CustomCollectionViewCell
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets (top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: UIScreen.main.bounds.width, height: 150)
    }
    
    @objc func applicationBecomeActiveListNews() {
        
    }
  
    /*
    // MARK: - Go to Screen View
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
}

extension ListNewsViewController : UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if(scrollView.contentOffset.y == 0)
        {
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomConstraint?.constant = 64
                self.view.layoutIfNeeded()
            }) { (result) in
                
            }
        }
        
        let canUpdateMenu = (scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.frame.size.height)) < 0
        if let del = delegate, canUpdateMenu {
            let currentY = scrollView.contentOffset.y
            del.scrollViewDidScroll(scrollView: scrollView, offset: lastContentOffset - currentY)
            lastContentOffset = scrollView.contentOffset.y
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if(velocity.y > 0)
        {
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomConstraint?.constant = 64
                self.view.layoutIfNeeded()
            }) { (result) in
            }
        }
        else
        {
            UIView.animate(withDuration: 0.3, animations: {
                //hien ra
                self.bottomConstraint?.constant = -30
                self.view.layoutIfNeeded()
            }) { (result) in
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset.y
        if delegate != nil {
            delegate?.scrollViewDidEnd()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate
        {
            lastContentOffset = scrollView.contentOffset.y
            if delegate != nil {
                delegate?.scrollViewDidEnd()
            }
        }
    }
    
}
