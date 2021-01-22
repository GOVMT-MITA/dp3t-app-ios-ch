//
/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import SnapKit
import UIKit

class NSLastSyncronizationControl: UIControl {
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return df
    }()

    private static let nullDateValueString = ""

    private let titleLabel = NSLabel(.interBold)
    private let subtitleLabel = NSLabel(.interRegular)
    private let chevronImageView = NSImageView(image: UIImage(named: "ic-chevron"), dynamicColor: .ns_text)

    var isChevronImageViewHidden: Bool {
        get { chevronImageView.isHidden }
        set { chevronImageView.isHidden = newValue }
    }

    var lastSyncronizationDate: Date? {
        didSet {
            guard let lastSyncronizationDate = lastSyncronizationDate else {
                subtitleLabel.text = Self.nullDateValueString
                return
            }
            subtitleLabel.text = dateFormatter.string(from: lastSyncronizationDate)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .ns_moduleBackground
        layer.cornerRadius = 3.0
        ub_addShadow(radius: 4.0, opacity: 0.05, xOffset: 0, yOffset: -2)

        accessibilityTraits = [.header]
        isAccessibilityElement = true
        titleLabel.text = "begegnung_detail_last_sync_title".ub_localized
        titleLabel.isAccessibilityElement = false
        subtitleLabel.isAccessibilityElement = false

        subtitleLabel.text = Self.nullDateValueString

        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 2.0 * NSPadding.medium, leading: 2.0 * NSPadding.medium, bottom: 2.0 * NSPadding.medium, trailing: 2.0 * NSPadding.medium)
        buildUILayout()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildUILayout() {
        addSubview(chevronImageView)
        addSubview(subtitleLabel)
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.top.equalTo(layoutMarginsGuide)
            make.trailing.lessThanOrEqualTo(chevronImageView.snp.leading)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.lessThanOrEqualTo(chevronImageView.snp.leading)
            make.top.equalTo(titleLabel.snp.bottom).offset(NSPadding.small)
            make.bottom.equalTo(layoutMarginsGuide)
        }

        chevronImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(layoutMarginsGuide)
        }
    }

    // MARK: User feedback

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .ns_background_highlighted : .ns_moduleBackground
        }
    }

    override var accessibilityLabel: String? {
        get {
            if let date = lastSyncronizationDate {
                return "\("begegnung_detail_last_sync_title".ub_localized) \(dateFormatter.string(from: date))"
            } else {
                return "begegnung_detail_no_last_sync_accessibility".ub_localized
            }
        }
        set {}
    }
}
