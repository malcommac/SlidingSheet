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

public protocol SlidingSheetViewDelegate: AnyObject {
    
    func slidingSheetView(_ view: SlidingSheetView, heightDidChange y: CGFloat)
    func slidingSheetViewRequestForDismission(_ view: SlidingSheetView)
    
}

public class SlidingSheetView: UIView, UIGestureRecognizerDelegate {
    
    public let config: Config

    public private(set) var pullIndicatorView: UIView?
    
    public weak var delegate: SlidingSheetViewDelegate?
    
    public var parentViewController: UIViewController? {
        config.parentViewController
    }
    
    public lazy var currentPosition: Position = config.initialPosition

    private var dismissButton: UIButton?
    
    private var maxHeight: CGFloat {
        UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height
    }
    
    private var heightConstraint: NSLayoutConstraint?
    private let panGesture = UIPanGestureRecognizer()
    private lazy var startPositionY = CGFloat(frame.height)
    
    private var heights: (
        fixed: CGFloat,
        top: CGFloat,
        middle: CGFloat,
        bottom: CGFloat,
        byContent: CGFloat
    ) = (0, 0, 0, 0, 0)
    
    public var contentView: UIView {
        config.contentView
    }
    
    public init(configuration: Config) {
        self.config = configuration
        
        super.init(frame: .zero)
        
        setupLayout()
        installPanGesture()
        evaluateSlidePositions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = config.cornerRadius
        
        pullIndicatorView?.layer.cornerRadius = 2
        pullIndicatorView?.layer.cornerCurve = .continuous
    }
    
