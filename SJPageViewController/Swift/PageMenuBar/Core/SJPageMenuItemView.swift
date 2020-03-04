//
//  SJPageMenuItemView.swift
//  Pods-SJPageViewControllerswift_Example
//
//  Created by BlueDancer on 2020/2/28.
//

import UIKit

public protocol SJPageMenuItemViewProtocol : UIView {
    var tintColor: UIColor? { set get }
    func sizeThatFits(_ size: CGSize) -> CGSize
    func sizeToFit()
}

open class SJPageMenuItemView : UILabel, SJPageMenuItemViewProtocol {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = .white
        font = .boldSystemFont(ofSize: 20)
        textAlignment = .center
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var tintColor: UIColor? {
        set {
            self.textColor = newValue
        }
        get {
            return self.textColor
        }
    }
}
