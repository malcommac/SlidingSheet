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
    
    public class Config {
        
        public let contentView: UIView
        public let parentViewController: UIViewController
        public let initialPosition: Position
        public let allowedPositions: [Position]
        public let slideToAppear: Bool
        public let showPullIndicator: Bool
        public let dismissIcon: UIImage?
        public let isDismissable: Bool
        public let cornerRadius: CGFloat
        
        public init(contentView: UIView,
                    parentViewController: UIViewController,
                    initialPosition: Position = .atMiddle(),
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

extension SlidingSheetView {
    
    public enum Position {
        case fitContent
        case fixed(CGFloat)
        case atTop(CGFloat = Defaults.top)
        case atMiddle(CGFloat = Defaults.middle)
        case atBottom(CGFloat = Defaults.bottom)
        
        public var height: CGFloat {
            switch self {
            case .fitContent: return 0
            case let .fixed(h): return h
            case let .atTop(h): return h
            case let .atBottom(h): return h
            case let .atMiddle(h): return h
            }
        }
        
        public enum Defaults {
            static let navigationBarHeight = CGFloat(60)
            static let keyboard = CGFloat(100)
            
            public static let top: CGFloat = UIScreen.main.bounds.height -
                                             UIApplication.shared.statusBarFrame.height - navigationBarHeight
            public static let middle: CGFloat = UIScreen.main.bounds.height / 2 + keyboard
            public static let bottom = CGFloat(100)
        }
    }
    
}
