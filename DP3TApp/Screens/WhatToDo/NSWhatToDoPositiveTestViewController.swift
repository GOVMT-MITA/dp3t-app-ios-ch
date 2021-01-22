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

class NSWhatToDoPositiveTestViewController: NSViewController {
    // MARK: - Views

    private let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)
    private let informView = NSWhatToDoInformView()

    private let titleElement = UIAccessibilityElement(accessibilityContainer: self)
    private var titleContentStackView = UIStackView()
    private var subtitleLabel: NSLabel!
    private var titleLabel: NSLabel!

    private let configTexts: ConfigResponseBody.WhatToDoPositiveTestTexts?

    // MARK: - Init

    override init() {
        configTexts = ConfigManager.currentConfig?.whatToDoPositiveTestTexts?.value
        super.init()
        title = "inform_detail_navigation_title".ub_localized
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .setColorsForTheme(lightColor: .ns_backgroundSecondary, darkColor: .ns_background)

        setupStackScrollView()
        setupLayout()

        informView.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentInformViewController()
        }

        setupAccessibility()
    }

    // MARK: - Setup

    private func setupStackScrollView() {
        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupLayout() {
        titleContentStackView.axis = .vertical
        stackScrollView.addSpacerView(NSPadding.large)

        // Title & subtitle
        subtitleLabel = NSLabel(.textLight, textAlignment: .center)
        subtitleLabel.text = "inform_detail_subtitle".ub_localized

        titleLabel = NSLabel(.title, textAlignment: .center)
        titleLabel.text = "inform_detail_title".ub_localized

        titleContentStackView.addArrangedView(subtitleLabel)
        titleContentStackView.addArrangedView(titleLabel)
        titleContentStackView.addSpacerView(3.0)

        stackScrollView.addArrangedView(titleContentStackView)

        stackScrollView.addSpacerView(NSPadding.large)

        let imageView = UIImageView(image: UIImage(named: "img_positive"))
        imageView.contentMode = .scaleAspectFit
        stackScrollView.addArrangedView(imageView)

        stackScrollView.addSpacerView(NSPadding.medium)

        stackScrollView.addArrangedView(informView)

        stackScrollView.addSpacerView(NSPadding.medium)

        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-verified-user")!, text: "inform_detail_faq1_text".ub_localized, title: "inform_detail_faq1_title".ub_localized, link: "", leftRightInset: 0, dynamicIconTintColor: .ns_purple))

        let callButton = NSExternalLinkButton(style: .normal(color: .ns_purple))
        callButton.title = "infoline_coronavirus_number".ub_localized
        callButton.touchUpCallback = { [weak self] in
            self?.callButtonTouched()
        }
        callButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: NSPadding.large + NSPadding.medium, bottom: 0, right: 0)
        stackScrollView.addArrangedView(callButton)

        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-key-purple")!, text: "inform_detail_faq2_text".ub_localized, title: "inform_detail_faq2_title".ub_localized, link: "", leftRightInset: 0, dynamicIconTintColor: .ns_purple))

        stackScrollView.addSpacerView(NSPadding.medium)

        stackScrollView.addArrangedView(NSButton.faqButton(color: .ns_purple))

        stackScrollView.addSpacerView(NSPadding.medium)
    }

    private func callButtonTouched() {
        let phoneNumber = "infoline_coronavirus_number".ub_localized
        PhoneCallHelper.call(phoneNumber)
    }

    private func setupAccessibility() {
        titleContentStackView.isAccessibilityElement = true
        titleContentStackView.accessibilityTraits = [.header]
        titleContentStackView.accessibilityLabel = subtitleLabel.text!.deleteSuffix("...") + titleLabel.text!
    }

    // MARK: - Present
    private func presentInformViewController() {
        NSInformViewController.present(from: self)
    }
}
