//
//  MIIScrollableViews.swift
//  MIIScrollableViews
//
//  Created by Miida Yuki on 2017/12/18.
//

import UIKit

@objc public protocol MIIScrollableViewsDelegate: AnyObject {
    func didViewsCountChange(count: Int)
    func didViewDisplayedChange(viewDisplayed: UIView, index: Int)
    @objc optional func didTap(view: UIView, index: Int, gesture: UITapGestureRecognizer)
    @objc optional func didDoubleTap(view: UIView, index: Int, gesture: UITapGestureRecognizer)
    @objc optional func didPan(view: UIView, index: Int, gesture: UIPanGestureRecognizer)
    @objc optional func didPinch(view: UIView, index: Int, gesture: UIPinchGestureRecognizer)
    @objc optional func didLongPress(view: UIView, index: Int, gesture: UILongPressGestureRecognizer)
}

open class MIIScrollableViews: UIScrollView {
    // MARK: - Type Alias
    public typealias Tap = UITapGestureRecognizer
    public typealias Pan = UIPanGestureRecognizer
    public typealias Pinch = UIPinchGestureRecognizer
    public typealias LongPress = UILongPressGestureRecognizer
    
    private let allGestureTypes = [Tap.self, Pan.self, Pinch.self, LongPress.self]
    
    private enum TapGestureType: Int {
        case tap = 1
        case doubleTap
        
        static func isDoubleTap(_ tapGesture: Tap) -> Bool {
            switch tapGesture.numberOfTapsRequired {
            case self.doubleTap.rawValue:
                return true
            default:
                return false
            }
        }
    }
    
    // MARK: - Flags
    public var animated = true
    
    public var shouldRoundViewDisplayed = true
    
    public var shouldMoveWhenAdding = true
    
    public var shouldAddTapGesture = false {
        didSet {
            didGestureFlagChange(oldFlag: oldValue, shouldAdd: shouldAddTapGesture, type: Tap.self)
        }
    }
    
    public var shouldAddPanGesture = false {
        didSet {
            didGestureFlagChange(oldFlag: oldValue, shouldAdd: shouldAddPanGesture, type: Pan.self)
        }
    }
    
    public var shouldAddPinchGesture = false {
        didSet {
            didGestureFlagChange(oldFlag: oldValue, shouldAdd: shouldAddPinchGesture, type: Pinch.self)
        }
    }
    
    public var shouldAddLongPressGesture = false {
        didSet {
            didGestureFlagChange(oldFlag: oldValue, shouldAdd: shouldAddLongPressGesture, type: LongPress.self)
        }
    }
    
    public var shouldAddDoubleTapGesture = false {
        didSet {
            guard oldValue != shouldAddDoubleTapGesture else {
                return
            }
            
            if shouldAddDoubleTapGesture {
                for view in views { addDoubleTapGesture(to: view) }
            } else {
                for view in views { removeDoubleTapGesture(from: view) }
            }
        }
    }
    
    private var beginningTapFlag = false
    
    private func didGestureFlagChange<T: UIGestureRecognizer>(oldFlag: Bool, shouldAdd: Bool, type: T.Type) {
        guard oldFlag != shouldAdd else {
            return
        }
        
        if shouldAdd {
            for view in views { addGesture(to: view, type: T.self) }
        } else {
            for view in views { removeGesture(from: view, type: T.self) }
        }
    }
    
    public func addAllGesturesToViews() {
        shouldAddTapGesture = true
        shouldAddPanGesture = true
        shouldAddPinchGesture = true
        shouldAddLongPressGesture = true
        shouldAddDoubleTapGesture = true
    }
    
    public func removeAllGesturesFromViews() {
        shouldAddTapGesture = false
        shouldAddPanGesture = false
        shouldAddPinchGesture = false
        shouldAddLongPressGesture = false
        shouldAddDoubleTapGesture = false
    }
    
    public weak var svDelegate: MIIScrollableViewsDelegate?
    
    private var oldIndex: Int?
    private var scrollStartingPointOfX: CGFloat?
    
    private var views: [UIView] = [] {
        didSet {
            adjustContentSize()
            
            if let svDelegate = svDelegate {
                svDelegate.didViewsCountChange(count: views.count)
            }
        }
    }
    
