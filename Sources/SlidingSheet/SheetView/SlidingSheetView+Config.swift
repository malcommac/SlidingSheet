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

extension SlidingSheetView {
    
    /// Define the configuration of used to create the bottom sheet.
    public class Config {
        
        // MARK: - Public Properties
        
        /// The content view to place into the bottom sheet.
        public let contentView: UIView
        
        /// Parent view controller, used as coordinate system for pan gesture.
        public let parentViewController: UIViewController
        
        /// Initial position of the bottom sheet.
        public var initialPosition: Position
        
        /// Allowed positions of the bottom sheet.
        public var allowedPositions: [Position]
        
        public var slideToAppear: Bool
        
        /// Show a system-like pull indicator to dismiss the sheet.
        public var showPullIndicator: Bool
        
        /// The dismiss button icon is a button placed on the top right of the sliding sheet
        /// used to dismiss explicitly the sheet itself.
        public var dismissIcon: UIImage?
        
        /// Margins from the top right of the slide where to place the button.
        public var dismissIconMargins: (top: CGFloat, right: CGFloat) = (16, -16)
        
        /// Set this value to non `nil` `CGSize` to set the size of the button to a value instead
        /// of using the size of the image passed in `dismissIcon`.
        public var dismissIconSize: CGSize?
        
        /// Can the bottom sheet dismissed totally.
        public var isDismissable: Bool
        
        /// Corner radius of the sheet. By default is set to `16`.
        public var cornerRadius = CGFloat(16)
        
        /// Vertical margins applied to the contentView.
        /// Bottom is applied only when `showPullIndicator` is `true`.
        public var contentViewVerticalMargins: (top: CGFloat, bottom: CGFloat) = (8, 16)
        
        /// Size of hte pull indicator.
        /// By default is set to `44x4`.
        public var pullIndicatorSize = CGSize(width: 44, height: 4)
        
        /// The color of the pull indicator.
        /// By default is a light gray color.
        public var pullIndicatorColor = UIColor(red: 229 / 255,
                                                green: 229 / 255,
                                                blue: 229 / 255,
                                                alpha: 1)
        
        
        
        // MARK: - Initialization
        
        public init(contentView: UIView,
                    parentViewController: UIViewController,
                    initialPosition: Position = .middle(),
                    allowedPositions: [Position],
                    slideToAppear: Bool = true,
                    showPullIndicator: Bool = true,
                    dismissIcon: UIImage? = nil,
                    isDismissable: Bool,
                    cornerRadius: CGFloat = 16
        ) {
            self.contentView = contentView
            self.parentViewController = parentViewController
            self.initialPosition = initialPosition
            self.allowedPositions = allowedPositions
            self.slideToAppear = slideToAppear
            self.showPullIndicator = showPullIndicator
            self.dismissIcon = dismissIcon
            self.isDismissable = isDismissable
            self.cornerRadius = cornerRadius
        }
    }
    
}

// MARK: - Position

extension SlidingSheetView {
    
    /// Allowed position of the bottom sheet.
    public enum Position {
        /// Fit the content height.
        case fitContent
        /// Fixed height.
        case fixed(CGFloat)
        /// On top with given margin value.
        case top(CGFloat = Defaults.top)
        /// On middle with given margin value.
        case middle(CGFloat = Defaults.middle)
        /// On bottom with given margin value.
        case bottom(CGFloat = Defaults.bottom)
        
        /// Return the value of the height for position.
        /// NOTE: In case of `fitContent` it returns `0`.
        public var height: CGFloat {
            switch self {
            case .fitContent: return 0
            case let .fixed(h): return h
            case let .top(h): return h
            case let .bottom(h): return h
            case let .middle(h): return h
            }
        }
    
    }
    
    // MARK: - Defaults
    
    /// Some defaults constants.
    public enum Defaults {
        static let overscrollFitContent = CGFloat(70)
        static let navigationBarHeight = CGFloat(60)
        static let keyboard = CGFloat(100)
        static let maxScreenHeight: CGFloat = UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height
        
        public static let top: CGFloat = UIScreen.main.bounds.height -
                                         UIApplication.shared.statusBarFrame.height - navigationBarHeight
        public static let middle: CGFloat = UIScreen.main.bounds.height / 2 + keyboard
        public static let bottom = CGFloat(100)
    }
    
}
