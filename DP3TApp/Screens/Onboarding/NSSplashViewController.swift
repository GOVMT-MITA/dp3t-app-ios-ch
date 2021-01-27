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

class NSSplashViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .setColorsForTheme(lightColor: .ns_background, darkColor: .ns_darkModeBackground2)

        let imgView = traitCollection.userInterfaceStyle == .light ? UIImageView(image: UIImage(named: "splash")) : UIImageView(image: UIImage(named: "splash_dark"))

        view.addSubview(imgView)

        imgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        imgView.ub_setContentPriorityRequired()
    }
}
