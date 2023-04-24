//
//  SlidingSheet
//  Configurable Bottom Sheet for UIKit - like AirBnb and Apple Maps
//
//  Created & Maintained by Daniele Margutti
//  Email: hello@danielemargutti
//  Web: http://www.danielemargutti.com
//
//  Copyright ©2023 Daniele Margutti
//  Licensed under MIT License.
//

import UIKit

/// This class represent the actual sliding sheet user can control via pan gesture.
public class SlidingSheetView: UIView, UIGestureRecognizerDelegate {
    
    // MARK: - Public Properties
    
    /// Loaded configuration used to create the sliding sheet.
    public let config: Config
    
    /// Delegate class to receive events from the sheet view.
    /// NOTE: You should never change it when used inside a `SlidingSheetController`.
    public weak var delegate: SlidingSheetViewDelegate?
    
    /// Instance of the view with the actual data represented by the sheet.
    public var contentView: SlideSheetPresented {
        config.contentView
    }
    
    /// Instance of the pull indicator view, if set.
    public private(set) var pullIndicatorView: UIView?
    
    /// Parent controller of the view.
    public var parentViewController: UIViewController? {
        config.parentViewController
    }
    
    /// Current position of the sliding sheet.
    public lazy var currentPosition: Position = config.initialPosition

    /// Pan gesture used to perform the slide with hands.
    public let panGesture = UIPanGestureRecognizer()
    
    // MARK: - Private Properties
    
    /// Dismiss accessory button.
    private var dismissButton: UIButton?
    
    /// Current height constraint reference for the sheet. Used to perform animations.
    private var heightConstraint: NSLayoutConstraint?
    
    /// Start Y position of the gesture.
    private lazy var panGestureY = CGFloat(frame.height)
    
    private var scrollViewOffsetObserverContext = UUID()
    
    /// Called after the sheet is properly set in place into the UI.
    /// This is necessary since some events like the observe of the scroll view
    /// should be not sent automatically when the view is being initialized in its frame
    /// property in order to set as subview of its container.
    private var layoutIsInProgress = true

    /// Define possible heights for each allowed state of the view.
    /// When state is not supported value is set to 0 and therefore ignored by the animation.
    private var allowedHeights: (
        fixed: CGFloat,
        top: CGFloat,
        middle: CGFloat,
        bottom: CGFloat,
        byContent: CGFloat
    ) = (0, 0, 0, 0, 0)
    
    // MARK: - Initialization
    
