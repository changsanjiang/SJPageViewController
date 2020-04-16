//
//  SJPageViewController.swift
//  SJPageViewControllerswift_Example
//
//  Created by BlueDancer on 2020/2/8.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

private var kContentOffset = "contentOffset";
private var kState = "state";
private var kBounds = "bounds"
private var kReuseIdentifierForCell = "1"

open class SJPageViewController: UIViewController {
    
    open class func pageViewController(options: [SJPageViewController.OptionsKey : Any]? = nil) -> SJPageViewController {
        return SJPageViewController.init(options: options)
    }
    
    public init(options: [SJPageViewController.OptionsKey : Any]? = nil, dataSource: SJPageViewControllerDataSource? = nil, delegate: SJPageViewControllerDelegate? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.edgesForExtendedLayout = UIRectEdge()
        self.options = options
        self.dataSource = dataSource
        self.delegate = delegate
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open weak var dataSource: SJPageViewControllerDataSource? {
        didSet {
            self.reload()
        }
    }
    
    open weak var delegate: SJPageViewControllerDelegate?
    
    open func reload() {
        if self.isViewLoaded {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_reload), object: nil)
            self.perform(#selector(_reload), with: nil, afterDelay: 0, inModes: [.common])
        }
    }
    
    open func setViewController(at index: Int) {
        if isSafeIndex(index) {
            UIView.performWithoutAnimation {
                if collectionView.bounds.width != 0 {
                    let offset = CGFloat(index) * collectionView.bounds.size.width
                    collectionView.setContentOffset(.init(x: offset, y: 0), animated: false)
                }
            }
            self.focusedIndex = index
        }
    }
    
    open func viewController(at index: Int) -> UIViewController? {
        if isSafeIndex(index) {
            var vc = self.viewControllers[index]
            if vc == nil {
                vc = self.dataSource?.pageViewController(self, viewControllerAt: index)
                assert(vc != nil, "The view controller can't be nil!")
                self.viewControllers[index] = vc
            }
            return vc
        }
        return nil
    }
    
    open func isViewControllerVisible(at index: Int) -> Bool {
        if isSafeIndex(index) {
            if index == self.focusedIndex {
                return true
            }
            
            for indexPath in self.collectionView.indexPathsForVisibleItems {
                if indexPath.item == index {
                    return true
                }
            }
        }
        return false
    }
    
    open var numberOfViewControllers: Int {
        return self.dataSource?.numberOfViewControllers(in: self) ?? 0
    }
    
    open private(set) var focusedIndex = NSNotFound {
        didSet {
            if focusedIndex != NSNotFound {
                self.delegate?.pageViewController(self, focusedIndexDidChange: focusedIndex)
            }
        }
    }
    open var minimumBottomInsetForChildScrollView: CGFloat = 0
    open var bounces = true {
        didSet {
            self.collectionView.bounces = bounces
        }
    }
    
    open private(set) var headerView: UIView?
    open private(set) var heightForHeaderBounds: CGFloat = 0.0 {
        didSet {
            if let scrollView = self.focusedViewController?.sj_lookupScrollView() {
                setupContentInset(for: scrollView)
            }
        }
    }
    open var heightForHeaderPinToVisibleBounds: CGFloat {
        return self.dataSource?.heightForHeaderPinToVisibleBounds(with: self) ?? 0
    }
    
    open var focusedViewController: UIViewController? {
        return self.viewController(at: self.focusedIndex)
    }
    
    open var cachedViewControllers: [UIViewController]? {
        return self.viewControllers.values.reversed()
    }
    
    open var panGestureRecognizer: UIPanGestureRecognizer {
        return self.collectionView.panGestureRecognizer
    }
    
    @objc public enum HeaderMode: Int {
        case tracking
        case pinnedToTop
        case scaleAspectFill
    }
    
    public struct OptionsKey : Hashable, Equatable, RawRepresentable {
        /// rawValue
        public private(set) var rawValue: String
        /// init
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    deinit {
        cleanPageItems()
    }
    
