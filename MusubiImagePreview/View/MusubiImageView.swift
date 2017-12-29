//
//  MusubiImageView.swift
//  Musubi
//
//  Created by はるふ on 2017/01/22.
//  Copyright © 2017年 有村琢磨. All rights reserved.
//

import UIKit

class MusubiImageView: UIImageView {
    private static let loadingImage: UIImage? = nil
    
    private var _musubiImage: MusubiImage?
    public var musubiImage: MusubiImage? {
        set {
            _musubiImage = newValue
            refreshImage()
        }
        get {
            return _musubiImage
        }
    }
    private var representingImageDataHash: Int? = nil
    
    public func setImage(_ image: MusubiImage?, original: Bool = false, completion: ((Bool)->Void)? = nil) {
        _musubiImage = image
        // 空
        guard let mImage = image else {
            let updated = self.image != MusubiImageView.loadingImage
            self.image = MusubiImageView.loadingImage
            completion?(updated)
            return
        }
        // 既に同じ画像のときは、サイズがより大きいときのみセット
        let wasSameImage = self.representingImageDataHash == mImage.hashValue
        self.representingImageDataHash = mImage.hashValue
        
        let observer: MusubiImage.MusubiImageDataFetchObserver = { [weak self] image, isDegraded in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    completion?(false)
                    return
                }
                if mImage.hashValue == self.representingImageDataHash {
                    if !wasSameImage || ((self.image?.size.width ?? 0) < (image?.size.width ?? 0)) {
                        self.image = image
                        completion?(true)
                    } else {
                        completion?(false)
                    }
                } else {
                    completion?(false)
                }
            }
        }
        if original {
            mImage.fetchOriginalImage(observer: observer)
        } else {
            mImage.fetchResizedImage(size: self.bounds.size.scaled(by: UIScreen.main.scale), observer: observer)
        }
    }
    
    public func refreshImage(completion: ((Bool) -> Void)? = nil) {
        setImage(musubiImage, original: false, completion: completion)
    }
}
