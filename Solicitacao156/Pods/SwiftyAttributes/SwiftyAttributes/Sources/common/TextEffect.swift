//
//  TextEffect.swift
//  SwiftyAttributes
//
//  Created by Eddie Kaiger on 10/28/16.
//  Copyright © 2016 Eddie Kaiger. All rights reserved.
//

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

/**
 An enum describing the possible values for text effects on attributed strings.
 */
public enum TextEffect: RawRepresentable {

    /// A graphical text effect giving glyphs the appearance of letterpress printing, in which type is pressed into the paper.
    case letterPressStyle

    public init?(rawValue: String) {
        #if swift(>=4.0)
            switch rawValue {
            case NSAttributedString.TextEffectStyle.letterpressStyle.rawValue: self = .letterPressStyle
            default: return nil
            }
        #else
            switch rawValue {
            case NSTextEffectLetterpressStyle: self = .letterPressStyle
            default: return nil
            }
        #endif
    }

    public var rawValue: String {
        switch self {
        case .letterPressStyle:
            #if swift(>=4.0)
                return NSAttributedString.TextEffectStyle.letterpressStyle.rawValue
            #else
                return NSTextEffectLetterpressStyle
            #endif
        }
    }
}