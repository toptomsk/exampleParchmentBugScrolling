//
//  ViewController.swift
//  Tin
//
//  Created by TopTomsk on 19/08/2020.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}
let IS_IPHONE = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone)
let SCREEN_MAX_LENGTH = (max(SCREEN_WIDTH, SCREEN_HEIGHT))
let IS_IPHONE_X = (IS_IPHONE && SCREEN_MAX_LENGTH >= 812.0)
let IS_IPHONE_5 = (IS_IPHONE && SCREEN_WIDTH <= 320)

let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad
let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
