//
//  ViewMoreCriticalCollectionViewCell.swift
//  Tin
//
//  Created by vietnb on 6/21/19.
//  Copyright © 2019 vietnb. All rights reserved.
//

import UIKit

protocol ViewMoreCriticalCollectionViewCellDelegate {
    func actionViewMoreComment()
}

class ViewMoreCriticalCollectionViewCell: UICollectionReusableView {
    
    var delegate:ViewMoreCriticalCollectionViewCellDelegate?
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var btnClick: UIButton!
    
    func setupView(arrayComment:NSMutableArray)
    {
        if(arrayComment.count == 0)
        {
            if(IS_IPAD)
            {
                let viewLine = UIView.init()
                viewLine.frame = CGRect(x: 30, y: 0, width: self.frame.width - 60, height: 1)
                viewLine.backgroundColor = UIColor(rgb: 0xebebeb)
                self.addSubview(viewLine)
            }
            
            self.lblTitle.font = UIFont.init(name: FONT_CONTENT_REGULAR, size: 14)
            
            self.lblTitle.frame = CGRect(x: 15, y: 15, width: self.frame.width - 30, height: 40)
            if(IS_IPAD)
            {
                self.lblTitle.frame = CGRect(x: 30, y: 60, width: self.frame.width - 60, height: 70)
                self.lblTitle.font = UIFont.init(name: FONT_CONTENT_REGULAR, size: 22)
            }
            self.lblTitle.text = "Nêu ý kiến của bạn"
            self.lblTitle.textColor = UIColor(rgb: 0xc71515)
            
            self.lblTitle.layer.borderColor = UIColor(rgb: 0xebebeb).cgColor
            self.lblTitle.layer.borderWidth = 0.5
            if(IS_IPAD)
            {
                self.lblTitle.layer.borderWidth = 2
            }
            
            self.lblTitle.layer.masksToBounds = true
            self.lblTitle.layer.cornerRadius = self.lblTitle.frame.height/2
        }
        else
        {
            self.lblTitle.font = UIFont.init(name: FONT_CONTENT_REGULAR, size: 14)
            
            self.lblTitle.frame = CGRect(x: 15, y: 15, width: self.frame.width - 30, height: 40)
            if(IS_IPAD)
            {
                self.lblTitle.frame = CGRect(x: 30, y: 21, width: self.frame.width - 60, height: 70)
                self.lblTitle.font = UIFont.init(name: FONT_CONTENT_REGULAR, size: 22)
            }
            self.lblTitle.text = "Xem thêm bình luận"
            self.lblTitle.textColor = UIColor(rgb: 0xc71515)
            
            self.lblTitle.layer.borderColor = UIColor(rgb: 0xebebeb).cgColor
            self.lblTitle.layer.borderWidth = 0.5
            if(IS_IPAD)
            {
                self.lblTitle.layer.borderWidth = 2
            }
            
            self.lblTitle.layer.masksToBounds = true
            self.lblTitle.layer.cornerRadius = self.lblTitle.frame.height/2;
        }
    }
    
    @IBAction func actionButton()
    {
        self.delegate?.actionViewMoreComment()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
