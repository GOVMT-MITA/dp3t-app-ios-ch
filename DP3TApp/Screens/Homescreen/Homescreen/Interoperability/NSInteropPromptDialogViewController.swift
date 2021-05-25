/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation
import SafariServices

class NSInteropPromptDialogViewController: NSTitleViewScrollViewController {
    
    private let foregroundImageView = UIImageView()
    private let titleLabel = NSLabel(.title, textAlignment: .center)
    private let textLabel = NSLabel(.textLight, textAlignment: .center)
    
    private let privacyButton = NSExternalLinkButton(style: .normal(color: .ns_blue))
    private let interopButton = NSButton(title: "onboarding_select_button".ub_localized, style: .normal(.ns_blue))
    private let continueButton = NSButton(title: "onboarding_skip_button".ub_localized, style: .borderless(.ns_blue))
    
    // MARK: - Init
    override init() {
        super.init()
        title = "interop_mode_title".ub_localized
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .setColorsForTheme(lightColor: .ns_backgroundSecondary, darkColor: .ns_background)
        
        setupStackScrollView()
        setupLayout()

        interopButton.touchUpCallback = {
            let interopModal = NSModalViewController(contentViewController: NSInteropSettingsViewController(), hasCloseButton: true)
            self.present(NSNavigationController(rootViewController: interopModal), animated: true) {
                self.continueButton.title = ("onboarding_continue_button".ub_localized)
                self.continueButton.titleLabel?.font = NSLabelType.button.font
                self.continueButton.style = .normal(.ns_blue)
            }
        }
        
        continueButton.touchUpCallback = {
            self.dismiss(animated: true)
        }
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
        stackScrollView.addSpacerView(NSPadding.large * 2)
        
        foregroundImageView.image = UIImage(named: "onboarding-interop")!
        foregroundImageView.contentMode = .scaleAspectFit
        stackScrollView.addArrangedView(foregroundImageView, spacing: NSPadding.medium)

        let sidePadding = UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large)
        
        titleLabel.text = "interop_mode_title".ub_localized
        stackScrollView.addArrangedView(titleLabel, spacing: NSPadding.medium, insets: sidePadding)
        
        textLabel.text = "interop_mode_update_description".ub_localized
        stackScrollView.addArrangedView(textLabel, spacing: NSPadding.medium, insets: sidePadding)
        
        privacyButton.title = "onboarding_disclaimer_legal_button".ub_localized
        privacyButton.accessibilityHint = "onboarding_disclaimer_legal_button".ub_localized
        privacyButton.touchUpCallback = { [weak self] in
            if let url = URL(string: "onboarding_disclaimer_legal_button_url".ub_localized) {
                let vc = SFSafariViewController(url: url)
                vc.modalPresentationStyle = .popover
                self?.present(vc, animated: true)
            }
        }
        
        stackScrollView.addArrangedView(privacyButton, spacing: NSPadding.large, insets: sidePadding)
        
        stackScrollView.addArrangedView(UIView(), spacing: 0, insets: UIEdgeInsets(top: NSPadding.medium, left: 0, bottom: 0, right: 0))
        
        stackScrollView.addArrangedView(interopButton, spacing: NSPadding.small, insets: UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large))
        
        continueButton.titleLabel?.font = NSLabelType.smallButton.font
        stackScrollView.addArrangedView(continueButton, spacing: NSPadding.small, insets: UIEdgeInsets(top: NSPadding.medium, left: NSPadding.large, bottom: 0, right: NSPadding.large))

        titleLabel.accessibilityTraits = [.header]
    }
}