    /// Initialize a new sliding sheet with given configuration.
    ///
    /// - Parameter config: configuration.
    public init(config: Config) {
        self.config = config
        
        super.init(frame: .zero)
        
        setupUI()
        setupPanGesture()
        evaluateHeightsOnAllowedPositions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    /// Setup the initial height of the sliding sheet based upon the current configuration.
    ///
    /// NOTE:
    /// This method should be called only if you plan to use `SlidingSheetView` directly without
    /// its controller.
    public func setupLayout(animated: Bool) {
        guard superview != nil else {
            return // no superview, skip.
        }
        
        delegate?.slidingSheetView(self, willMoveTo: config.initialPosition)
        
        if case .fitContent = config.initialPosition {
            setupInitialHeight(allowedHeights.byContent, animated: animated)
        } else {
            setupInitialHeight(config.initialPosition.height, animated: animated)
        }
        
        delegate?.slidingSheetView(self, didMoveFromPosition: nil, toPosition: config.initialPosition)
    }

    /// Dismiss the sheet if allowed.
    ///
    /// - Returns: `true` if dismiss was performed, `false` otherwise.
    @discardableResult
    public func dismiss() -> Bool {
        guard config.isDismissable else {
            return false
        }
        
        self.delegate?.slidingSheetViewRequestForDismission(self)
        return true
    }
    
    /// When the sheet is anchored the pull indicator view is hidden and
    /// the corner radius is set to none.
    ///
    /// - Parameters:
    ///   - anchored: `true` to enable anchored mode.
    public func setAsAnchored(_ anchored: Bool) {
        UIView.animate(withDuration: 0.25, delay: 0.0) {
            self.pullIndicatorView?.alpha = (anchored ? 1 : 0)
            self.layer.cornerRadius = (anchored ? self.config.cornerRadius : 0)
        }
    }
    
    /// Set the height based upon the new position and change the state of the control.
    ///
    /// - Parameters:
    ///   - newPosition: new position to apply.
    ///   - duration: duration of the animation, if not specified the default one is used.
    public func moveToPosition(_ newPosition: Position, duration: TimeInterval? = nil) {
        let oldPosition = currentPosition
        
        delegate?.slidingSheetView(self, willMoveTo: newPosition)
        
        switch newPosition {
        case let .fixed(height):
            setHeight(height)
        case .top:
            setHeight(allowedHeights.top, duration: duration)
            currentPosition = .top(allowedHeights.top)
        case .middle:
            setHeight(allowedHeights.middle, duration: duration)
            currentPosition = .middle(allowedHeights.middle)
        case .bottom:
            setHeight(allowedHeights.bottom, duration: duration)
            currentPosition = .bottom(allowedHeights.bottom)
        case .fitContent:
            setHeight(allowedHeights.byContent, duration: duration)
            currentPosition = .fitContent
        }

        delegate?.slidingSheetView(self, didMoveFromPosition: oldPosition, toPosition: currentPosition)
    }
    
    // MARK: - View Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = config.cornerRadius
        
        pullIndicatorView?.layer.cornerRadius = 2
        if #available(iOS 13.0, *) {
            pullIndicatorView?.layer.cornerCurve = .continuous
        }
    }
    
    /// Configure the UI with the elements of the sliding sheet.
    private func setupUI() {
        self.backgroundColor = .white
        self.isOpaque = true
        
        addSubview(contentView.presentedView)
        contentView.presentedView.translatesAutoresizingMaskIntoConstraints = false
        
        if config.showPullIndicator { // install the pull indicator view at the top of the hseet.
            self.pullIndicatorView = setupPullIndicatorView()
        } else {
            // pull indicator is disabled,
            NSLayoutConstraint.activate([
                contentView.presentedView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                contentView.presentedView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                contentView.presentedView.topAnchor.constraint(equalTo: self.topAnchor, constant: config.contentViewVerticalMargins.bottom)
            ])
        }
        
        if contentView.scrollView?.isKind(of: UIScrollView.self) ?? false {
            let constraint = contentView.presentedView.bottomAnchor.constraint(equalTo: bottomAnchor)
            constraint.priority = .init(999)
            constraint.isActive = true
            
            contentView.scrollView?.addObserver(self, forKeyPath: "bounds", options: .new, context: &scrollViewOffsetObserverContext)
        }
        
        if let dismissIcon = config.dismissIcon {
            self.dismissButton = setupDismissAccessoryButton(icon: dismissIcon)
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard layoutIsInProgress == false, // avoid the event to be called during the view initialization before being part of the superview.
              context == &self.scrollViewOffsetObserverContext,
              let scrollView = object as? UIScrollView,
              scrollView == contentView.scrollView else {
            return
        }
        
        delegate?.slidingSheetViewScrollViewDidChangeOffset(self, scrollView: scrollView, offset: scrollView.contentOffset)
    }
    
    /// Install the pull indicator.
    /// The pull indicator is just a small view used to indicate the user the size of the control
    /// may be changed using a pan gesture.
    ///
    /// - Returns: instance of the view.
    private func setupPullIndicatorView() -> UIView {
        let pullView = UIView()
        pullView.backgroundColor = config.pullIndicatorColor
        addSubview(pullView)
        pullView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pullView.topAnchor.constraint(equalTo: self.topAnchor, constant: config.contentViewVerticalMargins.top),
            pullView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            pullView.heightAnchor.constraint(equalToConstant: config.pullIndicatorSize.height),
            pullView.widthAnchor.constraint(equalToConstant: config.pullIndicatorSize.width)
        ])
        
        NSLayoutConstraint.activate([
            contentView.presentedView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.presentedView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentView.presentedView.topAnchor.constraint(equalTo: pullView.bottomAnchor, constant: config.contentViewVerticalMargins.bottom)
        ])
        return pullView
    }
    
    /// Configure the pan gesture.
    private func setupPanGesture() {
        addGestureRecognizer(panGesture)
        panGesture.delegate = self
        panGesture.addTarget(self, action: #selector(didPerformPanGesture(sender:)))
    }
    
    /// Install the dismiss button.
    /// The button is placed on the top right area of the sliding sheet.
    ///
    /// - Parameter icon: icon to place.
    /// - Returns: button instance used.
    private func setupDismissAccessoryButton(icon: UIImage) -> UIButton {
        let button = UIButton()
        button.setImage(icon, for: .normal)
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup location on top right of the sliding sheet.
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor, constant: config.dismissIconMargins.top),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: config.dismissIconMargins.right)
        ])
        
        if let fixedSize = config.dismissIconSize { // if user set a fixed size.
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: fixedSize.width),
                button.heightAnchor.constraint(equalToConstant: fixedSize.height)
            ])
        }
        
        button.addTarget(self, action: #selector(onTapDismissSheet(sender:)), for: .touchUpInside)
        return button
    }
    
    /// Action used to perform the dismiss of the sheet explicitly.
    ///
    /// - Parameter sender: sender of the action.
    @objc
    private func onTapDismissSheet(sender: UIButton) {
        dismiss()
    }
    
    /// Calculate the height of the sliding sheet based upon
    /// the allowed positions passed into the configuration.
    private func evaluateHeightsOnAllowedPositions() {
        for position in config.allowedPositions {
            switch position {
            case let .fixed(height):
                allowedHeights.fixed = height
            case let .top(height):
                allowedHeights.top = height
            case let .middle(height):
                allowedHeights.middle = height
            case let .bottom(height):
                allowedHeights.bottom = height
            case .fitContent:
                if let scrollView = contentView as? UIScrollView {
                    // dynamic size based upon the content of the scroll size.
                    let finalRect = scrollView.contentSize
                    allowedHeights.byContent = min(finalRect.height + Defaults.overscrollFitContent, Defaults.maxScreenHeight)
                } else {
                    // enumerate subviews to find the correct height.
                    let finalRect: CGRect = contentView.presentedView.subviews.reduce(into: .zero) { rect, subview in
                        rect = rect.union(subview.frame)
                    }
                    allowedHeights.byContent = finalRect.height
                }
            }
        }
    }
    
    /// Change the height of the sliding sheet.
    ///
    /// - Parameter height: height to set.
    private func setupInitialHeight(_ height: CGFloat, animated: Bool) {
        layoutIsInProgress = true

        heightConstraint?.isActive = false
        heightConstraint = heightAnchor.constraint(equalToConstant: height)
        heightConstraint?.priority = .init(999)
        heightConstraint?.isActive = true
        
        setNeedsLayout()
        
        guard config.slideToAppear else {
            self.delegate?.slidingSheetView(self, heightDidChange: height)
            return
        }
        
        if !animated {
            self.superview?.layoutIfNeeded()
            self.delegate?.slidingSheetView(self, heightDidChange: height)
            self.layoutIsInProgress = false
            return
        }
        
        UIView.animate(withDuration: 0.35, delay: 0.0, options: .allowAnimatedContent, animations: { [weak self] in
            guard let self else { return }
            self.superview?.layoutIfNeeded()
            self.delegate?.slidingSheetView(self, heightDidChange: height)
            self.layoutIsInProgress = false
        })
    }
    
    /// Handle the action of the gesture.
    ///
    /// - Parameter sender: gesture instance.
    @objc
    private func didPerformPanGesture(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began, .possible:
            layoutIsInProgress = true
            panGestureY = frame.height
        case .changed:
            if let scrollView = contentView as? UIScrollView, scrollView.contentOffset.y <= 0 {
                scrollView.contentOffset.y = 0 // if reached the top we want to pass the comand to the slide.
            }
            let height = -sender.translation(in: parentViewController?.view).y + panGestureY
            setHeight(height, animated: false)
            
        case .cancelled, .ended, .failed:
            panGestureY = frame.height
            if sender.velocity(in: parentViewController?.view).y > 1000, config.isDismissable {
                self.delegate?.slidingSheetViewRequestForDismission(self)
                break
            }
            
            let currentY = -sender.translation(in: parentViewController?.view).y + panGestureY
            let currentVelocity = sender.velocity(in: parentViewController?.view).y
            moveToClosestAllowedPosition(forY: currentY, velocity: currentVelocity)
            layoutIsInProgress = false
            
        @unknown default:
            break
        }
    }
    
    /// Identify the closest allowed position based upon the current location of the pan gesture,
    /// then move to that position.
    ///
    /// - Parameters:
    ///   - y: current position of the pan.
    ///   - velocity: velocity used to perform the gesture, used to clarify the intetion.
    private func moveToClosestAllowedPosition(forY y: CGFloat?, velocity: CGFloat) {
        guard let y else { return }
        
        switch currentPosition {
        case .fixed:
            moveToPosition(currentPosition)
        case let .top(height):
            if height <= y, velocity <= 0, allowedHeights.top != 0 {
                moveToPosition(.top(allowedHeights.top))
            } else if height >= y, velocity >= 0, allowedHeights.middle != 0 {
                moveToPosition(.middle(allowedHeights.middle))
            } else if height >= y, velocity >= 0, allowedHeights.bottom != 0 {
                moveToPosition(.bottom(allowedHeights.bottom))
            } else {
                moveToPosition(.top(allowedHeights.top))
            }
            
        case let .middle(height):
            if height <= y, velocity <= 0, allowedHeights.top != 0 {
                moveToPosition(.top(allowedHeights.top))
            } else if height >= y, velocity >= 0, allowedHeights.bottom != 0 {
                moveToPosition(.bottom(allowedHeights.bottom))
            } else {
                moveToPosition(.middle(allowedHeights.middle))
            }
            
        case let .bottom(height):
            if height >= y, velocity >= 0, allowedHeights.bottom != 0 {
                moveToPosition(.bottom(allowedHeights.bottom))
            } else if height <= y, velocity <= 0, allowedHeights.middle != 0 {
                moveToPosition(.middle(allowedHeights.middle))
            } else if height <= y, velocity <= 0, allowedHeights.top != 0 {
                moveToPosition(.top(allowedHeights.top))
            }
            
        case .fitContent:
            moveToPosition(.fitContent)
        }
    }
    
    /// Internal function to setup the height and animate the transition.
    ///
    /// - Parameters:
    ///   - height: height to set.
    ///   - animated: animate the transition, by default is set to `true`.
    private func setHeight(_ height: CGFloat, animated: Bool = true, duration: TimeInterval? = nil) {
        heightConstraint?.isActive = false
        heightConstraint = heightAnchor.constraint(equalToConstant: height)
        heightConstraint?.priority = .init(999)
        heightConstraint?.isActive = true
            
        setNeedsLayout()
        
        if animated {
            let duration = (duration ?? 0.55)
            UIView.animate(withDuration: duration,
                           delay: 0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 1,
                           options: .curveEaseInOut, animations: ({ [weak self] in
                self?.superview?.layoutIfNeeded()
            }))
        } else {
            superview?.layoutIfNeeded()
        }
        
        self.delegate?.slidingSheetView(self, heightDidChange: height)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let scrollView = contentView as? UIScrollView else {
            return false
        }
        
        return scrollView.contentOffset.y == 0 && panGesture.velocity(in: parentViewController?.view).y > 0
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: contentView.presentedView) ?? false) &&
            gestureRecognizer.isKind(of: UITapGestureRecognizer.self) {
            return false
        }
        
        return true
    }
    
}
