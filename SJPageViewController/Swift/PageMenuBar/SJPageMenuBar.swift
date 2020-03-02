//
//  SJPageMenuBar.swift
//  Pods-SJPageViewControllerswift_Example
//
//  Created by BlueDancer on 2020/2/28.
//

import UIKit

public protocol SJPageMenuBarDataSource: NSObjectProtocol {
    func numberOfItems(in menuBar: SJPageMenuBar) -> Int

    func pageMenuBar(_ menuBar: SJPageMenuBar, viewForItemAt index: Int) -> SJPageMenuItemViewProtocol
}

public protocol SJPageMenuBarDelegate: NSObjectProtocol {
    func pageMenuBar(_ bar: SJPageMenuBar, focusedIndexDidChange index: Int)
}

open class SJPageMenuBar: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open weak var dataSource: SJPageMenuBarDataSource? {
        didSet {
            reload()
        }
    }
    open weak var delegate: SJPageMenuBarDelegate?
    
    open private(set) var focusedIndex: Int = 0 {
        didSet {
            self.delegate?.pageMenuBar(self, focusedIndexDidChange: focusedIndex)
        }
    }
    open var numberOfItems: Int {
        return dataSource?.numberOfItems(in: self) ?? 0
    }
    
    open func reload() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_reload), object: nil)
        perform(#selector(_reload), with: nil, afterDelay: 0, inModes: [.common])
    }

    open func reloadItem(at index: Int, animated: Bool) {
        if isSafeIndex(index) {
            if menuItemViews.count < index {
                reload()
                return
            }
            
            let oldView = cache[index]
            cache[index] = nil
            let newView = viewForItem(at: index)
            newView?.center = oldView!.center
            scrollView.addSubview(newView!)
            menuItemViews[index] = newView!
            
            let oldViewAlpha = oldView!.alpha
            let newViewAlpha = newView!.alpha
            newView?.alpha = 0.001
            UIView.animate(withDuration: animated ? 0.25 : 0.0 , animations: {
                oldView?.alpha = 0.001
                newView?.alpha = newViewAlpha
                self.remakeConstraints(index)
            }) { (_) in
                oldView?.alpha = oldViewAlpha
                oldView?.removeFromSuperview()
            }
        }
    }
    
    open func scrollToItem(at index: Int, animated: Bool) {
        if isSafeIndex(index) && focusedIndex != index {
            let previousIdx = focusedIndex
            focusedIndex = index
            if self.bounds.size.width == 0 || self.bounds.size.height == 0 {
                return
            }
            UIView.animate(withDuration: animated ? 0.25 : 0.0, animations: {
                // previous
                if ( self.isSafeIndex(previousIdx) ) {
                    self.setZoomScale(self.minimumZoomScale, forMenuItemViewAt: previousIdx)
                }
                
                // to
                self.setZoomScale(self.maximumZoomScale, forMenuItemViewAt: index)
                self.remakeConstraints(previousIdx < index ? previousIdx : index)
                self.remakeConstraintsForScrollIndicator()
                self.setContentOffsetForScrollViewToIndex(index)
            })
        }
    }

    open func scroll(inRange range: NSRange, distaneProgress progress: CGFloat) {
        if isSafeIndex(range.location) && isSafeIndex(NSMaxRange(range)) {
            _scroll(inRange: range, distaneProgress: progress)
        }
    }

    
    open func viewForItem(at index: Int) -> SJPageMenuItemViewProtocol? {
        if ( index >= 0 && index < numberOfItems ) {
            if cache[index] == nil {
                guard let view = dataSource?.pageMenuBar(self, viewForItemAt: index) else {
                    assertionFailure("The menuItemView can't be nil!")
                    return nil
                }
                view.tintColor = focusedIndex == index ? focusedItemTintColor : itemTintColor
                view.sizeToFit()
                cache[index] = view
            }
            return cache[index]
        }
        return nil
    }
    
    open var distribution = Distribution.equalSpacing {
        didSet {
            if ( oldValue != distribution ) {
                remakeConstraints()
            }
        }
    }

    open var contentInsets = UIEdgeInsets.zero {
        didSet {
            scrollView.contentInset = contentInsets
            remakeConstraints()
        }
    }

    open var itemSpacing: CGFloat = 16.0 {
        didSet {
            if oldValue != itemSpacing {
                remakeConstraints()
            }
        }
    }

    open var itemTintColor = UIColor.systemGray {
        didSet {
            resetTintColorForMenuItemViews()
        }
    }

    open var focusedItemTintColor = UIColor.systemBlue {
        didSet {
            resetTintColorForMenuItemViews()
        }
    }

    open var minimumZoomScale: CGFloat = 1.0 {
        didSet {
            if oldValue != minimumZoomScale {
                remakeConstraints()
            }
        }
    }

    /// must be > minimum zoom scale to enable zooming.
    open var maximumZoomScale: CGFloat = 1.0 {
        didSet {
            if oldValue != maximumZoomScale {
                remakeConstraints()
            }
        }
    }

    open var showsScrollIndicator: Bool {
        set {
            scrollIndicator.isHidden = !newValue
        }
        get {
            return !scrollIndicator.isHidden
        }
    }

    open var scrollIndicatorSize = CGSize.init(width: 12, height: 2) {
        didSet {
            if oldValue.equalTo(scrollIndicatorSize) {
                remakeConstraintsForScrollIndicator()
            }
        }
    }

    open var scrollIndicatorBottomInsets: CGFloat = 3.0 {
        didSet {
            if oldValue != scrollIndicatorBottomInsets {
                remakeConstraintsForScrollIndicator()
            }
        }
    }

    open var scrollIndicatorTintColor = UIColor.systemBlue {
        didSet {
            scrollIndicator.backgroundColor = scrollIndicatorTintColor
        }
    }

    open var centerlineOffset: CGFloat = 0.0 {
        didSet {
            if oldValue != centerlineOffset {
                remakeConstraints()
            }
        }
    }
    
    public enum Distribution {
        case equalSpacing
        case fillEqually
    }
    
    private var cache = [Int:SJPageMenuItemViewProtocol]()
    private var scrollView: UIScrollView = {
        var scrollView = UIScrollView.init(frame: .zero)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        return scrollView
    }()
    private lazy var scrollIndicator: SJPageMenuBarScrollIndicator = {
        var scrollIndicator = SJPageMenuBarScrollIndicator.init(frame: .zero)
        scrollIndicator.backgroundColor = scrollIndicatorTintColor
        return scrollIndicator
    }()
    private var previousBounds = CGRect.zero
    private var menuItemViews = [SJPageMenuItemViewProtocol]()
    
    private func setupViews() {
        if #available(iOS 13.0, *) {
            backgroundColor = .systemGroupedBackground
        } else {
            backgroundColor = .groupTableViewBackground
        }
        
        addSubview(scrollView)
        scrollView.addSubview(scrollIndicator)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(handleTap(_:)))
        scrollView.addGestureRecognizer(tap)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if ( previousBounds.equalTo(bounds) == false ) {
            previousBounds = bounds
            scrollView.frame = bounds
            remakeConstraints()
        }
    }
    
    @objc private func handleTap(_ tap: UITapGestureRecognizer) {
        let location = tap.location(in: scrollView)
        for index in 0..<menuItemViews.count {
            let view = menuItemViews[index]
            if view.frame.contains(.init(x: location.x, y: view.frame.origin.y)) {
                scrollToItem(at: index, animated: true)
                return
            }
        }
    }
    
    @objc private func _reload() {
        menuItemViews.reversed().forEach { (itemView) in
            itemView.removeFromSuperview()
        }
        menuItemViews.removeAll()
        
        if numberOfItems != 0 {
            for index in 0..<numberOfItems {
                if let menuItemView = viewForItem(at: index) {
                    menuItemViews.append(menuItemView)
                    scrollView.addSubview(menuItemView)
                }
            }
        }
        remakeConstraints()
    }
}

