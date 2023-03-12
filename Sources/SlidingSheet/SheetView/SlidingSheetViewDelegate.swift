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

import Foundation

/// The delegate of the events for the sliding sheet view.
public protocol SlidingSheetViewDelegate: AnyObject {
    
    /// Height of the sheet did change to a new value.
    ///
    /// - Parameters:
    ///   - view: sliding sheet.
    ///   - y: new value.
    func slidingSheetView(_ view: SlidingSheetView, heightDidChange y: CGFloat)
    
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
    ///   - fromPosition: old position.
    ///   - toPosition: new position.
    func slidingSheetView(_ view: SlidingSheetView,
                                didMoveFrom fromPosition: SlidingSheetView.Position,
                                to toPosition: SlidingSheetView.Position)
    func slidingSheetViewRequestForDismission(_ view: SlidingSheetView)
    
}
