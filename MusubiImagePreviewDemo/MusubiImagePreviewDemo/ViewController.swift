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
        
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 40)))
        button.backgroundColor = UIColor.orange
        button.setTitle("show", for: .normal)
        button.center = view.center
        button.addTarget(self, action: #selector(self.onButtonTapped), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc
    func onButtonTapped() {
        let vc = ImagesPreviewController(transitionStyle: .scroll,
                                         navigationOrientation: .horizontal,
                                         options: nil)
        vc.musubiImages = [MusubiImage(image: #imageLiteral(resourceName: "Twitter-halloween.png"))!,
                           .url("https://ha1f.net/images/profile/board.jpg"),
                           .url("https://ha1f.net/images/profile/Twitter%E3%82%A2%E3%82%A4%E3%82%B3%E3%83%B3-Valentine2.png"),
                           .url("https://ha1f.net/images/profile/Twitter%E3%82%A2%E3%82%A4%E3%82%B3%E3%83%B3-NF.png")]
        vc.currentIndex = 0
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }

}