private extension SJPageMenuBar {
    func isSafeIndex(_ index: Int) -> Bool {
        return index >= 0 &&
               index < numberOfItems
    }
}
 
private extension SJPageMenuBar {
    func setContentOffsetForScrollViewToIndex(_ index: Int) {
        if let toView = viewForItem(at: index) {
            let half = bounds.size.width * 0.5
            var offset = toView.center.x - half
            
            let minOffset: CGFloat = 0
            var maxOffset: CGFloat = scrollView.contentSize.width - bounds.size.width + contentInsets.left
            if maxOffset < 0 {
                maxOffset = -contentInsets.left
            }
                
            if offset <= minOffset {
                offset = -contentInsets.left
            }
            else if offset >= maxOffset {
                offset = maxOffset
            }
            scrollView.contentSize = .init(width: offset, height: 0)
        }
    }
}


private extension SJPageMenuBar {
    struct ColorValues {
        var red: CGFloat = 0.0;
        var green: CGFloat = 0.0;
        var blue: CGFloat = 0.0;
        var alpha: CGFloat = 0.0;
    }
    
    func setGradientColor(progress: CGFloat, forItemAt index: Int) {
        if focusedItemTintColor.isEqual(itemTintColor) {
            return
        }
        
        var tinCol = ColorValues.init()
        var focTinCol = ColorValues.init()
        itemTintColor.getRed(&tinCol.red, green: &tinCol.green, blue: &tinCol.blue, alpha: &tinCol.alpha)
        focusedItemTintColor.getRed(&focTinCol.red, green: &focTinCol.green, blue: &focTinCol.blue, alpha: &focTinCol.alpha)
        
        let view = menuItemViews[index]
        view.tintColor = .init(red: tinCol.red + (focTinCol.red - tinCol.red) * progress, green: tinCol.green + (focTinCol.green - tinCol.green) * progress, blue: tinCol.blue + (focTinCol.blue - tinCol.blue) * progress, alpha: tinCol.alpha + (focTinCol.alpha - tinCol.alpha) * progress)
    }
    
