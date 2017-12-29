//
//  ViewController.swift
//  MusubiImagePreviewDemo
//
//  Created by ST20591 on 2017/12/29.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit
import MusubiImagePreview

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let vc = ImagesPreviewController(transitionStyle: .scroll,
                                         navigationOrientation: .horizontal,
                                         options: nil)
        vc.musubiImages = [MusubiImage(image: #imageLiteral(resourceName: "Twitter-halloween.png"))!,
                           .url("https://ha1f.net/images/profile/board.jpg"),
                           .url("https://ha1f.net/images/profile/Twitter%E3%82%A2%E3%82%A4%E3%82%B3%E3%83%B3-Valentine2.png"),
                           .url("https://ha1f.net/images/profile/Twitter%E3%82%A2%E3%82%A4%E3%82%B3%E3%83%B3-NF.png")]
        vc.currentIndex = 0
//        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }


}