    private var isDataSourceLoaded = false
    private var options: [SJPageViewController.OptionsKey : Any]?
    private var viewControllers = [Int : UIViewController]()
    private var currentVisibleViewController: UIViewController? {
        return (self.collectionView.visibleCells.last as? SJPageCollectionViewCell)?.viewController
    }
    private lazy var collectionView: SJPageCollectionView = {
        var spacing: CGFloat = self.interPageSpacing
        var layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = 0
        var collectionView = SJPageCollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: spacing)
        collectionView.bounces = bounces
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.register(SJPageCollectionViewCell.self, forCellWithReuseIdentifier: kReuseIdentifierForCell)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    private var previousOffset: CGFloat = 0
    private var hasHeader = false
    private var heightForIntersectionBounds: CGFloat {
        let frame = convertHeaderViewFrame(to: self.view)
        let intersection = self.view.bounds.intersection(frame)
        return intersection.isEmpty || intersection.isNull ? 0 : intersection.height
    }
    private var modeForHeader: SJPageViewController.HeaderMode {
        return self.dataSource?.modeForHeader(with: self) ?? .tracking
    }
    private var interPageSpacing: CGFloat {
        return options?[SJPageViewController.OptionsKey.interPageSpacing] as? CGFloat ?? 0
    }
    private var previousBounds: CGRect = .zero
    private var boundsObservation: NSKeyValueObservation?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        _setupViews()
        if self.dataSource != nil {
            reload()
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setViewController(at: focusedIndex)
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if previousBounds.equalTo(self.view.bounds) == false {
            previousBounds = self.view.bounds
            remakeConstraints()
        }
    }
    
    open override func willMove(toParent parent: UIViewController?) {
        parent?.edgesForExtendedLayout = UIRectEdge()
        super.willMove(toParent: parent)
    }
    
    private func _setupViews() {
        view.clipsToBounds = true
        view.addSubview(collectionView)
    }
    
    @objc private func _reload() {
        isDataSourceLoaded = true
        if headerView != nil {
            headerView?.removeFromSuperview()
            headerView = nil
            hasHeader = false
            boundsObservation = nil
        }
        
        cleanPageItems()
        viewControllers.removeAll()
        collectionView.reloadData()
        
        if numberOfViewControllers != 0 {
            // header view
            headerView = dataSource?.viewForHeader(in: self)
            hasHeader = headerView != nil
            if let headerView = headerView {
                heightForHeaderBounds = headerView.bounds.height
                boundsObservation = headerView.observe(\.bounds, changeHandler: { [weak self] (headerView, _) in
                    guard let self = self else { return }
                    self.heightForHeaderBounds = headerView.bounds.height
                })
            }
    
            // set view controller
            var index = focusedIndex
            if index == NSNotFound {
                index = 0
            }
            else if index >= numberOfViewControllers {
                index = numberOfViewControllers - 1
            }
            setViewController(at: index)
        }
    }
     
    private func cleanPageItems() {
        for vc in self.viewControllers.values {
            if let item = vc.sj_pageItem {
                item.scrollView?.panGestureRecognizer.removeObserver(self, forKeyPath: kState, context: &kState)
                item.scrollView?.removeObserver(self, forKeyPath: kContentOffset, context: &kContentOffset)
                vc.sj_pageItem = nil
            }
        }
    }
    
    private func remakeConstraints() {
        let bounds = view.bounds
        if let headerView = headerView {
            var frame = headerView.frame
            frame.size.width = bounds.width
            headerView.frame = frame
        }
        let width: CGFloat = bounds.width + interPageSpacing
        collectionView.frame = CGRect.init(x: 0, y: 0, width: width, height: bounds.height)
        setViewController(at: focusedIndex)
    }
}


private extension SJPageViewController {
    func isSafeIndex(_ index: Int) -> Bool {
        return index >= 0 && index < numberOfViewControllers
    }
    
    func convertHeaderViewFrame(to view: UIView?) -> CGRect {
        if let headerView = headerView, let superview = headerView.superview, let view = view {
            return superview.convert(headerView.frame, to: view)
        }
        return .zero
    }
    
