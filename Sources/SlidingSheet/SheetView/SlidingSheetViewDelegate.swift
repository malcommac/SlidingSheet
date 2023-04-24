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

/// The delegate of the events for the sliding sheet view.
public protocol SlidingSheetViewDelegate: AnyObject {
    
    /// Height of the sheet did change to a new value.
    ///
    /// - Parameters:
    ///   - view: sliding sheet.
    ///   - height: new value.
    func slidingSheetView(_ view: SlidingSheetView,
                          heightDidChange height: CGFloat)
    
    /// Sheet will move to a new allowed position.
    ///
    /// - Parameters:
    ///   - view: sliding sheet.
    ///   - position: new position.
    func slidingSheetView(_ view: SlidingSheetView,
                          willMoveTo position: SlidingSheetView.Position)
    
    /// Sheet did moved to a new allowed position from another previous allowed position.
    ///
    /// - Parameters:
    ///   - view: sliding sheet.
    ///   - position: old position.
    ///   - newPosition: new position.
    func slidingSheetView(_ view: SlidingSheetView,
                          didMoveFromPosition position: SlidingSheetView.Position?,
                          toPosition newPosition: SlidingSheetView.Position)
    
    /// Sliding sheet did request a dismission to its controller.
    ///
    /// - Parameter view: sliding sheet.
    func slidingSheetViewRequestForDismission(_ view: SlidingSheetView)
    
    /// Called when you specify a `scrollView` as content view of the sliding sheet.
    /// It will report chnages in its offset.
    ///
    /// - Parameters:
    ///   - view: sliding sheet.
    ///   - scrollView: inner scroll view object of the `SlidingSheetView`'s `contentView.scrollView`.
    ///   - offset: new offset.
    func slidingSheetViewScrollViewDidChangeOffset(_ view: SlidingSheetView,
                                                   scrollView: UIScrollView,
                                                   offset: CGPoint)
    
}
