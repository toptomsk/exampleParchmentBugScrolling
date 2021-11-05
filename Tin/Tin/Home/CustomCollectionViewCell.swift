//
//  CustomCollectionViewCell.swift
//  Tin
//
//  Created by hoan nguyen on 05/11/2021.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = UIColor.random
    }

}
extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}