    func resetTintColorForMenuItemViews() {
        for index in 0..<menuItemViews.count {
            let view = menuItemViews[index]
            view.tintColor = index == focusedIndex ? focusedItemTintColor : itemTintColor
        }
    }
}

private extension SJPageMenuBar {
    
    func remakeConstraints(_ beginIndex: Int = 0) {
        if isSafeIndex(beginIndex) {
            remakeConstraintsForMenuItemViewsWithBeginIndex(beginIndex)
            remakeConstraintsForScrollIndicator()
        }
    }
    
    func remakeConstraintsForMenuItemViewsWithBeginIndex(_ safeIndex: Int) {
        if bounds.size.width == 0 || bounds.size.height == 0 {
            return
        }
        
        let contentLayoutHeight = bounds.height - contentInsets.top - contentInsets.bottom
        let contentLayoutWidth = bounds.width - contentInsets.left - contentInsets.right
        let spacing = distribution == .equalSpacing ? itemSpacing : 0
        for index in safeIndex..<menuItemViews.count {
            let curr = menuItemViews[index]
            let prev = index != 0 ? menuItemViews[index - 1] : nil
            // zoomScale & tintColor
            if focusedIndex == index {
                setZoomScale(maximumZoomScale, forMenuItemViewAt: index)
                curr.tintColor = focusedItemTintColor
            }
            else {
                setZoomScale(minimumZoomScale, forMenuItemViewAt: index)
                curr.tintColor = itemTintColor
            }
            
            // x
            let size = curr.frame.size
            var frame = CGRect.zero
            if let prev = prev  {
                frame.origin.x = prev.frame.maxX + spacing
            }
            else {
                frame.origin.x = 0
            }
            // y
            let centloffset = focusedIndex == index ? 0 : centerlineOffset
            frame.origin.y = (contentLayoutHeight - size.height) * 0.5 + centloffset
            // size
            switch distribution {
            case .equalSpacing:
                frame.size = size
            case .fillEqually:
                frame.size = CGSize.init(width: contentLayoutWidth / CGFloat(numberOfItems), height: size.height)
            }
            curr.frame = frame
        }
        // contentSize
        scrollView.contentSize = CGSize.init(width: menuItemViews.last?.frame.maxX ?? 0, height: bounds.size.height)
    }
    
