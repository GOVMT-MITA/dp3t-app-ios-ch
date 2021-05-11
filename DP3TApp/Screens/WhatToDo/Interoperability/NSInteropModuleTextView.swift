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

class NSInteropModuleTextView: NSModuleBaseView {
    var uiState: UIStateModel.Interoperability = UIStateModel.Interoperability(interopPossible: false, interopState: UIStateModel.InteroperabilityState.legacy, interopSelectedCountries: []) {
        didSet { updateUI() }
    }
    
    var interopSettingsButton = NSExternalLinkButton(style: .normal(color: .ns_purple))
    
    override init() {
        super.init()
        
        headerView.isHidden = true
        stackView.layoutMargins = UIEdgeInsets.zero
        backgroundColor = .clear
        
        updateUI()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sectionViews() -> [UIView] {
        if(!uiState.interopPossible) {
            return [NSOnboardingInfoView(icon: UIImage(named: "ic-header-error")!, text: "interop_mode_unavailable_text".ub_localized, title: "interop_mode_unavailable_title".ub_localized, link: "", leftRightInset: 0, dynamicIconTintColor: .ns_purple)]
        }
        
        //Retrieve interop text to show
        var interopTitle: String
        var interopText: String
                
        switch uiState.interopState {
            case .legacy:
                interopTitle = "interop_mode_legacy_title".ub_localized
                interopText = "interop_mode_legacy_text_alt".ub_localized
                break
            case .disabled, .disabled_silent:
                interopTitle = "interop_mode_disabled_title".ub_localized
                interopText = "interop_mode_disabled_text_alt".ub_localized
                break
            case .countries:
                interopTitle = "interop_mode_countries_title".ub_localized
                interopText = "interop_mode_countries_text_alt".ub_localized
                break
            case .countries_update_pending:
                interopTitle = "interop_mode_countries_title".ub_localized
                interopText = "interop_mode_countries_update_pending_text_alt".ub_localized
                break
            case .eu:
                interopTitle = "interop_mode_eu_title".ub_localized
                interopText = "interop_mode_eu_text_alt".ub_localized
                break
        }
        
        let interopInfoView = NSOnboardingInfoView(icon: UIImage(named: "ic-info")!, text: interopText, title: interopTitle, link: "", leftRightInset: 0, dynamicIconTintColor: .ns_purple)
        
        interopSettingsButton.title = "interop_mode_preferences".ub_localized
        interopSettingsButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: NSPadding.large + NSPadding.medium, bottom: 0, right: 0)
        
        return [interopInfoView, interopSettingsButton]
    }

    private func updateUI() {
        stackView.setNeedsLayout()
        updateLayout()
        headerView.showCaret = true
        isEnabled = true
        stackView.layoutIfNeeded()
    }
}
