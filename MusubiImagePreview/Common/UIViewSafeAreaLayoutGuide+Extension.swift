//
//  UIViewSafeAreaLayoutGuide+Extension.swift
//  Musubi
//
//  Created by ST20591 on 2017/11/15.
//  Copyright © 2017年 有村琢磨. All rights reserved.
//

import UIKit

extension UIView {
    var safeAreaInsetsCompatible: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets
        } else {
            return .zero
        }
    }
    
    /// Get ViewController using responder chain
    /// - SeeAlso: https://qiita.com/tomohisaota/items/3ac83f9b829e30ce624c
    func getViewController() -> UIViewController? {
        var responder = self as UIResponder
        while let nextResponder = responder.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}

protocol SafeAreaLayoutGuideCompatibleContainerType {
}

extension SafeAreaLayoutGuideCompatibleContainerType {
    var safeAreaLayoutGuideCompatible: SafeAreaLayoutGuideCompatible<Self> {
        return SafeAreaLayoutGuideCompatible(self)
    }
}

struct SafeAreaLayoutGuideCompatible<Base> {
    /// Base object to extend.
    let base: Base
    
    /// Creates extensions with base object.
    ///
    /// - parameter base: Base object.
    init(_ base: Base) {
        self.base = base
    }
}

extension UIView: SafeAreaLayoutGuideCompatibleContainerType {}

extension SafeAreaLayoutGuideCompatible where Base: UIView {
    var leftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return base.safeAreaLayoutGuide.leftAnchor
        } else {
            return base.leftAnchor
        }
    }
    
    var rightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return base.safeAreaLayoutGuide.rightAnchor
        } else {
            return base.rightAnchor
        }
    }
    
    var bottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return base.safeAreaLayoutGuide.bottomAnchor
        } else {
            return base.bottomAnchor
        }
    }
    
    var topAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return base.safeAreaLayoutGuide.topAnchor
        } else {
            return base.getViewController()?.topLayoutGuide.bottomAnchor ?? base.topAnchor
        }
    }
    
    var widthAnchor: NSLayoutDimension {
        if #available(iOS 11.0, *) {
            return base.safeAreaLayoutGuide.widthAnchor
        } else {
            return base.widthAnchor
        }
    }
    
    var heightAnchor: NSLayoutDimension {
        if #available(iOS 11.0, *) {
            return base.safeAreaLayoutGuide.heightAnchor
        } else {
            return base.heightAnchor
        }
    }
    
    var centerYAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return base.safeAreaLayoutGuide.centerYAnchor
        } else {
            return base.centerYAnchor
        }
    }
    
    var centerXAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return base.safeAreaLayoutGuide.centerXAnchor
        } else {
            return base.centerXAnchor
        }
    }
    
    var leadingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return base.safeAreaLayoutGuide.leadingAnchor
        } else {
            return base.leadingAnchor
        }
    }
    
    var trailingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return base.safeAreaLayoutGuide.trailingAnchor
        } else {
            return base.trailingAnchor
        }
    }
}

extension UIViewController: SafeAreaLayoutGuideCompatibleContainerType {}

extension SafeAreaLayoutGuideCompatible where Base: UIViewController {
    var topAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return base.view.safeAreaLayoutGuide.topAnchor
        } else {
            return base.topLayoutGuide.bottomAnchor
        }
    }
    
    var bottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return base.view.safeAreaLayoutGuide.bottomAnchor
        } else {
            return base.bottomLayoutGuide.topAnchor
        }
    }
}