    func removePageChildViewController(_ childController: UIViewController?) {
        if let childController = childController {
            childController.willMove(toParent: nil)
            childController.view.removeFromSuperview()
            childController.removeFromParent()
            childController.didMove(toParent: nil)
        }
    }
}


public extension SJPageViewController.OptionsKey {
    static let interPageSpacing = SJPageViewController.OptionsKey.init(rawValue: "SJPageViewControllerOptionInterPageSpacingKey")
}

public protocol SJPageViewControllerDataSource : NSObjectProtocol {
    func numberOfViewControllers(in pageViewController: SJPageViewController) -> Int
    func pageViewController(_ pageViewController: SJPageViewController, viewControllerAt index: Int) -> UIViewController
    
    func viewForHeader(in pageViewController: SJPageViewController) -> UIView?
    func heightForHeaderPinToVisibleBounds(with pageViewController: SJPageViewController) -> CGFloat
    func modeForHeader(with pageViewController: SJPageViewController) -> SJPageViewController.HeaderMode
}
 
public protocol SJPageViewControllerDelegate : NSObjectProtocol {
    func pageViewController(_ pageViewController: SJPageViewController, headerViewVisibleRectDidChange visibleRect: CGRect)
    func pageViewController(_ pageViewController: SJPageViewController, didScrollIn range: NSRange, distanceProgress progress: CGFloat)

    func pageViewController(_ pageViewController: SJPageViewController, focusedIndexDidChange index: Int)
    
    func pageViewController(_ pageViewController: SJPageViewController, willDisplay viewController: UIViewController?, at index: Int)
    func pageViewController(_ pageViewController: SJPageViewController, didEndDisplaying viewController: UIViewController?, at index: Int)
}

public extension SJPageViewControllerDataSource {
    func viewForHeader(in pageViewController: SJPageViewController) -> UIView? {
        return nil
    } 
    func heightForHeaderPinToVisibleBounds(with pageViewController: SJPageViewController) -> CGFloat {
        return 0
    }
    func modeForHeader(with pageViewController: SJPageViewController) -> SJPageViewController.HeaderMode {
        return .tracking
    }
}

public extension SJPageViewControllerDelegate {
    func pageViewController(_ pageViewController: SJPageViewController, headerViewVisibleRectDidChange visibleRect: CGRect) {}
    func pageViewController(_ pageViewController: SJPageViewController, didScrollIn range: NSRange, distanceProgress progress: CGFloat) {}

    func pageViewController(_ pageViewController: SJPageViewController, focusedIndexDidChange index: Int) {}
    
    func pageViewController(_ pageViewController: SJPageViewController, willDisplay viewController: UIViewController?, at index: Int) {}
    func pageViewController(_ pageViewController: SJPageViewController, didEndDisplaying viewController: UIViewController?, at index: Int) {}
}

extension SJPageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isDataSourceLoaded ? self.numberOfViewControllers : 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: kReuseIdentifierForCell, for: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.view.bounds.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let pageCell = cell as! SJPageCollectionViewCell
        let oldViewController = pageCell.viewController
        let newViewController = self.viewController(at: indexPath.item)
        pageCell.viewController = newViewController
        
