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

public class SlidingSheetController: UIViewController, UIGestureRecognizerDelegate, SlidingSheetViewDelegate {
    public weak var delegate: SlidingSheetControllerDelegate?
    public var slidingSheetView: SlidingSheetView
    
    private var tapGesture = UITapGestureRecognizer()
    private var heightConstraint: NSLayoutConstraint?
    private var backgroundView = UIView()

    public convenience init(config: SlidingSheetView.Config) {
        let slidingSheetView = SlidingSheetView(config: config)
        self.init(slidingSheetView: slidingSheetView)
    }
    
    public init(slidingSheetView: SlidingSheetView) {
        self.slidingSheetView = slidingSheetView
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func present(from vc: UIViewController) {
        vc.present(self, animated: false)
    }
 
    override public func viewDidLoad() {
        super.viewDidLoad()
        installTapGesture()
    }
 
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSubviews()
        // viewDidAppear?()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // viewDidDisappear?()
    }
    
    private func setupSubviews() {
        backgroundView.backgroundColor = .clear
        slidingSheetView.delegate = self
        
        // Install background view
        self.view.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        // Install sliding view
        self.view.addSubview(slidingSheetView)
        slidingSheetView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            slidingSheetView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            slidingSheetView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            slidingSheetView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        self.heightConstraint = slidingSheetView.heightAnchor.constraint(equalToConstant: 0)
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        slidingSheetView.setupInitialHeight()
    }
    
    private func installTapGesture() {
        tapGesture.addTarget(self, action: #selector(onTap(sender:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func onTap(sender: UITapGestureRecognizer) {
        let isTapOutsideSliding = !slidingSheetView.frame.contains(sender.location(in: view))
        if slidingSheetView.config.isDismissable, isTapOutsideSliding {
            dismissSheet()
        }
    }
    
    fileprivate func dismissSheet() {
        delegate?.slidingSheetControllerWillDismiss(self)
        
        heightConstraint?.isActive = false
        heightConstraint = slidingSheetView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint?.isActive = true
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            self.dismiss(animated: false, completion: nil)
            self.delegate?.slidingSheetControllerDidDismiss(self)
        }
    }
    
    // MARK: - SlidingSheetViewDelegate
    
    public func slidingSheetView(_ view: SlidingSheetView, heightDidChange y: CGFloat) {
        UIView.animate(withDuration: 0.1) { // fade the background color
            self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(y / self.view.frame.height)
        }
    }
    
    public func slidingSheetViewRequestForDismission(_ view: SlidingSheetView) {
        dismissSheet()
    }
    
    public func slidingSheetView(_ view: SlidingSheetView, willMoveTo position: SlidingSheetView.Position) {
        delegate?.slidingSheetController(self, willMoveTo: position)
    }
    
    public func slidingSheetView(_ view: SlidingSheetView, didMoveFrom fromPosition: SlidingSheetView.Position, to toPosition: SlidingSheetView.Position) {
        delegate?.slidingSheetController(self, didMoveFrom: fromPosition, to: toPosition)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldReceive touch: UITouch) -> Bool {
        
        let isDescendantOfSliding = touch.view?.isDescendant(of: slidingSheetView) ?? false
        return !isDescendantOfSliding
    }
    
}

