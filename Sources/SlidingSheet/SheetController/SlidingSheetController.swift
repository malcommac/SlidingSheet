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
    
    // MARK: - Public Properties
    
    /// Delegate of the events available via the controller.
    public weak var delegate: SlidingSheetControllerDelegate?
    
    /// Instance of the sheet view.
    public private(set) var sheetView: SlidingSheetView
    
    /// Background view outside the frame of the sheet.
    public private(set) var backgroundView = UIView()
    
    // MARK: - Private Properties
    
    /// Tap gesture used to dismiss the sheet outside its frame.
    private var tapGesture = UITapGestureRecognizer()
    
    /// Height constraint of the sheet.
    private var heightConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    
    /// Initialize a new sliding sheet controller with a sliding sheet view based upon
    /// passed configuration object.
    ///
    /// - Parameter config: configuration.
    public convenience init(config: SlidingSheetView.Config) {
        let sheetView = SlidingSheetView(config: config)
        self.init(sheetView: sheetView)
    }
    
    /// Initialize a new controller with passed instance of the sliding sheet.
    ///
    /// - Parameter slidingSheetView: sliding sheet view.
    public init(sheetView: SlidingSheetView) {
        self.sheetView = sheetView
        super.init(nibName: nil, bundle: nil)
        setupUIPresentation()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    /// Present the sheet from a parent view controller.
    ///
    /// - Parameter vc: view controller which present `self`.
    public func present(from vc: UIViewController) {
        vc.present(self, animated: false)
    }
    
    // MARK: - View Life-cycle
 
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupTapGesture()
    }
 
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
    }
    
    // MARK: - Private Methods
    
    /// Setup the user interface.
    private func setupUIPresentation() {
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationCapturesStatusBarAppearance = true
    }
    
    /// Setup the interface elements.
    private func setupUI() {
        backgroundView.backgroundColor = .clear
        sheetView.delegate = self
        
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
        self.view.addSubview(sheetView)
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sheetView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            sheetView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            sheetView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        self.heightConstraint = sheetView.heightAnchor.constraint(equalToConstant: 0)
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        sheetView.setupLayout(animated: true)
    }
    
    /// Setup the tap gesture used to dismiss the sheet outside its frame.
    private func setupTapGesture() {
        tapGesture.addTarget(self, action: #selector(onTap(sender:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func onTap(sender: UITapGestureRecognizer) {
        let isTapOutsideSliding = !sheetView.frame.contains(sender.location(in: view))
        if sheetView.config.isDismissable, isTapOutsideSliding {
            dismissSheet()
        }
    }
    
    /// Dismiss the sheet.
    private func dismissSheet() {
        delegate?.slidingSheetControllerWillDismiss(self)
        
        heightConstraint?.isActive = false
        heightConstraint = sheetView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint?.isActive = true
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            self.dismiss(animated: false, completion: nil)
            self.delegate?.slidingSheetControllerDidDismiss(self)
        }
    }
    
    // MARK: - SlidingSheetViewDelegate
    
    public func slidingSheetView(_ view: SlidingSheetView,
                                 heightDidChange height: CGFloat) {
        let percentage = (height / self.view.frame.height)
        
        if sheetView.config.dimmedBackground {
            UIView.animate(withDuration: 0.1) { // fade the background color
                self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(percentage)
            }
        }
        
        delegate?.slidingSheetView(self, heightDidChange: height, percentage: percentage)
    }
    
    public func slidingSheetViewRequestForDismission(_ view: SlidingSheetView) {
        dismissSheet()
    }
    
    public func slidingSheetView(_ view: SlidingSheetView,
                                 willMoveTo position: SlidingSheetView.Position) {
        delegate?.slidingSheetController(self, willMoveTo: position)
    }
    
    public func slidingSheetView(_ view: SlidingSheetView,
                                 didMoveFromPosition position: SlidingSheetView.Position?,
                                 toPosition: SlidingSheetView.Position) {
        delegate?.slidingSheetController(self, didMoveFrom: position, to: toPosition)
    }
    
    public func slidingSheetViewScrollViewDidChangeOffset(_ view: SlidingSheetView,
                                                          scrollView: UIScrollView,
                                                          offset: CGPoint) {
        delegate?.slidingSheetController(self, innerScrollView: scrollView, didChangeOffset: offset)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldReceive touch: UITouch) -> Bool {
        
        let isDescendentOfSheet = touch.view?.isDescendant(of: sheetView) ?? false
        return !isDescendentOfSheet
    }
    
}