    private func setupLayout() {
        self.backgroundColor = .white
        
        addSubview(config.contentView)
        config.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        if config.showPullIndicator {
            self.pullIndicatorView = installPullIndicatorView()
        } else {
            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16)
            ])
        }
        
        if contentView.isKind(of: UIScrollView.self) {
            let constraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
            constraint.priority = .init(999)
            constraint.isActive = true
        }
        
        if let dismissIcon = config.dismissIcon {
            self.dismissButton = installDismissButton(icon: dismissIcon)
        }
        
    }
    
    private func installDismissButton(icon: UIImage) -> UIButton {
        let button = UIButton()
        button.setImage(icon, for: .normal)
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        
        button.addTarget(self, action: #selector(onTapDismissButton(sender:)), for: .touchUpInside)
        return button
    }
    
    @objc
    private func onTapDismissButton(sender: UIButton) {
        guard config.isDismissable else {
            return
        }
        
        self.delegate?.slidingSheetViewRequestForDismission(self)
    }
    
    private func evaluateSlidePositions() {
        for position in config.allowedPositions {
            switch position {
            case let .fixed(height):
                heights.fixed = height
            case let .atTop(height):
                heights.top = height
            case let .atMiddle(height):
                heights.middle = height
            case let .atBottom(height):
                heights.bottom = height
            case .fitContent:
                if let scrollView = contentView as? UIScrollView {
                    let finalRect = scrollView.contentSize
                    heights.byContent = min(finalRect.height + 70, maxHeight)
                } else {
                    // enumerate subviews to find the correct height.
                    let finalRect: CGRect = contentView.subviews.reduce(into: .zero) { rect, subview in
                        rect = rect.union(subview.frame)
                    }
                    heights.byContent = finalRect.height
                }
            }
        }
    }
    
    private func installPullIndicatorView() -> UIView {
        let pullView = UIView()
        pullView.backgroundColor = UIColor(red: 229 / 255, green: 229 / 255, blue: 229 / 255, alpha: 1)
        addSubview(pullView)
        pullView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pullView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            pullView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            pullView.heightAnchor.constraint(equalToConstant: 4),
            pullView.widthAnchor.constraint(equalToConstant: 44)
        ])
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: pullView.bottomAnchor, constant: 16)
        ])
        return pullView
    }
    
    func setupInitialHeight() {
        guard superview != nil else {
            return
        }
        
        if case .fitContent = config.initialPosition {
            setupInitialHeight(heights.byContent)
        } else {
            setupInitialHeight(config.initialPosition.height)
        }
    }
    
    private func setupInitialHeight(_ height: CGFloat) {
        heightConstraint?.isActive = false
        heightConstraint = heightAnchor.constraint(equalToConstant: height)
        heightConstraint?.priority = .init(999)
        heightConstraint?.isActive = true
        
        setNeedsLayout()
        
        guard config.slideToAppear else {
            self.delegate?.slidingSheetView(self, heightDidChange: height)
            return
        }
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .allowAnimatedContent, animations: { [weak self] in
            guard let self else { return }
            self.superview?.layoutIfNeeded()
            self.delegate?.slidingSheetView(self, heightDidChange: height)
        })
    }
    
    private func installPanGesture() {
        addGestureRecognizer(panGesture)
        panGesture.delegate = self
        panGesture.addTarget(self, action: #selector(didPerformPangesture(sender:)))
    }
    
    @objc
    private func didPerformPangesture(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began, .possible:
            startPositionY = frame.height
        case .changed:
            if let scrollView = contentView as? UIScrollView, scrollView.contentOffset.y <= 0 {
                scrollView.contentOffset.y = 0
            }
            let height = -sender.translation(in: parentViewController?.view).y + startPositionY
            updateHeight(height)
        case .cancelled, .ended, .failed:
            startPositionY = frame.height
            if sender.velocity(in: parentViewController?.view).y > 1000, config.isDismissable {
                self.delegate?.slidingSheetViewRequestForDismission(self)
                break
            }
            
            let currentY = -sender.translation(in: parentViewController?.view).y + startPositionY
            let currentVelocity = sender.velocity(in: parentViewController?.view).y
            moveToClosestAllowedPosition(forY: currentY, velocity: currentVelocity)
            
        @unknown default:
            break
        }
    }
    
    private func updateHeight(_ height: CGFloat, animated: Bool = false) {
        heightConstraint?.isActive = false
        heightConstraint = heightAnchor.constraint(equalToConstant: height)
        heightConstraint?.priority = .init(999)
        heightConstraint?.isActive = true
        
        setNeedsLayout()
        
        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 1,
                           options: .curveEaseOut, animations: ({ [weak self] in
                self?.superview?.layoutIfNeeded()
            }))
        }
        
        self.delegate?.slidingSheetView(self, heightDidChange: height)
    }
    
    private func moveToClosestAllowedPosition(forY y: CGFloat?, velocity: CGFloat) {
        guard let y else { return }
        
        switch currentPosition {
        case .fixed:
            moveToPosition(currentPosition)
        case let .atTop(height):
            if height <= y, velocity <= 0, heights.top != 0 {
                moveToPosition(.atTop(heights.top))
            } else if height >= y, velocity >= 0, heights.middle != 0 {
                moveToPosition(.atMiddle(heights.middle))
            } else if height >= y, velocity >= 0, heights.bottom != 0 {
                moveToPosition(.atBottom(heights.bottom))
            } else {
                moveToPosition(.atTop(heights.top))
            }
            
        case let .atMiddle(height):
            if height <= y, velocity <= 0, heights.top != 0 {
                moveToPosition(.atTop(heights.top))
            } else if height >= y, velocity >= 0, heights.bottom != 0 {
                moveToPosition(.atBottom(heights.bottom))
            } else {
                moveToPosition(.atMiddle(heights.middle))
            }
            
        case let .atBottom(height):
            if height >= y, velocity >= 0, heights.bottom != 0 {
                moveToPosition(.atBottom(heights.bottom))
            } else if height <= y, velocity <= 0, heights.middle != 0 {
                moveToPosition(.atMiddle(heights.middle))
            } else if height <= y, velocity <= 0, heights.top != 0 {
                moveToPosition(.atTop(heights.top))
            }
            
        case .fitContent:
            moveToPosition(.fitContent)
        }
    }
    
    private func moveToPosition(_ newPosition: Position) {
        switch newPosition {
        case let .fixed(height):
            updateHeight(height)
        case .atTop:
            updateHeight(heights.top)
            currentPosition = .atTop(heights.top)
        case .atMiddle:
            updateHeight(heights.bottom)
            currentPosition = .atMiddle(heights.middle)
        case .atBottom:
            updateHeight(heights.bottom)
            currentPosition = .atBottom(heights.bottom)
        case .fitContent:
            updateHeight(heights.byContent)
            currentPosition = .fitContent
        }
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
        if (touch.view?.isDescendant(of: contentView) ?? false) &&
            gestureRecognizer.isKind(of: UITapGestureRecognizer.self) {
            return false
        }
        
        return true
    }
    
}
