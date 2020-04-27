//
//  SJPageMenuBar.swift
//  Pods-SJPageViewControllerswift_Example
//
//  Created by BlueDancer on 2020/2/28.
//

import UIKit
 
public protocol SJPageMenuBarDelegate: NSObjectProtocol {
    func pageMenuBar(_ bar: SJPageMenuBar, focusedIndexDidChange index: Int)
}

public protocol SJPageMenuBarGestureHandlerProtocol {
    var singleTapHandler: ((SJPageMenuBar, CGPoint) -> ())? { get set }
}

open class SJPageMenuBar: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    open var itemViews: [SJPageMenuItemView]? {
        didSet {
            if let old = oldValue {
                old.forEach { $0.removeFromSuperview() }
            }
            
            if let new = itemViews {
                new.forEach({
                    $0.sizeToFit()
                    self.scrollView.addSubview($0)
                })
                self.focusedIndex = new.count == 0 ? NSNotFound : 0
            }
            remakeConstraints()
        }
    }
    
    open func viewForItem(at index: Int) -> SJPageMenuItemViewProtocol? {
        if isSafeIndex(index) {
            return itemViews![index]
        }
        return nil
    }
    
    open func reloadItem(at index: Int, animated: Bool) {
        if let view = viewForItem(at: index) {
            UIView.animate(withDuration: animated ? 0.25 : 0.0) {
                view.sizeToFit()
                self.remakeConstraintsForMenuItemViewsWithBeginIndex(index)
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
                self.remakeConstraints(previousIdx < index ? previousIdx : index)
                self.remakeConstraintsForScrollIndicator()
                self.setContentOffsetForScrollViewToIndex(index)
            })
        }
    }

    open func scroll(inRange range: NSRange, distanceProgress progress: CGFloat) {
        if isSafeIndex(range.location) && isSafeIndex(NSMaxRange(range)) {
            _scroll(inRange: range, distanceProgress: progress)
        }
    }

    
    open weak var delegate: SJPageMenuBarDelegate?
    open lazy var gestureHandler: SJPageMenuBarGestureHandlerProtocol = {
       var handler = SJPageMenuBarGestureHandler()
        handler.singleTapHandler = { (bar, location) in
            if let itemViews = bar.itemViews {
                for index in 0..<itemViews.count {
                    let view = itemViews[index]
                    if view.frame.contains(.init(x: location.x, y: view.frame.origin.y)) {
                        bar.scrollToItem(at: index, animated: true)
                        return
                    }
                }
            }
        }
        return handler
    }()
    
    open private(set) var focusedIndex: Int = 0 {
        didSet {
            if let views = itemViews {
                for index in 0..<views.count {
                    views[index].isFocusedMenuItem = focusedIndex == index
                }
            }
            
            if focusedIndex != NSNotFound {
                self.delegate?.pageMenuBar(self, focusedIndexDidChange: focusedIndex)
            }
        }
    }
    open var numberOfItems: Int {
        return itemViews?.count ?? 0
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
    
    open var scrollIndicatorLayoutMode = ScrollIndicatorLayoutMode.specifiedWidth {
        didSet {
            remakeConstraintsForScrollIndicator()
        }
    }

    open var scrollIndicatorSize = CGSize.init(width: 12, height: 2) {
        didSet {
            if oldValue.equalTo(scrollIndicatorSize) {
                remakeConstraintsForScrollIndicator()
            }
        }
    }
    
    /// scrollIndicator.size = scrollIndicatorSize + scrollIndicatorExpansionSize
    open var scrollIndicatorExpansionSize = CGSize.zero

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
    
    public enum ScrollIndicatorLayoutMode {
        case specifiedWidth
        ///
        /// itemView内容大小
        ///
        case equalItemViewContentWidth
        ///
        /// itemView布局显示时的大小
        ///
        case equalItemViewLayoutWidth
    }
    
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
            setContentOffsetForScrollViewToIndex(focusedIndex)
        }
    }
    
    @objc private func handleTap(_ tap: UITapGestureRecognizer) {
        let location = tap.location(in: scrollView)
        if let handler = self.gestureHandler.singleTapHandler {
            handler(self, location)
        }
    }
}

private extension SJPageMenuBar {
    func isSafeIndex(_ index: Int) -> Bool {
        return index >= 0 &&
               index < numberOfItems
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
        remakeConstraintsForMenuItemViewsWithBeginIndex(safeIndex, zoomScale: {
            return $0 == focusedIndex ? maximumZoomScale : minimumZoomScale
        }, transitionProgress: {
            return $0 == focusedIndex ? 1 : 0;
        }, tintColor: {
            return $0 == focusedIndex ? focusedItemTintColor : itemTintColor
        }, centerlineOffset: {
            return $0 == focusedIndex ? 0 : centerlineOffset
        })
    }
    
