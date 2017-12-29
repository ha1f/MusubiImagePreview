//
//  ImagePreviewViewController.swift
//  Musubi
//
//  Created by はるふ on 2017/12/18.
//  Copyright © 2017年 はるふ. All rights reserved.
//

import UIKit

public final class ImagePreviewViewController: UIViewController, IndexedPageType {
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        return scrollView
    }()
    
    /// double tap to zoomToFit
    private(set) lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onDoubleTapped(_:)))
        gestureRecognizer.numberOfTapsRequired = 2
        return gestureRecognizer
    }()
    
    private lazy var imageView: MusubiImageView = {
        let imageView = MusubiImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    public var musubiImage: MusubiImage?
    var pageIndex: Int = 0
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        // scrollView
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
        
        // imageView
        scrollView.addSubview(imageView)
        imageView.frame = scrollView.bounds
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            imageView.leftAnchor.constraint(equalTo: scrollView.leftAnchor)
            ])
        
        // double tap gesture recognizer
        self.scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imageView.setImage(musubiImage, original: true) { [weak self] updated in
            guard let `self` = self, updated else {
                return
            }
            
            if let imageSize = self.imageView.image?.size {
                self.imageView.frame = CGRect(origin: .zero, size: imageSize)
                self.scrollView.contentSize = imageSize
            }
            self.scrollView.minimumZoomScale = min(self._aspectFitScale(), 1)
            self.scrollView.maximumZoomScale = max(self.scrollView.minimumZoomScale * 8,  1)
            
            // zoom
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: false)
            self._updateContentInset()
        }
    }
    
    @available(iOS 11.0, *)
    public override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        self._updateContentInset()
    }
    
    private func _updateContentInset() {
        // frameのほうがcontentSizeより大きい時にinsetをつける
        let width = self.scrollView.frame.width
        let height = self.scrollView.frame.height
        
        let lrInset = max((width - self.scrollView.contentSize.width) / 2, 0)
        let tbInset = max((height - self.scrollView.contentSize.height) / 2, 0)
        
        self.scrollView.contentInset = UIEdgeInsets(
            top: max(tbInset, scrollView.safeAreaInsetsCompatible.top),
            left: max(lrInset, scrollView.safeAreaInsetsCompatible.left),
            bottom: max(tbInset, scrollView.safeAreaInsetsCompatible.bottom),
            right: max(lrInset, scrollView.safeAreaInsetsCompatible.right))
    }
    
    private func _aspectFitScale() -> CGFloat {
        let width = self.scrollView.frame.width - self.scrollView.safeAreaInsetsCompatible.left - self.scrollView.safeAreaInsetsCompatible.right
        let height = self.scrollView.frame.height - self.scrollView.safeAreaInsetsCompatible.top - self.scrollView.safeAreaInsetsCompatible.bottom
        let imageSizse = self.imageView.image?.size ?? CGSize.zero
        let imageWidthForCalc = max(imageSizse.width, 1)
        let imageHeightForCalc = max(imageSizse.height, 1)
        return min(width / imageWidthForCalc, height / imageHeightForCalc)
    }
    
    private func _aspectFillScale() -> CGFloat {
        let width = self.scrollView.frame.width - self.scrollView.safeAreaInsetsCompatible.left - self.scrollView.safeAreaInsetsCompatible.right
        let height = self.scrollView.frame.height - self.scrollView.safeAreaInsetsCompatible.top - self.scrollView.safeAreaInsetsCompatible.bottom
        let imageSizse = self.imageView.image?.size ?? CGSize.zero
        let imageWidthForCalc = max(imageSizse.width, 1)
        let imageHeightForCalc = max(imageSizse.height, 1)
        return max(width / imageWidthForCalc, height / imageHeightForCalc)
    }
    
    @objc
    func onDoubleTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        let fitScale = _aspectFitScale()
        if fitScale == scrollView.zoomScale {
            self.scrollView.setZoomScale(1.0, animated: true)
        } else {
            self.scrollView.setZoomScale(fitScale, animated: true)
        }
    }
}

extension ImagePreviewViewController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self._updateContentInset()
    }
}

