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
import SafariServices

class NSReportsDetailPositiveTestedViewController: NSTitleViewScrollViewController {
    // MARK: - Init
    
    private let quarantineButton = NSExternalLinkButton(style: .normal(color: .ns_purple))
    
    override init() {
        super.init()
        titleView = NSReportsDetailPositiveTestedTitleView()
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }

    override var titleHeight: CGFloat {
        return super.titleHeight * NSFontSize.fontSizeMultiplicator
    }

    override var startPositionScrollView: CGFloat {
        return titleHeight - 30
    }

    // MARK: - Setup

    private func setupLayout() {
        
        quarantineButton.title = "meldung_detail_positive_test_box_link".ub_localized
        quarantineButton.accessibilityHint = "meldung_detail_positive_test_box_link".ub_localized
        quarantineButton.touchUpCallback = { [weak self] in
            if let url = URL(string: "meldung_detail_positive_test_box_url".ub_localized) {
                let vc = SFSafariViewController(url: url)
                vc.modalPresentationStyle = .popover
                self?.present(vc, animated: true)
            }
        }
        
        let whiteBoxView = NSSimpleModuleBaseView(title: "meldung_detail_positive_test_box_title".ub_localized, subtitle: "meldung_detail_positive_test_box_subtitle".ub_localized, subview: quarantineButton, text: "meldung_detail_positive_test_box_text".ub_localized, image: UIImage(named: "illu-self-isolation"), subtitleColor: .ns_purple, bottomPadding: false)

        addDeleteButton(whiteBoxView)
        
        stackScrollView.addSpacerView(NSPadding.large)

        stackScrollView.addArrangedView(whiteBoxView)

        stackScrollView.addSpacerView(NSPadding.large)

        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-tracing")!.ub_image(with: .ns_purple)!, text: "meldungen_positive_tested_faq1_text_alt".ub_localized, title: "meldungen_positive_tested_faq1_title".ub_localized, link: "", leftRightInset: 0, dynamicIconTintColor: .ns_purple))

        stackScrollView.addSpacerView(NSPadding.medium)

        stackScrollView.addArrangedView(NSButton.faqButton(color: .ns_purple))

        stackScrollView.addSpacerView(NSPadding.large)
    }

    private func addDeleteButton(_ whiteBoxView: NSSimpleModuleBaseView) {
        whiteBoxView.contentView.addSpacerView(NSPadding.large)

        whiteBoxView.contentView.addDividerView(inset: -NSPadding.large)

        let deleteButton = NSButton(title: "delete_infection_button".ub_localized, style: .borderless(.ns_purple))

        let container = UIView()
        whiteBoxView.contentView.addArrangedView(container)

        container.addSubview(deleteButton)

        deleteButton.highlightCornerRadius = 0

        deleteButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.centerX.top.bottom.equalToSuperview()
            make.width.equalToSuperview().inset(-2 * 12.0)
        }

        deleteButton.setContentHuggingPriority(.required, for: .vertical)

        deleteButton.touchUpCallback = { [weak self] in

            deleteButton.touchUpCallback = {
                let alert = UIAlertController(title: nil, message: "delete_infection_dialog".ub_localized, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "delete_infection_button".ub_localized, style: .destructive, handler: { _ in
                    TracingManager.shared.deletePositiveTest()
                }))
                alert.addAction(UIAlertAction(title: "cancel".ub_localized, style: .cancel, handler: { _ in

                }))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
}
