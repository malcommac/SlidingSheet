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
import SlidingSheet
import MapKit

public class MapsController: UIViewController {
    
    // MARK: - Public Properties
    
    @IBOutlet public var viewFilters: UIView!
    @IBOutlet public var mapView: MKMapView!

    // MARK: - Private Properties
    
    private var observeMapRegionChanges = false
    private var bottomSheetView: SlidingSheetView!
    private static let identifier = "MapsController"
    
    private var listController = ListController()
    
    // MARK: - Initialiation

    public static func create() -> MapsController {
        let s = UIStoryboard(name: MapsController.identifier, bundle: .main)
        return s.instantiateViewController(withIdentifier: MapsController.identifier) as! MapsController
    }
    
    // MARK: - View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Your Search Listings"
        
        listController.tableView.reloadData()
        listController.tableView.backgroundColor = .white
        
        setupBottomSheet()
        self.mapView.delegate = self
    
        // Must be called when not managed by `SlidingSheetController` directly.
        bottomSheetView?.setupLayout(animated: false)

    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        observeMapRegionChanges = true
    }
    
    // MARK: - Private Methods
    
    /// Get the margin on top to attach the sliding sheet to the bottom filters view bar.
    ///
    /// - Returns: CGFloat
    private func topHeightMargin() -> CGFloat {
        let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
        let filtersViewHeight = viewFilters.frame.height
        
        return (statusBarHeight + navigationBarHeight + filtersViewHeight - 20)
    }
    
    private func setupBottomSheet() {
        let configuration = SlidingSheetView.Config(
            contentView: listController,
            parentViewController: self,//self.tabBarController!,
            initialPosition: .middle(),
            allowedPositions: [
                .middle(),
                .top(UIScreen.main.bounds.height-topHeightMargin()),
                .bottom(150)
            ],
            showPullIndicator: true,
            isDismissable: false
        )
        
        self.bottomSheetView = SlidingSheetView(config: configuration)
        self.bottomSheetView.delegate = self
        
        view.addSubview(bottomSheetView!)
        bottomSheetView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        bottomSheetView.backgroundColor = .white
        self.view.sendSubviewToBack(bottomSheetView)
        self.view.sendSubviewToBack(mapView)

    }
}

// MARK: - MapsController + SlidingSheetViewDelegate

extension MapsController: SlidingSheetViewDelegate {
    
    public func slidingSheetViewScrollViewDidChangeOffset(_ view: SlidingSheet.SlidingSheetView, scrollView: UIScrollView, offset: CGPoint) {
        let threshold: CGFloat = -100
        if offset.y < threshold {
            view.moveToPosition(.bottom())
        }
    }
    
    public func slidingSheetView(_ view: SlidingSheet.SlidingSheetView, heightDidChange height: CGFloat) {
        
    }
    
    public func slidingSheetView(_ view: SlidingSheet.SlidingSheetView, willMoveTo position: SlidingSheet.SlidingSheetView.Position) {
        
    }
    
    public func slidingSheetView(_ view: SlidingSheet.SlidingSheetView, didMoveFrom fromPosition: SlidingSheet.SlidingSheetView.Position?, to toPosition: SlidingSheet.SlidingSheetView.Position) {
        
        // Modify appearance when fully expanded
        view.setAsAnchored(!toPosition.isTop)
        
        // Disable the pan gesture on top in order to avoid collpasing the sheet while moving inside table cells.
        view.slidePanGesture.isEnabled = !toPosition.isTop
        
        // Disable scrolling inside the table when collapsed.
        listController.tableView.isUserInteractionEnabled = toPosition.isTop
    }
    
    public func slidingSheetViewRequestForDismission(_ view: SlidingSheet.SlidingSheetView) {
        
    }
    
}

// MARK: - MapsController + MKMapViewDelegate

extension MapsController: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if observeMapRegionChanges { // dismiss when moving inside the map
            // used this because maps region changes when xib is loaded and frame is adjusted.
            bottomSheetView?.moveToPosition(.bottom())
        }
    }
    
}