        if oldViewController != newViewController {
            if oldViewController?.view.superview == pageCell.contentView {
                removePageChildViewController(oldViewController)
            }
            
            if let newViewController = newViewController {
                self.addChild(newViewController)
                let bounds = pageCell.bounds
                newViewController.view.frame = bounds
                pageCell.contentView.addSubview(newViewController.view)
                
                if hasHeader {
                    guard let childScrollView = newViewController.sj_lookupScrollView() else {
                        assertionFailure("The scrollView can't be nil!")
                        return
                    }
                    var pageItem = newViewController.sj_pageItem
                    if pageItem == nil {
                        pageItem = SJPageItem.init()
                        pageItem?.scrollView = childScrollView
                        newViewController.sj_pageItem = pageItem
                        
                        // pageItem 为空, 则为首次出现
                        //      - 需修正 childScrollView 的 scrollIndicatorInsets & contentInset & contentOffset
                        //      - 是否需要添加 headerView 到 第一个显示的 childScrollView 中
                        //      - kvo contentOffset
                        childScrollView.frame = bounds
                        if #available(iOS 13.0, *) {
                            childScrollView.automaticallyAdjustsScrollIndicatorInsets = false
                        }
                        if #available(iOS 11.0, *) {
                            childScrollView.contentInsetAdjustmentBehavior = .never
                        }
                        
                        if let headerView = headerView, headerView.superview == nil {
                            headerView.frame = CGRect.init(x: 0, y: -heightForHeaderBounds, width: bounds.width, height: heightForHeaderBounds)
                            childScrollView.addSubview(headerView)
                        }
                        setupContentInset(for: childScrollView)
                        childScrollView.scrollIndicatorInsets = UIEdgeInsets.init(top: heightForHeaderBounds, left: 0, bottom: 0, right: 0)
                        childScrollView.setContentOffset(CGPoint.init(x: 0, y: -heightForHeaderBounds), animated: false)
                        childScrollView.panGestureRecognizer.addObserver(self, forKeyPath: kState, options: .new, context: &kState)
                        childScrollView.addObserver(self, forKeyPath: kContentOffset, options: [.new, .old], context: &kContentOffset)
                    }
                    else {
                        setupContentInset(for: childScrollView)
                    }
                    
                    if let pageItem = pageItem, let scrollView = pageItem.scrollView, scrollView.sj_locked == false {
                        let intersection = self.heightForIntersectionBounds
                        var contentOffset = pageItem.contentOffset
                        contentOffset.y += pageItem.intersection - intersection
                        if scrollView.contentOffset.equalTo(contentOffset) == false {
                            scrollView.sj_lock()
                            scrollView.setContentOffset(contentOffset, animated: false)
                            scrollView.sj_unlock()
                        }
                    }
                    
                    if focusedIndex == indexPath.item && !collectionView.isDecelerating && !collectionView.isDragging {
                        _insertHeaderViewForFocusedViewController()
                    }
                }
            }
        }
        
        self.delegate?.pageViewController(self, willDisplay: newViewController, at: indexPath.item)
        if focusedIndex == NSNotFound {
            focusedIndex = 0
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let pageCell = cell as! SJPageCollectionViewCell
        if hasHeader {
            if let viewController = pageCell.viewController {
                viewController.sj_pageItem?.intersection = heightForIntersectionBounds
                viewController.sj_pageItem?.contentOffset = viewController.sj_pageItem?.scrollView?.contentOffset ?? .zero
            }
        }
        
        delegate?.pageViewController(self, didEndDisplaying: pageCell.viewController, at: indexPath.item)
        removePageChildViewController(pageCell.viewController)
        pageCell.viewController = nil
    }
}