    public subscript(index: Int) -> UIView {
        get {
            return views[index]
        }
        set {
            if index == views.count { append(newValue) }
            
            replaceView(newValue, at: index)
        }
    }
    
    public var all: [UIView] {
        return views
    }
    
    public var count: Int {
        return views.count
    }
    
    public var isEmpty: Bool {
        return views.isEmpty
    }
    
    public var first: UIView? {
        return views.first
    }
    
    public var last: UIView? {
        return views.last
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - Private Methods
    private func commonInit() {
        // set UIScrollViewDelegate
        self.delegate = self
        
        // setup ScrollView
        setupScrollView()
        
        // setupGestures
        for view in views {
            setupGestures(to: view)
        }
    }
    
    private func setupScrollView() {
        // No ScrollIndicators
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        // Enable Paging
        self.isPagingEnabled = true
    }
    
    private func setupView(_ view: UIView, at index: Int) {
        view.isUserInteractionEnabled = true
        view.frame = self.bounds
        view.frame.origin.x = self.frame.width * CGFloat(index)
        
        setupGestures(to: view)
    }
    
    private func setupGestures(to view: UIView) {
        if shouldAddTapGesture { addGesture(to: view, type: Tap.self) }
        if shouldAddPanGesture { addGesture(to: view, type: Pan.self) }
        if shouldAddPinchGesture { addGesture(to: view, type: Pinch.self) }
        if shouldAddLongPressGesture { addGesture(to: view, type: LongPress.self) }
        if shouldAddDoubleTapGesture { addDoubleTapGesture(to: view) }
    }
    
    private func addGesture<T: UIGestureRecognizer>(to view: UIView, type: T.Type) {
        if type == Tap.self {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap))
            
            if let doubleTap = findTapGesture(from: view, type: .doubleTap) {
                tap.require(toFail: doubleTap)
            }
            
            view.addGestureRecognizer(tap)
        }
        
        if type == Pan.self {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan))
            pan.delegate = self
            pan.minimumNumberOfTouches = 1
            pan.maximumNumberOfTouches = 2
            view.addGestureRecognizer(pan)
        }
        
        if type == Pinch.self {
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch))
            pinch.delegate = self
            view.addGestureRecognizer(pinch)
        }
        
        if type == LongPress.self {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
            longPress.delegate = self
            view.addGestureRecognizer(longPress)
        }
    }
    
    private func addDoubleTapGesture(to view: UIView) {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        doubleTap.numberOfTapsRequired = 2
        
        if let tap = findTapGesture(from: view, type: .tap) {
            tap.require(toFail: doubleTap)
        }
        
        view.addGestureRecognizer(doubleTap)
    }
    
    private func removeGesture<T: UIGestureRecognizer>(from view: UIView, type: T.Type) {
        guard let gestures = view.gestureRecognizers else {
            return
        }
        
        for gesture in gestures where gesture is T {
            if let tap = gesture as? Tap {
                // skip removing `DoubleTap` Gesture
                if !TapGestureType.isDoubleTap(tap) {
                    view.removeGestureRecognizer(gesture)
                }
                continue
            }
            
            view.removeGestureRecognizer(gesture)
        }
    }
    
    private func removeDoubleTapGesture(from view: UIView) {
        guard let doubleTap = findTapGesture(from: view, type: .doubleTap) else {
            return
        }
        
        if findTapGesture(from: view, type: .tap) != nil {
            removeGesture(from: view, type: Tap.self)
            addGesture(to: view, type: Tap.self)
        }
        
        view.removeGestureRecognizer(doubleTap)
    }
    
    private func findTapGesture(from view: UIView, type: TapGestureType) -> UITapGestureRecognizer? {
        guard let gestures = view.gestureRecognizers else {
            return nil
        }
        
        for gesture in gestures where gesture is UITapGestureRecognizer {
            let tapGesture = gesture as! UITapGestureRecognizer
            
            switch tapGesture.numberOfTapsRequired {
            case TapGestureType.tap.rawValue:
                if type == .tap { return tapGesture }
            case TapGestureType.doubleTap.rawValue:
                if type == .doubleTap { return tapGesture }
            default:
                break
            }
        }
        
        return nil
    }
    
    private func adjustContentSize() {
        self.contentSize.width = self.frame.width * CGFloat(views.count)
    }
    
    private func replaceView(_ view: UIView, at index: Int) {
        let oldView = views[index]
        views[index] = view
        
        oldView.removeFromSuperview()
        
        setupView(view, at: index)
        addSubview(view)
    }
    
    // MARK: - Public Methods
    public func index(of view: UIView) -> Int? {
        return views.index(of: view)
    }
    
    public func insert(_ view: UIView, at index: Int) {
        setupView(view, at: index)
        
        views.insert(view, at: index)
        addSubview(view)
        
        for i in index + 1 ..< views.count {
            views[i].frame.origin.x += self.frame.width
        }
        
        if shouldMoveWhenAdding { move(to: view) }
    }
    
    public func insert(contentsOf elements: [UIView], at index: Int) {
        for (i, element) in elements.enumerated() {
            insert(element, at: i + index)
        }
    }
    
    public func append(_ view: UIView) {
        insert(view, at: views.count)
    }
    
    public func append(contentsOf elements: [UIView]) {
        insert(contentsOf: elements, at: views.count)
    }
    
    public func remove(at index: Int) {
        views.remove(at: index).removeFromSuperview()
        
        for i in index ..< views.count {
            views[i].frame.origin.x -= self.frame.width
        }
    }
    
    public func removeLast() {
        views.removeLast().removeFromSuperview()
    }
    
    public func removeAll() {
        views.removeAll()
        
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
    
    public func move(to view: UIView) {
        if let index = views.index(of: view) {
            self.setContentOffset(CGPoint(x: self.frame.width * CGFloat(index), y: self.bounds.origin.y), animated: animated)
        }
    }
}

