/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

class NSFontSize {
    private static let normalBodyFontSize: CGFloat = 16.0

    public static func bodyFontSize() -> CGFloat {
        // default from system is 17.
        let bfs = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.body).pointSize - 1.0

        let preferredSize: CGFloat = normalBodyFontSize
        let maximum: CGFloat = 1.5 * preferredSize
        let minimum: CGFloat = 0.5 * preferredSize

        return min(max(minimum, bfs), maximum)
    }

    public static let fontSizeMultiplicator: CGFloat = {
        max(1.0, bodyFontSize() / normalBodyFontSize)
    }()
}

public enum NSLabelType: UBLabelType {
    case title
    case subtitle
    case splashTitle
    case textLight
    case smallLight
    case textBold
    case smallBold
    case ultraSmallBold
    case button // used for button
    case smallButton // used for button
    case uppercaseBold
    case date
    case smallRegular
    case interRegular
    case interBold
    case buttonLabel
    case largeButton // used for button

    public var font: UIFont {
        let bfs = NSFontSize.bodyFontSize()

        var boldFontName = "Inter-Bold"
        var regularFontName = "Inter-Regular"
        var lightFontName = "Inter-Light"

        switch UITraitCollection.current.legibilityWeight {
        case .bold:
            boldFontName = "Inter-ExtraBold"
            regularFontName = "Inter-Bold"
            lightFontName = "Inter-Medium"
        default:
            break
        }

        switch self {
        case .title: return UIFont(name: boldFontName, size: bfs + 8.0)!
        case .subtitle: return UIFont(name: boldFontName, size: bfs + 4.0)!
        case .splashTitle: return UIFont(name: boldFontName, size: bfs + 11.0)!
        case .textLight: return UIFont(name: lightFontName, size: bfs)!
        case .smallLight: return UIFont(name: lightFontName, size: bfs - 3.0)!
        case .textBold: return UIFont(name: boldFontName, size: bfs - 1.0)!
        case .smallBold: return UIFont(name: boldFontName, size: bfs - 3.0)!
        case .ultraSmallBold: return UIFont(name: boldFontName, size: bfs - 5.0)!
        case .button: return UIFont(name: boldFontName, size: bfs)!
        case .smallButton: return UIFont(name: boldFontName, size: bfs - 3.0)!
        case .uppercaseBold: return UIFont(name: boldFontName, size: bfs)!
        case .date: return UIFont(name: boldFontName, size: bfs - 3.0)!
        case .smallRegular: return UIFont(name: regularFontName, size: bfs - 3.0)!
        case .interRegular: return UIFont(name: regularFontName, size: bfs - 3.0)!
        case .interBold: return UIFont(name: boldFontName, size: bfs - 3.0)!
        case .buttonLabel: return UIFont(name: regularFontName, size: bfs)!
        case .largeButton: return UIFont(name: boldFontName, size: bfs + 2.0)!
        }
    }

    public var textColor: UIColor {
        switch self {
        case .button, .splashTitle:
            return .white
        case .smallRegular:
            return UIColor.black.withAlphaComponent(0.28).withHighContrastColor(color: UIColor.black.withAlphaComponent(0.7))
        default:
            return .ns_text
        }
    }

    public var lineSpacing: CGFloat {
        return 1.1
    }

    public var letterSpacing: CGFloat? {
        if self == .uppercaseBold {
            return 1.0
        }

        if self == .date {
            return 0.5
        }

        if self == .smallRegular || self == .smallLight || self == .smallBold {
            return 0.3
        }

        return nil
    }

    public var isUppercased: Bool {
        if self == .uppercaseBold {
            return true
        }

        return false
    }

    public var hyphenationFactor: Float {
        return 0.0
    }

    public var lineBreakMode: NSLineBreakMode {
        if self == .splashTitle { return .byWordWrapping }
        return .byTruncatingTail
    }
}

class NSLabel: UBLabel<NSLabelType> {
    private var labelType: NSLabelType

    override init(_ type: NSLabelType, textColor: UIColor? = nil, numberOfLines: Int = 0, textAlignment: NSTextAlignment = .left) {
        labelType = type
        super.init(type, textColor: textColor, numberOfLines: numberOfLines, textAlignment: textAlignment)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            font = labelType.font
        }
    }
}