    func remakeConstraintsForScrollIndicator() {
        if bounds.size.width == 0 || bounds.size.height == 0 {
            return
        }
        guard let view = viewForItem(at: focusedIndex) else { return }
        var frame = CGRect.zero
        frame.size = sizeForScrollIndicator(at: focusedIndex)
        frame.origin.y = bounds.height - scrollIndicatorBottomInsets - scrollIndicatorSize.height
        frame.origin.x = view.center.x - frame.size.width * 0.5
        scrollIndicator.frame = frame;
    }
    
    func _scroll(inRange range: NSRange, distanceProgress progress: CGFloat) {
        let left = range.location
        let right = NSMaxRange(range)
        
        if left == right || progress <= 0 {
            scrollToItem(at: left, animated: true)
        }
        else if progress >= 1 {
            scrollToItem(at: right, animated: true)
        }
        else {
            remakeConstraintsForMenuItemViewsWithBeginIndex(left, zoomScale: {
                let length = maximumZoomScale - minimumZoomScale
                if      $0 == left {
                    return maximumZoomScale - length * progress
                }
                else if $0 == right {
                    return minimumZoomScale + length * progress
                }
                return minimumZoomScale
            }, transitionProgress: {
                if      ( $0 == left ) {
                    return 1 - progress;
                }
                else if ( $0 == right ) {
                    return progress;
                }
                return 0;
            }, tintColor: {
                if      $0 == left {
                    return graidentColor(progress: 1 - progress)
                }
                else if $0 == right {
                    return graidentColor(progress: progress)
                }
                return itemTintColor
            }, centerlineOffset: {
                if $0 == left {
                    return centerlineOffset * progress
                }
                else if $0 == right {
                    return centerlineOffset * (1 - progress)
                }
                return centerlineOffset
            })
            
            guard let leftView = viewForItem(at: left) else { return }
            guard let rightView = viewForItem(at: right) else { return }
            
            let leftSize = sizeForScrollIndicator(at: left)
            let rightSize = sizeForScrollIndicator(at: right)
            let factor = 1 - abs(rightSize.width - leftSize.width) / max(rightSize.width, leftSize.width)
            let distance = (rightView.frame.maxX - leftView.frame.minX) * factor
            var indicatorWidth: CGFloat = 0
            // A + (B - A) = B
            // 小于 0.5 开始变长
            if ( progress < 0.5 ) {
                indicatorWidth = leftSize.width * ( 1 - progress ) + rightSize.width * progress + distance * progress
            }
            // 超过 0.5 开始缩小
            else {
                indicatorWidth = leftSize.width * ( 1 - progress ) + rightSize.width * progress + distance * ( 1 - progress)
            }
            let maxOffset = rightView.center.x - leftView.center.x
            let currOffset = leftView.center.x + maxOffset * progress - indicatorWidth * 0.5;
            var frame = scrollIndicator.frame
            frame.size.width = indicatorWidth;
            frame.origin.x = currOffset;
            scrollIndicator.frame = frame;
        }
    }

    func remakeConstraintsForMenuItemViewsWithBeginIndex(_ safeIndex: Int, zoomScale: (Int) -> CGFloat, transitionProgress: (Int) -> CGFloat, tintColor: (Int) -> UIColor, centerlineOffset: (Int) -> CGFloat) {
        if bounds.size.width == 0 || bounds.size.height == 0 {
            return
        }
        
        let contentLayoutHeight = bounds.size.height - contentInsets.top - contentInsets.bottom
        let contentLayoutWidth = bounds.size.width - contentInsets.top - contentInsets.bottom
        let itemWidth = contentLayoutWidth / CGFloat(numberOfItems)
        let spacing = distribution == .equalSpacing ? itemSpacing : 0
        
        var prev: SJPageMenuItemViewProtocol? = viewForItem(at: safeIndex - 1)
        
        for index in safeIndex..<numberOfItems {
            guard let curr = viewForItem(at: index) else {
                return
            }
            
            // zoomScale
            let scale = zoomScale(index)
            setZoomScale(scale, forMenuItemViewAt: index)
            
            // transitionProgress
            curr.transitionProgress = transitionProgress(index)
            
            // tintColor
            let color = tintColor(index)
            curr.tintColor = color
            
            // bounds
            var bounds = curr.bounds
            switch distribution {
            case .equalSpacing:
                break
            case .fillEqually:
                bounds.size.width = itemWidth * 1.0 / scale
            }
            curr.bounds = bounds
            
            // center
            var center = CGPoint.zero
            // center.x
            center.x = bounds.size.width * 0.5 * scale
            if let prev = prev {
                let prez = prev.sj_pageZoomScale
                center.x += prev.center.x + prev.bounds.width * 0.5 * prez + spacing
            }
            // center.y
            center.y = contentLayoutHeight * 0.5 + centerlineOffset(index)
            curr.center = center
            
            prev = curr
        }
        
        scrollView.contentSize = .init(width: itemViews?.last?.frame.maxX ?? 0, height: bounds.size.height)
    }
    