extension MIIScrollableViews: UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollStartingPointOfX = self.contentOffset.x
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let svDelegate = svDelegate {
            var cgFloatIndex = self.contentOffset.x / self.frame.size.width
            
            cgFloatIndex = shouldRoundViewDisplayed ? cgFloatIndex.rounded() : getRetainedIndex(cgFloatIndex, x: self.contentOffset.x)
            
            let index = Int(cgFloatIndex)
            
            if oldIndex != index {
                if oldIndex != nil { svDelegate.didViewDisplayedChange(viewDisplayed: views[index], index: index) }
                oldIndex = index
            }
        }
    }
    
    private func getRetainedIndex(_ index: CGFloat, x: CGFloat) -> CGFloat {
        
        guard let startX = scrollStartingPointOfX else {
            return index
        }
        
        return startX < x ? index.rounded(.down) : index.rounded(.up)
    }
}

// Gestures
extension MIIScrollableViews: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension MIIScrollableViews {
    @objc private func tap(gesture: Tap) {
        invokeGestureDelegateMethod(gesture: gesture, type: Tap.self)
    }
    
    @objc private func pan(gesture: Pan) {
        invokeGestureDelegateMethod(gesture: gesture, type: Pan.self)
    }
    
    @objc private func pinch(gesture: Pinch) {
        invokeGestureDelegateMethod(gesture: gesture, type: Pinch.self)
    }
    
    @objc private func longPress(gesture: LongPress) {
        // To prevent `tap` from being called after LongPress
        if gesture.state == .began {
            beginningTapFlag = shouldAddTapGesture
            shouldAddTapGesture = false
        }
        if gesture.state == .ended { shouldAddTapGesture = beginningTapFlag }
        
        invokeGestureDelegateMethod(gesture: gesture, type: LongPress.self)
    }
    
    private func invokeGestureDelegateMethod<T: UIGestureRecognizer>(gesture: T, type: T.Type) {
        if let svDelegate = svDelegate {
            guard let view = gesture.view, let index = views.index(of: view) else {
                return
            }
            
            if let tap = gesture as? Tap {
                if TapGestureType.isDoubleTap(tap) {
                    svDelegate.didDoubleTap?(view: view, index: index, gesture: tap)
                } else {
                    svDelegate.didTap?(view: view, index: index, gesture: tap)
                }
            }
            
            if type == Pan.self {
                svDelegate.didPan?(view: view, index: index, gesture: gesture as! MIIScrollableViews.Pan)
            }
            
            if type == Pinch.self {
                svDelegate.didPinch?(view: view, index: index, gesture: gesture as! MIIScrollableViews.Pinch)
            }
            
            if type == LongPress.self {
                svDelegate.didLongPress?(view: view, index: index, gesture: gesture as! MIIScrollableViews.LongPress)
            }
        }
    }
}


