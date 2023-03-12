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

public protocol SlidingSheetControllerDelegate: AnyObject {
    
    func slidingSheetControllerWillDismiss(_ controller: SlidingSheetController)

    func slidingSheetControllerDidDismiss(_ controller: SlidingSheetController)
    
    func slidingSheetController(_ controller: SlidingSheetController,
                                willMoveTo position: SlidingSheetView.Position)
    
    func slidingSheetController(_ controller: SlidingSheetController,
                                didMoveFrom fromPosition: SlidingSheetView.Position,
                                to toPosition: SlidingSheetView.Position)
    
}
