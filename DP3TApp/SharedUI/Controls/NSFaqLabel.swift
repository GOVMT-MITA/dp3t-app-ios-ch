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

import UIKit

class NSFaqLabel: UIView {
    
    private let leadingIconImageView = UIImageView()
    private let textLabel = NSLabel(.uppercaseBold)

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(color: UIColor? = .ns_blue) {
        super.init(frame: .zero)
        
        self.clipsToBounds = false
        self.isUserInteractionEnabled = true
        
        let topBottomPadding: CGFloat = 0
        
        leadingIconImageView.ub_setContentPriorityRequired()
        leadingIconImageView.image = UIImage(named: "ic_launch_blue")?.withRenderingMode(.alwaysTemplate)
        leadingIconImageView.tintColor = color
        
        self.addSubview(leadingIconImageView)
        leadingIconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().inset(topBottomPadding)
        }
        
        textLabel.text = "faq_button_title".ub_localized
        textLabel.textColor = color
        
        self.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(topBottomPadding + 3.0)
            make.leading.equalTo(self.leadingIconImageView.snp.trailing).offset(NSPadding.medium)
            make.trailing.equalToSuperview().inset(NSPadding.medium)
        }
        
        setupAccessibility(text: textLabel.text ?? "")
        
        let onTap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(onTap)
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        UIApplication.shared.open(URL(string: "faq_button_url".ub_localized)!, options: [:], completionHandler: nil)
    }
}

// MARK: - Accessibility

extension NSFaqLabel {
    private func setupAccessibility(text: String) {
        isAccessibilityElement = true
        accessibilityLabel = "\(text)"
    }
}
