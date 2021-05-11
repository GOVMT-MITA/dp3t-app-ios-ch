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

class NSModalViewController: NSViewController {
    // MARK: - Views

    private let contentViewController: NSViewController
    private let hasCloseButton: Bool
    
    // MARK: - Init

    init(contentViewController : NSViewController, hasCloseButton: Bool = false) {
        self.hasCloseButton = hasCloseButton
        self.contentViewController = contentViewController
        
        super.init()
        
        title = contentViewController.title
    }

    // MARK: - View Loading

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        if hasCloseButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didPressClose))
        }
    }

    // MARK: - Setup

    private func setup() {
        addChild(contentViewController)
        view.addSubview(contentViewController.view)
        contentViewController.didMove(toParent: self)

        contentViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.backgroundColor = UIColor.ns_backgroundSecondary

        contentViewController.view.isOpaque = false
        contentViewController.view.backgroundColor = UIColor.clear
    }
    
    // MARK: - Navigation

    @objc private func didPressClose() {
        dismiss(animated: true, completion: nil)
    }
}
