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

class NSOnboardingLanguageSelectionViewController: NSOnboardingContentViewController {
    private let foregroundImageView = UIImageView()
    private let languageENLabel = NSLabel(.title, textAlignment: .center)
    private let languageMTLabel = NSLabel(.title, textAlignment: .center)

    let languageENButton = NSButton(title: "", style: .normal(.ns_blue))
    let languageMTButton = NSButton(title: "", style: .normal(.ns_blue))
        
    private var elements: [Any] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        elements = [languageENLabel, languageMTLabel].compactMap { $0 }
        setupViews()
        fillViews()

        elements.append(languageENButton)
        elements.append(languageMTButton)
        accessibilityElements = elements.compactMap { $0 }
    }

    private func setupViews() {
        addArrangedView(foregroundImageView, spacing: NSPadding.large, insets: UIEdgeInsets(top: NSPadding.large * 4, left: 0, bottom: 0, right: 0))

        let sidePadding = UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large)
        addArrangedView(languageENLabel, spacing: NSPadding.large, insets: sidePadding)
        addArrangedView(languageMTLabel, spacing: 1.5 * NSPadding.large, insets: sidePadding)
        addArrangedView(languageENButton, spacing: NSPadding.large, insets: UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large))
        addArrangedView(languageMTButton, spacing: NSPadding.large, insets: UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large))

        languageENLabel.accessibilityTraits = [.header]
        languageMTLabel.accessibilityTraits = [.header]
    }

    private func fillViews() {
        foregroundImageView.image = UIImage(named: "onboarding-report")!
        languageENLabel.text = "onboarding_language_title_en".ub_localized
        languageMTLabel.text = "onboarding_language_title_mt".ub_localized
        languageENButton.title = "onboarding_language_button_text_en".ub_localized
        languageMTButton.title = "onboarding_language_button_text_mt".ub_localized
    }

    override func fadeAnimation(fromFactor: CGFloat, toFactor: CGFloat, delay: TimeInterval, completion: ((Bool) -> Void)?) {
        super.fadeAnimation(fromFactor: fromFactor, toFactor: toFactor, delay: delay, completion: completion)
    }
}
