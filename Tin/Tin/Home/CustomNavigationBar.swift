//
//  CustomNavigationBar.swift
//  Tin
//
//  Created by nguyen hoan on 3/11/20.
//  Copyright © 2020 vietnb. All rights reserved.
//

import UIKit

protocol NaviBarDelegate: class {
    func backClicked()
    func rightBtnClick()
    func growthBtnClick()
}
extension NaviBarDelegate {
    func rightBtnClick() {
    
    }
    
    func growthBtnClick() {
    
    }
}


class CustomNavigationBar: UIView {

    var title = UILabel()
    var btnBack = UIButton(type: .system)
    var rightBtn = UIButton()
    var growthBtn = UIButton()
    weak var delegate: NaviBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = .white
        
        title.textColor = .black
        title.textAlignment = .center
        btnBack.setMixedImage(.init(normal: "icon_back_black", night: "icon_back_white"), forState: .normal)
        btnBack.mixedTintColor = .init(normal: .black, night: .white)
        rightBtn.imageView?.contentMode = .scaleAspectFit
        
        addSubview(title)
        addSubview(btnBack)
        addSubview(rightBtn)
        addSubview(growthBtn)
        title.translatesAutoresizingMaskIntoConstraints = false
        btnBack.translatesAutoresizingMaskIntoConstraints = false
        rightBtn.translatesAutoresizingMaskIntoConstraints = false
        growthBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            //title.centerXAnchor.constraint(equalTo: centerXAnchor),
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 44),
            title.rightAnchor.constraint(equalTo: rightAnchor, constant: -44),
            title.centerYAnchor.constraint(equalTo: centerYAnchor),
            title.topAnchor.constraint(equalTo: topAnchor),
            
            btnBack.topAnchor.constraint(equalTo: topAnchor),
            btnBack.leftAnchor.constraint(equalTo: leftAnchor),
            btnBack.heightAnchor.constraint(equalTo: heightAnchor),
            btnBack.widthAnchor.constraint(equalTo: btnBack.heightAnchor),
            
            rightBtn.topAnchor.constraint(equalTo: topAnchor),
            rightBtn.rightAnchor.constraint(equalTo: rightAnchor, constant: -6),
            rightBtn.heightAnchor.constraint(equalTo: heightAnchor),
            rightBtn.widthAnchor.constraint(equalTo: rightBtn.heightAnchor),
            
            growthBtn.topAnchor.constraint(equalTo: topAnchor),
            growthBtn.rightAnchor.constraint(equalTo: rightBtn.leftAnchor, constant: -6),
            growthBtn.heightAnchor.constraint(equalTo: heightAnchor),
            growthBtn.widthAnchor.constraint(equalTo: rightBtn.heightAnchor)
            
        ])
        btnBack.addTarget(self, action: #selector(backClicked), for: .touchUpInside)
        rightBtn.addTarget(self, action: #selector(rightBtnClicked), for: .touchUpInside)
        growthBtn.addTarget(self, action: #selector(growthBtnClicked), for: .touchUpInside)
    }
    
    @objc func backClicked() {
        delegate?.backClicked()
    }
    @objc func rightBtnClicked() {
        delegate?.rightBtnClick()
    }
    
    @objc func growthBtnClicked() {
        delegate?.growthBtnClick()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
}
