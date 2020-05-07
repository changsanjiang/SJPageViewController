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

public protocol SJPageMenuBarScrollIndicatorProtocol: UIView {
    
}

open class SJPageMenuBar: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open weak var delegate: SJPageMenuBarDelegate?
    
    // MARK: -
    
    open private(set) var focusedIndex: Int = 0 {
        didSet {
            if ( focusedIndex != oldValue ) {
                itemViews?.sj_forEach({ (index, view, _) in
                    view.isFocusedMenuItem = focusedIndex == index
                })
                
                delegate?.pageMenuBar(self, focusedIndexDidChange: focusedIndex)
            }
        }
    }

    // MARK: -

    open func scrollToItem(at index: Int, animated: Bool) {
        if isSafeIndex(index) && focusedIndex != index {
            let previousIdx = focusedIndex
            perform(animated: animated, actions: {
                self.remakeConstraints(min(previousIdx, index), index)
                self.setContentOffsetForScrollViewToIndex(index)
                self.focusedIndex = index
            })
        }
    }

    open func scroll(inRange range: NSRange, distanceProgress progress: CGFloat) {
        if isSafeIndex(range.location) && isSafeIndex(NSMaxRange(range)) {
            _scroll(inRange: range, distanceProgress: progress)
        }
    }
    
    // MARK: -

    private var itemViews: [SJPageMenuItemViewProtocol]?

    open func setItemViews(_ views: [SJPageMenuItemViewProtocol]?) {
        itemViews?.forEach { $0.removeFromSuperview() }
        itemViews = views != nil ? Array(views!) : nil
        itemViews?.forEach {
            scrollView.addSubview($0)
            $0.sizeToFit()
        }
        
        let focusedIndex = itemViews?.count == 0 ? NSNotFound : 0
        remakeConstraints(0, focusedIndex)
        self.focusedIndex = focusedIndex
    }
    
    open func viewForItem(at index: Int) -> SJPageMenuItemViewProtocol? {
        return isSafeIndex(index) ? itemViews?[index] : nil
    }
    
    open var numberOfItems: Int {
        return itemViews?.count ?? 0
    }

    // MARK: -
     
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
            remakeConstraintsForScrollIndicator(focusedIndex)
        }
    }

    open var scrollIndicatorSize = CGSize.init(width: 12, height: 2) {
        didSet {
            remakeConstraintsForScrollIndicator(focusedIndex)
        }
    }
    
    /// scrollIndicator.size = scrollIndicatorSize + scrollIndicatorExpansionSize
    open var scrollIndicatorExpansionSize = CGSize.zero {
        didSet {
            remakeConstraintsForScrollIndicator(focusedIndex)
        }
    }

    open var scrollIndicatorBottomInsets: CGFloat = 3.0 {
        didSet {
            remakeConstraintsForScrollIndicator(focusedIndex)
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
    
    open var gestureHandler: SJPageMenuBarGestureHandlerProtocol = {
        var handler = SJPageMenuBarGestureHandler()
        handler.singleTapHandler = { (bar, location) in
            bar.itemViews?.sj_forEach({ (index, view, stop) in
                if view.frame.contains(.init(x: location.x, y: view.frame.origin.y)) {
                    bar.scrollToItem(at: index, animated: true)
                    stop = true
                }
            })
        }
        return handler
    }()
    
    open var scrollIndicator: SJPageMenuBarScrollIndicatorProtocol {
        set { _scrollIndicator = newValue }
        get { return _scrollIndicator }
    }
    
    /// enable fade in on the left. default is `NO`.
    open var isEnabledFadeIn: Bool = false {
        didSet {
            if ( oldValue != isEnabledFadeIn ) {
                resetFadeMask()
            }
        }
    }
    
    /// enable fade out on the right. default is `NO`.
    open var isEnabledFadeOut: Bool = false {
        didSet {
            if ( oldValue != isEnabledFadeOut ) {
                resetFadeMask()
            }
        }
    }
    
    // MARK: -

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

    private lazy var _scrollIndicator: SJPageMenuBarScrollIndicatorProtocol = {
        var scrollIndicator = SJPageMenuBarScrollIndicator.init(frame: .zero)
        scrollIndicator.backgroundColor = scrollIndicatorTintColor
        return scrollIndicator
    }()
    
    private var previousBounds = CGRect.zero
    
    private var fadeMaskLayer: CAGradientLayer?
    
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
            resetFadeMask()
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


public extension SJPageMenuBar {
    func insertItem(at index: Int, view newView: UIView & SJPageMenuItemViewProtocol, animated: Bool) {
        if ( isSafeIndex(index) || index == self.numberOfItems ) {
            if ( itemViews == nil ) { itemViews = Array() }
            itemViews?.insert(newView, at: index)
            scrollView.insertSubview(newView, at: index)
            newView.sizeToFit()
            
            let preView = viewForItem(at: index - 1)
            var frame = newView.frame
            frame.origin.x = preView?.frame.maxX ?? 0 - frame.size.width
            frame.origin.y = (scrollView.bounds.height - frame.height) * 0.5
            
            newView.frame = frame
            newView.alpha = 0.001
            
            perform(animated: animated) {
                newView.alpha = 1
                let focusedIndex = self.fixedFocusedIndex()
                self.remakeConstraints(index, focusedIndex)
                self.focusedIndex = focusedIndex
            }
        }
    }

    func deleteItem(at index: Int, animated: Bool) {
        if let view = viewForItem(at: index) {
            perform(animated: animated, actions: {
                view.alpha = 0.001
                self.itemViews?.remove(at: index)
                
                let focusedIndex = self.fixedFocusedIndex()
                self.remakeConstraints(index != 0 ? (index - 1) : 0, focusedIndex)
                self.remakeConstraintsForScrollIndicator(focusedIndex)
                self.focusedIndex = focusedIndex
            }) { (_) in
                view.removeFromSuperview()
                view.alpha = 1
            }
        }
    }

    func reloadItem(at index: Int, animated: Bool) {
        if let view = viewForItem(at: index) {
            perform(animated: animated) {
                view.sizeToFit()
                self.remakeConstraints(index, self.focusedIndex)
            }
        }
    }
    
    func moveItem(at index: Int, to newIndex: Int, animated: Bool) {
        if ( index == newIndex ) { return }
        if ( isSafeIndex(index) && isSafeIndex(newIndex) ) {
            perform(animated: animated) {
                self.itemViews?.swapAt(index, newIndex)
                var focusedIndex = self.focusedIndex
                if      ( index == self.focusedIndex ) {
                    focusedIndex = newIndex
                }
                else if ( newIndex == self.focusedIndex ) {
                    focusedIndex = index
                }
                self.remakeConstraints(min(index, newIndex), focusedIndex)
                self.focusedIndex = focusedIndex
            }
        }
    }
}


private extension SJPageMenuBar {
    func isSafeIndex(_ index: Int) -> Bool {
        return index >= 0 &&
               index < numberOfItems
    }
    
    func fixedFocusedIndex() -> Int {
        if ( numberOfItems == 0 ) {
            return NSNotFound;
        }
        else if ( focusedIndex >= numberOfItems ) {
            return numberOfItems - 1
        }
        return focusedIndex
    }
}

private extension SJPageMenuBar {
    
    func remakeConstraints() {
        remakeConstraints(0, focusedIndex)
    }
    
    func remakeConstraints(_ beginIndex: Int, _ focusedIndex: Int) {
        if self.bounds.size.width == 0 || self.bounds.size.height == 0 {
            return
        }
        if isSafeIndex(beginIndex) {
            remakeConstraintsForMenuItemViewsWithBeginIndex(beginIndex, focusedIndex)
            remakeConstraintsForScrollIndicator(focusedIndex)
        }
    }
    
    func remakeConstraintsForMenuItemViewsWithBeginIndex(_ safeIndex: Int, _ focusedIndex: Int) {
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
    
    func remakeConstraintsForScrollIndicator(_ focusedIndex: Int) {
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
                    return gradientColor(progress: 1 - progress)
                }
                else if $0 == right {
                    return gradientColor(progress: progress)
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
        if ( self.numberOfItems == 0 ) { return .zero }
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
    
    func gradientColor(progress: CGFloat) -> UIColor {
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
        itemViews?.sj_forEach { (index, view, _) in
            view.tintColor = index == focusedIndex ? focusedItemTintColor : itemTintColor
        }
    }
}

private extension SJPageMenuBar {
    func perform(animated: Bool, actions: @escaping (() -> Void)) {
        perform(animated: animated, actions: actions, completion: nil)
    }
    
    func perform(animated: Bool, actions: @escaping (() -> Void), completion: ((Bool) -> Void)?) {
        animated ? UIView.animate(withDuration: 0.25, animations: actions, completion: completion) : actions();
    }
}
 

private extension SJPageMenuBar {
    func resetFadeMask() {
        if ( isEnabledFadeIn || isEnabledFadeOut ) {
            if ( bounds.size.width == 0 ) { return; }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
  
            if ( fadeMaskLayer == nil ) {
                fadeMaskLayer = CAGradientLayer()
                fadeMaskLayer?.startPoint = .zero
                fadeMaskLayer?.endPoint = .init(x: 1, y: 0)
                fadeMaskLayer?.frame = bounds
            }
            
            let width: CGFloat = 16.0
            let widthCenti = width / bounds.size.width
            
            var locations = Array<NSNumber>()
            var colors = Array<CGColor>()
            if ( isEnabledFadeIn ) {
                locations.append(NSNumber(value: Float(0)))
                locations.append(NSNumber(value: Float(widthCenti)))

                colors.append(UIColor.clear.cgColor)
                colors.append(UIColor.white.cgColor)
                
                locations.append(locations.last!)
                locations.append(NSNumber(value: Float(1 - widthCenti)))

                colors.append(UIColor.white.cgColor)
                colors.append(UIColor.white.cgColor)
            }
            
            if ( isEnabledFadeOut ) {
                if ( !isEnabledFadeIn ) {
                    locations.append(NSNumber(value: Float(0)))
                    locations.append(NSNumber(value: Float(1 - widthCenti)))

                    colors.append(UIColor.white.cgColor)
                    colors.append(UIColor.white.cgColor)
                }
                
                locations.append(locations.last!)
                locations.append(NSNumber(value: Float(1.0)))

                colors.append(UIColor.white.cgColor)
                colors.append(UIColor.clear.cgColor)
            }
            
            fadeMaskLayer?.locations = locations
            fadeMaskLayer?.colors = colors
            fadeMaskLayer?.frame = bounds
            CATransaction.commit()
            
            if ( self.layer.mask != fadeMaskLayer ) { self.layer.mask = fadeMaskLayer }
        }
        else if fadeMaskLayer != nil {
            self.layer.mask = nil
            fadeMaskLayer = nil
        }
    }
}

private class SJPageMenuBarScrollIndicator: UIView, SJPageMenuBarScrollIndicatorProtocol {
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

fileprivate extension Array {
    func sj_forEach(_ body: (Int, Element, inout Bool) throws -> Void) rethrows {
        var stop = false
        for index in 0..<count {
            if ( stop ) { break }
            try body(index, self[index], &stop)
        }
    }
}

extension SJPageMenuBarDelegate {
    func pageMenuBar(_ bar: SJPageMenuBar, focusedIndexDidChange index: Int) {
        
    }
}
