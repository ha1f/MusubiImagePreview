//
//  MusubiImageData.swift
//  Musubi
//
//  Created by はるふ on 2017/12/29.
//  Copyright © 2017年 はるふ. All rights reserved.
//

import UIKit
import Photos

public enum MusubiImage {
    case data(Data)
    case url(String)
    case phAssetLocalIdentifier(String)
    
    /// (image: UIImage?, isDegraded: Bool)
    public typealias MusubiImageDataFetchObserver = (UIImage?, Bool) -> ()
    
    public var identifier: Int {
        return hashValue
    }
    
    public init?(alAssetUrl: URL) {
        guard let phAssetLocalIdentifier = PHAsset.fetchAssets(withALAssetURLs: [alAssetUrl], options: nil).firstObject?.localIdentifier else {
            return nil
        }
        self = MusubiImage.phAssetLocalIdentifier(phAssetLocalIdentifier)
    }
    
    public init?(image: UIImage) {
        guard let data = UIImagePNGRepresentation(image) else {
            return nil
        }
        self = MusubiImage.data(data)
    }
    
    /// Fetch resized image
    /// Note: observer can be called in background thread
    public func fetchResizedImage(size: CGSize, observer: MusubiImageDataFetchObserver?) {
        switch self {
        case .data(let data):
            observer?(UIImage(data: data)?.aspectResized(to: size), false)
        case .url(let urlString):
            guard let url = URL(string: urlString) else {
                observer?(nil, false)
                return
            }
            _fetchImageWithUrl(url: url) { (image, isDegraded) in
                observer?(image?.aspectResized(to: size), isDegraded)
            }
        case .phAssetLocalIdentifier(let identifier):
            guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject else {
                observer?(nil, false)
                return
            }
            _fetchResizedImageWithAsset(asset, size: size, contentMode: .aspectFill, observer: observer)
        }
    }
    
    /// Note: observer can be called in background thread
    public func fetchOriginalImage(observer: MusubiImageDataFetchObserver?) {
        switch self {
        case .data(let data):
            observer?(UIImage(data: data), false)
        case .url(let urlString):
            guard let url = URL(string: urlString) else {
                observer?(nil, false)
                return
            }
            _fetchImageWithUrl(url: url, observer: observer)
        case .phAssetLocalIdentifier(let identifier):
            guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject else {
                observer?(nil, false)
                return
            }
            _fetchOriginalImageWithAsset(asset, observer: observer)
        }
    }
    
    private func _fetchImageWithAsset(_ asset: PHAsset, size: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions, observer: MusubiImageDataFetchObserver?) {
        PHImageManager.default()
            .requestImage(for: asset, targetSize: size, contentMode: contentMode, options: options) { image, info in
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                observer?(image, isDegraded)
        }
    }
    
    private func _fetchOriginalImageWithAsset(_ asset: PHAsset, observer: MusubiImageDataFetchObserver?) {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.resizeMode = PHImageRequestOptionsResizeMode.none
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.opportunistic
        _fetchImageWithAsset(asset, size: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options, observer: observer)
    }
    
    /// observer can be called more than once
    /// (image, isDegraded)
    private func _fetchResizedImageWithAsset(_ asset: PHAsset, size: CGSize, contentMode: PHImageContentMode, resizeMode: PHImageRequestOptionsResizeMode = .fast, observer: MusubiImageDataFetchObserver?) {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.resizeMode = resizeMode
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.opportunistic
        _fetchImageWithAsset(asset, size: size, contentMode: contentMode, options: options, observer: observer)
    }
    
    private func _fetchImageWithUrl(url: URL, observer: MusubiImageDataFetchObserver?) {
        DispatchQueue.global(qos: .background).async {
            guard let data = try? Data(contentsOf: url) else {
                observer?(nil, false)
                return
            }
            guard let image = UIImage(data: data) else {
                observer?(nil, false)
                return
            }
            observer?(image, false)
        }
    }
}

extension MusubiImage: Equatable {
    public static func ==(lhs: MusubiImage, rhs: MusubiImage) -> Bool {
        if case .data(let ldata) = lhs, case .data(let rdata) = rhs {
            return ldata == rdata
        } else if case .url(let ldata) = lhs, case .url(let rdata) = rhs {
            return ldata == rdata
        } else if case .phAssetLocalIdentifier(let ldata) = lhs, case .phAssetLocalIdentifier(let rdata) = rhs {
            return ldata == rdata
        }
        return false
    }
}

extension MusubiImage: Hashable {
    public var hashValue: Int {
        switch self {
        case .data(let data):
            return data.hashValue
        case .url(let url):
            return url.hashValue
        case .phAssetLocalIdentifier(let identifier):
            return identifier.hashValue
        }
    }
}

/// Rx
//extension MusubiImage {
//    func fetchOriginalImage() -> Observable<UIImage?> {
//        return Observable<UIImage?>.create { observer in
//            self.fetchOriginalImage { (image, isDegraded) in
//                observer.onNext(image)
//                if !isDegraded {
//                    observer.onCompleted()
//                }
//            }
//            return Disposables.create()
//        }
//    }
//
//    func fetchResizedImage(size: CGSize) -> Observable<UIImage?> {
//        return Observable<UIImage?>.create { observer in
//            self.fetchResizedImage(size: size) { (image, isDegraded) in
//                observer.onNext(image)
//                if !isDegraded {
//                    observer.onCompleted()
//                }
//            }
//            return Disposables.create()
//        }
//    }
//}

