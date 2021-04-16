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

class NSOnboardingInteroperabilityViewController: NSOnboardingContentViewController {
    private let foregroundImageView = UIImageView()
    private let titleLabel = NSLabel(.title, textAlignment: .center)
    private let textLabel = NSLabel(.textLight, textAlignment: .center)

    let interopButton = NSButton(title: "onboarding_select_button".ub_localized, style: .normal(.ns_blue))
    let continueButton = NSButton(title: "onboarding_skip_button".ub_localized, style: .borderless(.ns_blue))
    
    private let interopUnavailableContainer = UIView()
    
    private let goodToKnowContainer = UIView()
    private let goodToKnowLabel = NSLabel(.textLight, textColor: .ns_blue)

    private let background = UIView()

    private var elements: [Any] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        elements = [titleLabel, textLabel, goodToKnowContainer].compactMap { $0 }
        setupViews()
        fillViews()

        elements.append(interopButton)
        elements.append(continueButton)
        elements.append(interopUnavailableContainer)
        accessibilityElements = elements.compactMap { $0 }
        
        //Prevent interop prompt in future app launches
        UserStorage.shared.requireInteropPromptDialog = false;
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    private func setupViews() {
        addArrangedView(foregroundImageView, spacing: NSPadding.medium)

        let sidePadding = UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large)
        addArrangedView(titleLabel, spacing: NSPadding.medium, insets: sidePadding)
        addArrangedView(textLabel, spacing: NSPadding.large + NSPadding.medium, insets: sidePadding)
        
        if(!UserStorage.shared.interopPossible) {
            let interopUnavailableIcon = UIImageView()
            interopUnavailableIcon.image = UIImage(named: "ic-error")?.withRenderingMode(.alwaysOriginal)
            interopUnavailableIcon.ub_setContentPriorityRequired()
            interopUnavailableIcon.contentMode = .scaleAspectFit
            interopUnavailableContainer.addSubview(interopUnavailableIcon)
            
            let interopUnavailableLabel = NSLabel(.textBold, textAlignment: .left)
            interopUnavailableLabel.text = "interop_mode_unavailable_text".ub_localized
            interopUnavailableContainer.addSubview(interopUnavailableLabel)

            interopUnavailableIcon.snp.makeConstraints { make in
                make.leading.equalToSuperview().inset(NSPadding.small)
                make.centerY.equalToSuperview()
                make.size.equalTo(30)
            }

            interopUnavailableLabel.snp.makeConstraints { make in
                make.leading.equalTo(interopUnavailableIcon.snp.trailing).inset(-NSPadding.medium)
                make.top.bottom.trailing.equalToSuperview().inset(NSPadding.medium)
            }
            
            addArrangedView(interopUnavailableContainer, spacing: 0, insets: sidePadding)
        } else {
            addArrangedView(interopButton, spacing: NSPadding.small, insets: UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large))
        }
        
        addArrangedView(continueButton, spacing: NSPadding.small, insets: UIEdgeInsets(top: NSPadding.medium, left: NSPadding.large, bottom: 0, right: NSPadding.large))

        addArrangedView(UIView(), spacing: 0, insets: UIEdgeInsets(top: NSPadding.large, left: 0, bottom: 0, right: 0))
        addArrangedView(goodToKnowContainer)

        background.backgroundColor = .setColorsForTheme(lightColor: .ns_backgroundSecondary, darkColor: .ns_background)
        background.alpha = 0

        view.insertSubview(background, at: 0)
        background.snp.makeConstraints { make in
            make.top.equalTo(goodToKnowContainer)
            make.bottom.equalTo(goodToKnowContainer).offset(2000)
            make.leading.trailing.equalToSuperview()
        }

        titleLabel.accessibilityTraits = [.header]
    }

    private func fillViews() {
        goodToKnowLabel.text = "onboarding_good_to_know".ub_localized
        goodToKnowContainer.addSubview(goodToKnowLabel)
        goodToKnowLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(2 * NSPadding.medium)
        }

        foregroundImageView.image = UIImage(named: "onboarding-interop")!
        titleLabel.text = "interop_mode_title".ub_localized
        textLabel.text = "interop_mode_summary".ub_localized
        
        continueButton.titleLabel?.font = NSLabelType.smallButton.font

        let info = NSOnboardingInfoView(icon: UIImage(named: "ic-info")!, text: "onboarding_interop_info_text_1".ub_localized, title: "onboarding_interop_info_title_1".ub_localized, link: "", dynamicIconTintColor: .ns_blue)
        elements.append(info)
        goodToKnowContainer.addSubview(info)
        info.snp.makeConstraints { make in
            make.top.equalTo(goodToKnowLabel.snp.bottom).offset(2 * NSPadding.medium)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(2 * NSPadding.medium)
        }
    }

    override func fadeAnimation(fromFactor: CGFloat, toFactor: CGFloat, delay: TimeInterval, completion: ((Bool) -> Void)?) {
        super.fadeAnimation(fromFactor: fromFactor, toFactor: toFactor, delay: delay, completion: completion)

        setViewState(view: background, factor: fromFactor)

        UIView.animate(withDuration: 0.5, delay: delay + 4 * 0.05, options: [.beginFromCurrentState], animations: {
            self.setViewState(view: self.background, factor: toFactor)
        }, completion: nil)
    }
}
