//
//  ImagesPreviewController.swift
//  Musubi
//
//  Created by はるふ on 2017/12/27.
//  Copyright © 2017年 有村琢磨. All rights reserved.
//

import UIKit

protocol IndexedPageType {
    var pageIndex: Int { get set }
}

/// 複数枚の画像を表示する
/// TODO: 画像一覧から選択する画面を作りたい
public final class ImagesPreviewController: UIPageViewController {
    
    /// images to show
    public var musubiImages: [MusubiImage] = []
    
    /// Current page index
    /// Set currentIndex to jump to specified page.
    public var currentIndex: Int? {
        get {
            return (viewControllers?.first as? IndexedPageType)?.pageIndex
        }
        set {
            if let index = newValue {
                self.setIndex(index)
            }
        }
    }
    
    // pull to dismiss
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(self.onPanned(_:)))
    }()
    
    // tap to hide / show navigation bar
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recogniser = UITapGestureRecognizer(target: self, action: #selector(self.onTapped(_:)))
        recogniser.delegate = self
        return recogniser
    }()
    
    private lazy var topView = TopView()
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @available(iOS 11.0, *)
    public override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        print("safearea", view.safeAreaInsets)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        // topView
        topView.titleLabel.textColor = UIColor.white
        topView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        topView.addTo(viewController: self)
        
        // dismiss button
        let dismissItem = UIButton(type: .system)
        dismissItem.setImage(UIImage.cross(size: CGSize(width: 44, height: 44), lineWidth: 2, color: UIColor.white.cgColor, edgeInset: UIEdgeInsets(top: 13, left: 13, bottom: 13, right: 13)), for: .normal)
        dismissItem.tintColor = UIColor.white
        dismissItem.addTarget(self, action: #selector(self.onTapDismiss), for: .touchUpInside)
        topView.rightItem = dismissItem
        
        
        self.dataSource = self
        self.delegate = self
        
        // pull to dismiss
        self.view.addGestureRecognizer(panGestureRecognizer)
        
        // tap to hide / show navigation bar
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        // Set initial ViewController if needed
        if currentIndex == nil {
            let succeeded = setIndex(0)
            if !succeeded {
                // Set empty viewController to avoid crashing
                setViewControllers([UIViewController()], direction: .forward, animated: true, completion: nil)
            }
        }
        _updateTitle()
    }
    
    @discardableResult
    private func setIndex(_ index: Int, animated: Bool = true, completion: ((Bool) -> Void)? = nil) -> Bool {
        if let viewController = _viewController(for: index) {
            let direction: UIPageViewControllerNavigationDirection = (index >= (currentIndex ?? 0) ? .forward : .reverse)
            setViewControllers([viewController], direction: direction, animated: animated, completion: completion)
            return true
        }
        return false
    }
    
    fileprivate func _viewController(for pageIndex: Int) -> UIViewController? {
        guard let image = musubiImages.get(pageIndex) else {
            return nil
        }
        let viewController = ImagePreviewViewController()
        viewController.musubiImage = image
        viewController.pageIndex = pageIndex
        // Prefer doubletap rather than single tap
        tapGestureRecognizer.require(toFail: viewController.doubleTapGestureRecognizer)
        return viewController
    }
    
    fileprivate func _updateTitle() {
        let showIndex = (currentIndex ?? 0) + 1
        topView.title = "\(showIndex)/\(musubiImages.count)"
    }
    
    @objc
    func onTapDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func onTapped(_ recognizer: UITapGestureRecognizer) {
        toggleNavigationBarHidden()
    }
    
    private func toggleNavigationBarHidden() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let topView = self?.topView else {
                return
            }
            topView.alpha = 1 - topView.alpha
        }
    }
    
    @objc
    func onPanned(_ recognizer: UIPanGestureRecognizer) {
        // pull to dismiss
        let translation = recognizer.translation(in: view)
        switch recognizer.state {
        case .began, .changed:
            if translation.y > 0 {
                self.view.layer.transform = CATransform3DMakeTranslation(0, translation.y, 0)
//                view.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended, .failed, .cancelled, .possible:
            if translation.y > view.frame.height / 4 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // rewind to initial position
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.view.layer.transform = CATransform3DIdentity
//                     self?.view.transform = CGAffineTransform.identity
                }
            }
        }
    }
}

extension ImagesPreviewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // ignore tap on topBar
        if gestureRecognizer == tapGestureRecognizer && (touch.view?.isDescendant(of: topView) ?? false) {
            return false
        }
        return true
    }
}

extension ImagesPreviewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            // When the page was turned without aborting
            _updateTitle()
        }
    }
}

extension ImagesPreviewController: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let page = viewController as? IndexedPageType else {
            return nil
        }
        return _viewController(for: page.pageIndex + 1)
    }
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let page = viewController as? IndexedPageType else {
            return nil
        }
        return _viewController(for: page.pageIndex - 1)
    }
}