    func setContentOffsetForScrollViewToIndex(_ index: Int) {
        if distribution == .fillEqually {
            return
        }
        if let toView = viewForItem(at: index) {
            let size = frame.size.width
            let middle = size * 0.5
            let min = middle
            let max = scrollView.contentSize.width - middle + contentInsets.left + contentInsets.right
            var centerX = toView.center.x
            if      centerX < min || max < middle {
                centerX = -contentInsets.left
            }
            else if centerX > max {
                centerX = scrollView.contentSize.width - size + contentInsets.right
            }
            else {
                centerX -= middle
            }
            scrollView.contentOffset = .init(x: centerX, y: 0)
        }
    }

    func setZoomScale(_ zoomScale: CGFloat, forMenuItemViewAt index: Int) {
        if let view = viewForItem(at: index) {
            view.sj_pageZoomScale = zoomScale
            view.transform = CGAffineTransform.init(scaleX: zoomScale, y: zoomScale)
        }
    }
    
    func sizeForScrollIndicator(at index: Int) -> CGSize {
        var size = CGSize.zero
        if let view = viewForItem(at: index) {
            switch scrollIndicatorLayoutMode {
            case .specifiedWidth:
                size = scrollIndicatorSize
            case .equalItemViewContentWidth:
                size = CGSize.init(width: view.sizeThatFits(CGSize.init(width: 1000, height: 1000)).width, height: scrollIndicatorSize.height)
            case .equalItemViewLayoutWidth:
                size = CGSize.init(width: view.bounds.size.width, height: scrollIndicatorSize.height)
            }
        }
        size.width += scrollIndicatorExpansionSize.width;
        size.height += scrollIndicatorExpansionSize.height;
        return size
    }
}


private extension SJPageMenuBar {
    struct ColorValues {
        var red: CGFloat = 0.0;
        var green: CGFloat = 0.0;
        var blue: CGFloat = 0.0;
        var alpha: CGFloat = 0.0;
    }
    
    func graidentColor(progress: CGFloat) -> UIColor {
        if focusedItemTintColor.isEqual(itemTintColor) {
            return itemTintColor
        }
        
        var tinCol = ColorValues.init()
        var focTinCol = ColorValues.init()
        itemTintColor.getRed(&tinCol.red, green: &tinCol.green, blue: &tinCol.blue, alpha: &tinCol.alpha)
        focusedItemTintColor.getRed(&focTinCol.red, green: &focTinCol.green, blue: &focTinCol.blue, alpha: &focTinCol.alpha)

        return .init(red: tinCol.red + (focTinCol.red - tinCol.red) * progress, green: tinCol.green + (focTinCol.green - tinCol.green) * progress, blue: tinCol.blue + (focTinCol.blue - tinCol.blue) * progress, alpha: tinCol.alpha + (focTinCol.alpha - tinCol.alpha) * progress)
    }
    
    func resetTintColorForMenuItemViews() {
        if let itemViews = itemViews {
            for index in 0..<itemViews.count {
                let view = itemViews[index]
                view.tintColor = index == focusedIndex ? focusedItemTintColor : itemTintColor
            }
        }
    }
}
 
private class SJPageMenuBarScrollIndicator: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.height * 0.5
    }
}

private class SJPageMenuBarGestureHandler: SJPageMenuBarGestureHandlerProtocol {
    var singleTapHandler: ((SJPageMenuBar, CGPoint) -> ())?
}

private var kPageZoomScale = "PageZoomScale";

fileprivate extension UIView {
     var sj_pageZoomScale: CGFloat {
        set { objc_setAssociatedObject(self, &kPageZoomScale, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
        get { return objc_getAssociatedObject(self, &kPageZoomScale) as? CGFloat ?? 0.0 }
    }
}


extension SJPageMenuBarDelegate {
    func pageMenuBar(_ bar: SJPageMenuBar, focusedIndexDidChange index: Int) {
        
    }
}
