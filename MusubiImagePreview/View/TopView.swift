//
//  TopView.swift
//  Musubi
//
//  Created by はるふ on 2017/12/27.
//  Copyright © 2017年 はるふ. All rights reserved.
//

import UIKit

final class TopView: UIView {
    private(set) lazy var contentView = UIView()
    let contentViewHeight: CGFloat = 44
    let contentViewHorizontalInset: CGFloat = 8
    
    private(set) lazy var titleLabel: UILabel = UILabel()
    var title: String = "" {
        didSet {
            titleLabel.text = title
            titleLabel.sizeToFit()
        }
    }
    
    var rightItem: UIView? {
        didSet {
            // 元々あれば消す
            oldValue?.removeFromSuperview()
            if let item = rightItem {
                self._configureItem(item, position: .right)
            }
        }
    }
    
    var leftItem: UIView? {
        didSet {
            // 元々あれば消す
            oldValue?.removeFromSuperview()
            if let item = leftItem {
                self._configureItem(item, position: .left)
            }
        }
    }
    
    enum ItemPosition {
        case right
        case left
    }
    
    /// You must not call this method manually
    private func _configureItem(_ item: UIView, position: ItemPosition) {
        contentView.addSubview(item)
        item.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [
            item.topAnchor.constraint(equalTo: contentView.topAnchor),
            item.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            item.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1)
        ]
        switch position {
        case .right:
            constraints.append(item.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -contentViewHorizontalInset))
        case .left:
            constraints.append(item.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: contentViewHorizontalInset))
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func _configureTitleLabel() {
        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1)
            ])
    }
    
    // TODO: インターフェース考える
    func addTo(viewController: UIViewController) {
        viewController.view.subviews.filter { $0 is TopView }.forEach { view in
            view.removeFromSuperview()
        }
        viewController.view.addSubview(self)
        
        self.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuideCompatible.topAnchor),
            contentView.heightAnchor.constraint(equalToConstant: contentViewHeight),
            contentView.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuideCompatible.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuideCompatible.rightAnchor),
            ])
        
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            self.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            self.leftAnchor.constraint(equalTo: viewController.view.leftAnchor),
            self.rightAnchor.constraint(equalTo: viewController.view.rightAnchor)
            ])
        
        _configureTitleLabel()
    }
}
