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

/// The delegate to receive relevant information about the state of the sliding sheet.
public protocol SlidingSheetControllerDelegate: AnyObject {
    
    /// Height of the sheet did change to a new value.
    ///
    /// - Parameters:
    ///   - controller: controller.
    ///   - height: new value.
    ///   - percentage: which percentage of area is covered by the height of the slider.
    func slidingSheetView(_ controller: SlidingSheetController,
                          heightDidChange height: CGFloat,
                          percentage: CGFloat)
    
    /// The sheet is about to be dismissed.
    ///
    /// - Parameter controller: controller.
    func slidingSheetControllerWillDismiss(_ controller: SlidingSheetController)
    
    /// The sheet has been dismissed.
    ///
    /// - Parameter controller: controller.
    func slidingSheetControllerDidDismiss(_ controller: SlidingSheetController)
    
    /// The sheet is about to move to a new position.
    ///
    /// - Parameters:
    ///   - controller: controller.
    ///   - position: new position.
    func slidingSheetController(_ controller: SlidingSheetController,
                                willMoveTo position: SlidingSheetView.Position)
    
    /// The sheet did move to a new position.
    ///
    /// - Parameters:
    ///   - controller: controller.
    ///   - fromPosition: old position.
    ///   - toPosition: new position.
    func slidingSheetController(_ controller: SlidingSheetController,
                                didMoveFrom fromPosition: SlidingSheetView.Position?,
                                to toPosition: SlidingSheetView.Position)
    
    /// The inner scrollview specified by `contentView.scrollView` of the `SlidingSheetView` instance
    /// did change it's offset due to a scroll.
    ///
    /// - Parameters:
    ///   - controller: controller.
    ///   - scrollView: scroll view instance.
    ///   - offset: new offset.
    func slidingSheetController(_ controller: SlidingSheetController,
                                innerScrollView scrollView: UIScrollView,
                                didChangeOffset offset: CGPoint)

}