extension SJPageViewController: SJPageCollectionViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging || scrollView.isDecelerating {
            _updateFocusedIndex()
            _callScrollInRange()
        }
        _insertHeaderViewForRootViewController()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ( decelerate == false ) {
            self.scrollViewDidEndDecelerating(scrollView)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        _insertHeaderViewForFocusedViewController()
    }
    
    func collectionView(_ collectionView: SJPageCollectionView, gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.state == .cancelled || gestureRecognizer.state == .failed {
            return false
        }
        
        if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer, self.numberOfViewControllers != 0 {
            let location = gestureRecognizer.location(in: self.view)
            if hasHeader {
                if convertHeaderViewFrame(to: self.view).contains(location) {
                    gestureRecognizer.state = .cancelled
                    return false
                }
            }
            
            let leftEdgeRect = _rect(for: .left)
            let rightEdgeRect = _rect(for: .right)
            let webGestureClass: AnyClass? = NSClassFromString("UIWebTouchEventsGestureRecognizer")
            if leftEdgeRect.contains(location) {
                if let webGestureClass = webGestureClass, otherGestureRecognizer.isKind(of: webGestureClass) {
                    otherGestureRecognizer.state = .cancelled
                    return false
                }
                
                if otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
                    let translate = gestureRecognizer.translation(in: collectionView)
                    if translate.x > 0, translate.y == 0, self.focusedIndex != 0 {
                        otherGestureRecognizer.state = .cancelled
                        return false
                    }
                }
            }
            else if rightEdgeRect.contains(location) {
                if let webGestureClass = webGestureClass, otherGestureRecognizer.isKind(of: webGestureClass) {
                    otherGestureRecognizer.state = .cancelled
                    return false
                }
                
                if otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
                    let translate = gestureRecognizer.translation(in: collectionView)
                    if translate.x < 0, translate.y == 0, self.focusedIndex != self.numberOfViewControllers - 1 {
                        otherGestureRecognizer.state = .cancelled
                        return false
                    }
                }
            }
        }
        return false
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kContentOffset, let childScrollView = object as? UIScrollView {
            if collectionView.isDecelerating || collectionView.isDragging {
                return
            }
            
            let newValue = (change?[NSKeyValueChangeKey.newKey] as? CGPoint)?.y ?? 0
            let oldValue = (change?[NSKeyValueChangeKey.oldKey] as? CGPoint)?.y ?? 0
            
            if newValue == oldValue {
                return
            }
            setupContentInset(for: childScrollView)
            // 同步 pageItem, 当前 child scrollView 的 contentOffset
            if childScrollView.sj_locked == false {
                for vc in self.viewControllers.values {
                    if childScrollView == vc.sj_pageItem?.scrollView {
                        vc.sj_pageItem?.contentOffset = childScrollView.contentOffset
                        break
                    }
                }
            }
            
            // header悬浮控制
            if childScrollView == self.currentVisibleViewController?.sj_pageItem?.scrollView, let headerView = headerView {
                _insertHeaderViewForFocusedViewController()
                
                let offset = childScrollView.contentOffset.y
                let topPinOffset = offset - heightForHeaderBounds + heightForHeaderPinToVisibleBounds
                var frame = headerView.frame
                var y = frame.origin.y
                // 向上移动
                if newValue >= oldValue {
                    if y <= topPinOffset {
                        y = topPinOffset
                    }
                }
                // 向下移动
                else {
                    y += newValue - oldValue
                    if y <= -heightForHeaderBounds {
                        y = -heightForHeaderBounds
                    }
                }
                
                let mode = modeForHeader
                switch mode {
                case .tracking:
                    frame.origin.x = 0
                    frame.origin.y = y
                case .pinnedToTop:
                    if offset <= -heightForHeaderBounds {
                        y = offset
                    }
                    
                    frame.origin.x = 0
                    frame.origin.y = y
                case .scaleAspectFill:
                    var extend = (-offset - heightForHeaderBounds)
                    if offset <= -heightForHeaderBounds {
                        y = offset
                    }
                    else {
                        extend = 0
                    }
                    
                    frame.origin.x = -extend * 0.5
                    frame.origin.y = y
                    frame.size.width = self.view.bounds.width + extend
                    frame.size.height = heightForHeaderBounds + extend
                @unknown default:
                    break
                }
                
                headerView.frame = frame
                if ( mode == .scaleAspectFill ) {
                    headerView.layoutIfNeeded()
                }
                
                var indictorTopInset = -heightForHeaderBounds
                if y <= -heightForHeaderBounds {
                    indictorTopInset = y
                }
                if childScrollView.scrollIndicatorInsets.top != indictorTopInset {
                    childScrollView.scrollIndicatorInsets = UIEdgeInsets.init(top: -indictorTopInset, left: 0, bottom: 0, right: 0)
                }
                
                var headerScrollProgress = 1 - abs(y - offset) / heightForHeaderBounds
                if headerScrollProgress <= 0 {
                    headerScrollProgress = 0
                }
                else if headerScrollProgress >= 1 {
                    headerScrollProgress = 1
                }
                let rect = CGRect.init(x: 0, y: 0, width: frame.size.width, height: frame.size.height * headerScrollProgress)
                self.delegate?.pageViewController(self, headerViewVisibleRectDidChange: rect)
            }
        }
        else if ( context == &kState ) {
            _insertHeaderViewForFocusedViewController()
        }
    }
    
    private func _rect(for rectEdge: UIRectEdge) -> CGRect {
        let bounds = self.view.bounds
        if rectEdge == .left {
            return CGRect.init(x: 0, y: 0, width: 50, height: bounds.height)
        }
        if rectEdge == .right {
            return CGRect.init(x: bounds.width - 50, y: 0, width: 50, height: bounds.height)
        }
        return .zero
    }
    
    private func _updateFocusedIndex() {
        let horizontalOffset = collectionView.contentOffset.x
        let position = horizontalOffset / collectionView.bounds.width
        focusedIndex = Int(horizontalOffset > previousOffset ? ceil(position) : position);
        previousOffset = horizontalOffset
    }
    
    private func _callScrollInRange() {
        let horizontalOffset = collectionView.contentOffset.x
        let position = horizontalOffset / collectionView.bounds.width
        
        let left = Int(floor(position))
        let right = Int(ceil(position))
        
        if left >= 0 && right < self.numberOfViewControllers {
            let progress = position - CGFloat(left)
            self.delegate?.pageViewController(self, didScrollIn: .init(location: left, length: right - left), distanceProgress: progress)
        }
    }
    
    private func _insertHeaderViewForRootViewController() {
        if hasHeader, let headerView = headerView {
            let horizontalOffset = collectionView.contentOffset.x
            var frame = convertHeaderViewFrame(to: self.view)
            let lastItemOffset = CGFloat((self.numberOfViewControllers - 1)) * collectionView.bounds.width
            if horizontalOffset <= 0 {
                frame.origin.x = -horizontalOffset
            }
            else if horizontalOffset >= lastItemOffset {
                frame.origin.x = lastItemOffset - horizontalOffset
            }
            else {
                frame.origin.x = 0
            }
            headerView.frame = frame
            if headerView.superview != self.view {
                self.view.insertSubview(headerView, aboveSubview: collectionView)
            }
        }
    }
    
    private func _insertHeaderViewForFocusedViewController() {
        if hasHeader, let headerView = headerView, let childScrollView = self.focusedViewController?.sj_pageItem?.scrollView {
            headerView.frame = convertHeaderViewFrame(to: childScrollView)
            if headerView.superview != childScrollView {
                let index = _indexOfScrollIndicator(in: childScrollView)
                if index != NSNotFound {
                    childScrollView.insertSubview(headerView, at: index)
                }
                else {
                    childScrollView.addSubview(headerView)
                }
            }
        }
    }
    
    private func _indexOfScrollIndicator(in scrollView: UIScrollView) -> Int {
        let subviews = scrollView.subviews
        if let cls: AnyClass = NSClassFromString("_UIScrollViewScrollIndicator") {
            return subviews.firstIndex { (view) -> Bool in
                return view.isKind(of: cls)
                } ?? NSNotFound
        }
        return NSNotFound
    }
    
    private func setupContentInset(for childScrollView: UIScrollView) {
        let bounds = self.view.bounds
        let boundsHeight = bounds.size.height
        let contentHeight = childScrollView.contentSize.height
        var bottomInset = minimumBottomInsetForChildScrollView
        if contentHeight < boundsHeight {
            bottomInset = ceil(boundsHeight - contentHeight - heightForHeaderPinToVisibleBounds)
        }
        if bottomInset < minimumBottomInsetForChildScrollView {
            bottomInset = minimumBottomInsetForChildScrollView
        }
        
        var insets = childScrollView.contentInset
        if insets.top != heightForHeaderBounds || insets.bottom != bottomInset {
            insets.top = heightForHeaderBounds;
            insets.bottom = bottomInset;
            childScrollView.contentInset = insets;
        }
    }
}

