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

class NSInformationView: NSModuleBaseView {

    var informationInfoBoxView : NSInfoBoxView = {
        var viewModel = NSInfoBoxView.ViewModel(title: "information_text".ub_localized,
                                                subText: "".ub_localized,
                                                image: UIImage(named: "ic-info-outline"),
                                                titleColor: .ns_text,
                                                subtextColor: .ns_text,
                                                additionalURL: "information_url".ub_localized,
                                                titleLabelType: .textBold)
        return .init(viewModel: viewModel)
    }()

    override init() {
        super.init()

        headerTitle = "information_title".ub_localized

        updateUI()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sectionViews() -> [UIView] {
        return [informationInfoBoxView]
    }

    private func updateUI() {
        stackView.setNeedsLayout()
        updateLayout()
        stackView.layoutIfNeeded()
    }
}
