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

class NSInteropModuleView: NSModuleBaseView {
    var uiState: UIStateModel.Interoperability = UIStateModel.Interoperability(interopPossible: false, interopState: UIStateModel.InteroperabilityState.legacy, interopSelectedCountries: []) {
        didSet { updateUI() }
    }
    
    let interopUnavailable: NSInfoBoxView = {
        var viewModel = NSInfoBoxView.ViewModel(title: "interop_mode_unavailable_title".ub_localized,
                                                subText: "interop_mode_unavailable_text".ub_localized,
                                                image: UIImage(named: "ic-header-error"),
                                                titleColor: .white,
                                                subtextColor: .white)
        viewModel.illustration = UIImage(named: "img_cooperation")!
        viewModel.backgroundColor = .ns_lightBlue
        viewModel.dynamicIconTintColor = .white
        return .init(viewModel: viewModel)
    }()
    
    let interopLegacy: NSInfoBoxView = {
        var viewModel = NSInfoBoxView.ViewModel(title: "interop_mode_legacy_title".ub_localized,
                                                subText: "interop_mode_legacy_text".ub_localized,
                                                image: UIImage(named: "ic-header-error"),
                                                titleColor: .ns_text,
                                                subtextColor: .ns_text)
        viewModel.illustration = UIImage(named: "img_cooperation")!
        viewModel.backgroundColor = .ns_yellow
        viewModel.dynamicIconTintColor = .ns_text
        return .init(viewModel: viewModel)
    }()
    
    let interopDisabled: NSInfoBoxView = {
        var viewModel = NSInfoBoxView.ViewModel(title: "interop_mode_disabled_title".ub_localized,
                                                subText: "interop_mode_disabled_text_alt".ub_localized,
                                                image: UIImage(named: "ic-info"),
                                                titleColor: .white,
                                                subtextColor: .white)
        viewModel.illustration = UIImage(named: "img_cooperation")!
        viewModel.backgroundColor = .ns_lightBlue
        viewModel.dynamicIconTintColor = .white
        return .init(viewModel: viewModel)
    }()
    
    let interopCountries: NSInfoBoxView = {
        var viewModel = NSInfoBoxView.ViewModel(title: "interop_mode_countries_title".ub_localized,
                                                subText: "interop_mode_countries_text_alt".ub_localized,
                                                image: UIImage(named: "ic-check"),
                                                titleColor: .white,
                                                subtextColor: .white)
        viewModel.illustration = UIImage(named: "img_cooperation")!
        viewModel.backgroundColor = .ns_purple
        viewModel.dynamicIconTintColor = .white
        return .init(viewModel: viewModel)
    }()
    
    let interopCountriesUpdatePending: NSInfoBoxView = {
        var viewModel = NSInfoBoxView.ViewModel(title: "interop_mode_countries_title".ub_localized,
                                                subText: "interop_mode_countries_update_pending_text".ub_localized,
                                                image: UIImage(named: "ic-header-error"),
                                                titleColor: .ns_text,
                                                subtextColor: .ns_text)
        viewModel.illustration = UIImage(named: "img_cooperation")!
        viewModel.backgroundColor = .ns_yellow
        viewModel.dynamicIconTintColor = .ns_text
        return .init(viewModel: viewModel)
    }()
    
    let interopEU: NSInfoBoxView = {
        var viewModel = NSInfoBoxView.ViewModel(title: "interop_mode_eu_title".ub_localized,
                                                subText: "interop_mode_eu_text_alt".ub_localized,
                                                image: UIImage(named: "ic-check"),
                                                titleColor: .white,
                                                subtextColor: .white)
        viewModel.illustration = UIImage(named: "img_cooperation")!
        viewModel.backgroundColor = .ns_purple
        viewModel.dynamicIconTintColor = .white
        return .init(viewModel: viewModel)
    }()

    override init() {
        super.init()

        headerTitle = "interop_mode_title".ub_localized

        updateUI()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sectionViews() -> [UIView] {
        if(!uiState.interopPossible) {
            return [interopUnavailable]
        }
        
        switch uiState.interopState {
            case .legacy: return [interopLegacy]
            case .countries: return [interopCountries]
            case .countries_update_pending: return [interopCountriesUpdatePending]
            case .eu: return [interopEU]
            case .disabled:
                return [interopDisabled]
            default:
                return [interopDisabled]
        }
    }

    private func updateUI() {
        stackView.setNeedsLayout()
        updateLayout()
        headerView.showCaret = true
        isEnabled = true
        stackView.layoutIfNeeded()
    }
}