private var kPageItem = "kPageItem";

fileprivate extension UIViewController {
    func sj_lookupScrollView() -> UIScrollView? {
        return sj_lookupScrollView(self.view)
    }
    
    private func sj_lookupScrollView(_ view: UIView) -> UIScrollView? {
        if let view = view as? UIScrollView {
            return view
        }
        
        for subview in view.subviews {
            if let subview = subview as? UIScrollView {
                return subview
            }
        }
        
        for subview in view.subviews {
            if let target = sj_lookupScrollView(subview) {
                return target
            }
        }
        return nil
    }
    
    var sj_pageItem: SJPageViewController.SJPageItem? {
        set {
            objc_setAssociatedObject(self, &kPageItem, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(self, &kPageItem) as? SJPageViewController.SJPageItem
        }
    }
}

private var kLocked = "kLocked";

fileprivate extension UIScrollView {
    func sj_lock() {
        objc_setAssociatedObject(self, &kLocked, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func sj_unlock() {
        objc_setAssociatedObject(self, &kLocked, false, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    var sj_locked: Bool {
        return objc_getAssociatedObject(self, &kLocked) as? Bool ?? false
    }
}

fileprivate extension SJPageViewController {
    struct SJPageItem {
        weak var scrollView: UIScrollView?
        var intersection: CGFloat = 0
        var contentOffset: CGPoint = .zero
    }
}
