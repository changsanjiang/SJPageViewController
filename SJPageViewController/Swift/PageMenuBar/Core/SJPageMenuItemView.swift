//
//  SJPageMenuItemView.swift
//  Pods-SJPageViewControllerswift_Example
//
//  Created by BlueDancer on 2020/2/28.
//

import UIKit

public protocol SJPageMenuItemViewProtocol : UIView {
    var tintColor: UIColor? { set get }
    var isFocusedMenuItem : Bool { set get }
    func sizeThatFits(_ size: CGSize) -> CGSize
    func sizeToFit()
}

open class SJPageMenuItemView : UIView, SJPageMenuItemViewProtocol {
    public override init(frame: CGRect) {
        label = UILabel.init(frame: .zero)
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.textColor = .white
        super.init(frame: frame)
        self.addSubview(label)
    }
    
    open var isFocusedMenuItem : Bool = false
        
    override open var tintColor: UIColor? {
        set {
            label.textColor = newValue
        }
        get {
            return label.textColor
        }
    }
    
    open var font: UIFont {
        set {
            label.font = newValue
        }
        get {
            return label.font
        }
    }
    
    open var text: String? {
        set {
            label.text = newValue
        }
        get {
            return label.text
        }
    }
    
    open var attributedText: NSAttributedString? {
        set {
            label.attributedText = newValue
        }
        get {
            return label.attributedText
        }
    }
    
    private var label: UILabel
    
    open override var bounds: CGRect {
        didSet {
            let center = CGPoint.init(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
            label.center = center
        }
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return label.sizeThatFits(size)
    }
    
    open override func sizeToFit() {
        label.sizeToFit()
        var bounds = self.bounds
        bounds.size = label.bounds.size
        self.bounds = bounds
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