    func remakeConstraintsForScrollIndicator() {
        if bounds.size.width == 0 || bounds.size.height == 0 {
            return
        }
        
        if menuItemViews.count <= focusedIndex {
            return
        }
        
        var frame = CGRect.zero
        frame.size = scrollIndicatorSize
        frame.origin.y = bounds.height - scrollIndicatorBottomInsets - scrollIndicatorSize.height
        frame.origin.x = menuItemViews[focusedIndex].center.x - frame.size.width * 0.5
        scrollIndicator.frame = frame;
    }
    
    
    func setZoomScale(_ zoomScale: CGFloat, forMenuItemViewAt index: Int) {
        menuItemViews[index].transform = CGAffineTransform.init(scaleX: zoomScale, y: zoomScale)
    }
}

private extension SJPageMenuBar {
    func _scroll(inRange range: NSRange, distaneProgress progress: CGFloat) {
        let left = range.location
        let right = NSMaxRange(range)
        
        if left == right || progress <= 0 {
            scrollToItem(at: left, animated: true)
        }
        else if progress >= 1 {
            scrollToItem(at: right, animated: true)
        }
        else {
            if bounds.size.width == 0 || bounds.size.height == 0 {
                return
            }
            let contentLayoutHeight = bounds.height - contentInsets.top - contentInsets.bottom
            let contentLayoutWidth = bounds.width - contentInsets.left - contentInsets.right
            let zoomScaleLength = maximumZoomScale - minimumZoomScale
            let spacing = distribution == .equalSpacing ? itemSpacing : 0;
            for index in left..<menuItemViews.count {
                let curr = menuItemViews[index]
                let prev = index != 0 ? menuItemViews[index - 1] : nil
                // zoomScale & tintColor
                if index == left {
                    setZoomScale(maximumZoomScale - zoomScaleLength * progress, forMenuItemViewAt: index)
                    setGradientColor(progress: 1 - progress, forItemAt: index)
                }
                else if index == right {
                    setZoomScale(minimumZoomScale + zoomScaleLength * progress, forMenuItemViewAt: index)
                    setGradientColor(progress: progress, forItemAt: index)
                }
                else {
                    setZoomScale(minimumZoomScale, forMenuItemViewAt: index)
                    curr.tintColor = itemTintColor
                }
                
                // x
                let size = curr.frame.size
                var frame = CGRect.zero
                if let prev = prev  {
                    frame.origin.x = prev.frame.maxX + spacing
                }
                else {
                    frame.origin.x = 0
                }
                // y
                var centloffset = centerlineOffset
                if index == left {
                    centloffset = centerlineOffset * progress
                }
                else if index == right {
                    centloffset = (1 - progress) * centerlineOffset;
                }
                frame.origin.y = (contentLayoutHeight - size.height) * 0.5 + centloffset
                // size
                switch distribution {
                case .equalSpacing:
                    frame.size = size
                case .fillEqually:
                    frame.size = CGSize.init(width: contentLayoutWidth / CGFloat(numberOfItems), height: size.height)
                }
                curr.frame = frame
            }
            
            // scroll indicator
            let leftView = menuItemViews[left]
            let rightView = menuItemViews[right]
            let distance = rightView.frame.maxX - leftView.frame.minX
            var currWidth: CGFloat = 0.0
            if progress < 0.5 {
                currWidth = distance * progress + scrollIndicatorSize.width
            }
            else {
                currWidth = (1 - progress) * distance + scrollIndicatorSize.width
            }
            let maxOffset = rightView.center.x - leftView.center.x
            let currOffset = leftView.center.x + maxOffset * progress - currWidth * 0.5
            var frame = scrollIndicator.frame
            frame.size.width = currWidth
            frame.origin.x = currOffset
            scrollIndicator.frame = frame
            
            // contentSize
            scrollView.contentSize = .init(width: menuItemViews.last?.frame.maxX ?? 0, height: bounds.size.height)
        }
    }
}

private class SJPageMenuBarScrollIndicator: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.height * 0.5
    }
}


extension SJPageMenuBarDelegate {
    func pageMenuBar(_ bar: SJPageMenuBar, focusedIndexDidChange index: Int) {
        
    }
}
