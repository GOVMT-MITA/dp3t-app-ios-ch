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

class NSReportsDetailReportViewController: NSTitleViewScrollViewController {
    // MARK: - API

    public var reports: [UIStateModel.ReportsDetail.NSReportModel] = [] {
        didSet {
            guard oldValue != reports else { return }
            update()
        }
    }

    public var showReportWithAnimation: Bool = false

    public var phoneCallState: UIStateModel.ReportsDetail.PhoneCallState = .notCalled {
        didSet { update() }
    }

    // MARK: - Views

    private var callLabels = [NSLabel]()
    private var notYetCalledView: NSSimpleModuleBaseView?
    private var alreadyCalledView: NSSimpleModuleBaseView?
    private var callAgainView: NSSimpleModuleBaseView?

    private var daysLeftLabels = [NSLabel]()

    private var overrideHitTestAnyway: Bool = true

    // MARK: - Init

    override init() {
        super.init()
        titleView = NSReportsDetailReportTitleView(overlapInset: titleHeight - startPositionScrollView)

        stackScrollView.hitTestDelegate = self
    }

    override var useFullScreenHeaderAnimation: Bool {
        return UIAccessibility.isVoiceOverRunning ? false : showReportWithAnimation
    }

    override var titleHeight: CGFloat {
        return 260.0 * NSFontSize.fontSizeMultiplicator
    }

    override var startPositionScrollView: CGFloat {
        return titleHeight - 30
    }

    override func startHeaderAnimation() {
        overrideHitTestAnyway = false

        for report in reports {
            UserStorage.shared.registerSeenMessages(identifier: report.identifier)
        }

        super.startHeaderAnimation()
    }

    // MARK: - Views

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }

    // MARK: - Setup

    private func setupLayout() {
        notYetCalledView = makeNotYetCalledView()
        alreadyCalledView = makeAlreadyCalledView()
        callAgainView = makeCallAgainView()

        // !: function have return type UIView
        stackScrollView.addArrangedView(notYetCalledView!)
        stackScrollView.addArrangedView(alreadyCalledView!)
        stackScrollView.addArrangedView(callAgainView!)
        stackScrollView.addSpacerView(NSPadding.large)

        stackScrollView.addSpacerView(2 * NSPadding.large)

        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-call")!, text: "messages_messages_faq1_text".ub_localized, title: "messages_messages_faq1_title".ub_localized, link: "", leftRightInset: 0, dynamicIconTintColor: .ns_blue))

        stackScrollView.addSpacerView(3 * NSPadding.large)

        stackScrollView.addArrangedView(NSButton.faqButton(color: .ns_blue))

        stackScrollView.addSpacerView(NSPadding.large)
    }

    // MARK: - Update

    private func update() {
        if let tv = titleView as? NSReportsDetailReportTitleView {
            tv.reports = reports
        }

        notYetCalledView?.isHidden = phoneCallState != .notCalled
        alreadyCalledView?.isHidden = phoneCallState != .calledAfterLastExposure
        callAgainView?.isHidden = phoneCallState != .multipleExposuresNotCalled

        if let lastReportId = reports.last?.identifier,
            let lastCall = UserStorage.shared.lastPhoneCall(for: lastReportId) {
            callLabels.forEach {
                $0.text = "messages_detail_call_last_call".ub_localized.replacingOccurrences(of: "{DATE}", with: DateFormatter.ub_string(from: lastCall))
            }
            daysLeftLabels.forEach {
                $0.text = DateFormatter.ub_inDays(until: lastCall.addingTimeInterval(60 * 60 * 24 * 10)) // 10 days after last exposure
            }
        }
    }

    // MARK: - Detail Views

    private func makeNotYetCalledView() -> NSSimpleModuleBaseView {
        let whiteBoxView = NSSimpleModuleBaseView(title: "messages_detail_call".ub_localized, subtitle: "report_detail_positive_test_box_subtitle".ub_localized, boldText: "infoline_tel_number".ub_localized, text: "messages_detail_call_text".ub_localized, image: UIImage(named: "illu-call"), subtitleColor: .ns_blue, bottomPadding: false)

        whiteBoxView.contentView.addSpacerView(NSPadding.medium)

        let callButton = NSButton(title: "messages_detail_call_button".ub_localized, style: .uppercase(.ns_blue))

        callButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.call()
        }

        whiteBoxView.contentView.addArrangedSubview(callButton)
        whiteBoxView.contentView.addSpacerView(40.0)
        whiteBoxView.contentView.addArrangedSubview(createExplanationView())
        whiteBoxView.contentView.addSpacerView(NSPadding.large)

        addDeleteButton(whiteBoxView)

        return whiteBoxView
    }

    private func makeAlreadyCalledView() -> NSSimpleModuleBaseView {
        let whiteBoxView = NSSimpleModuleBaseView(title: "messages_detail_call_thankyou_title".ub_localized, subtitle: "messages_detail_call_thankyou_subtitle".ub_localized, text: "messages_detail_guard_text".ub_localized, image: UIImage(named: "illu-behaviour"), subtitleColor: .ns_blue, bottomPadding: false)

        whiteBoxView.contentView.addSpacerView(NSPadding.medium)

        let callButton = NSButton(title: "messages_detail_call_again_button".ub_localized, style: .outlineUppercase(.ns_blue))

        callButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.call()
        }

        whiteBoxView.contentView.addArrangedSubview(callButton)
        whiteBoxView.contentView.addSpacerView(NSPadding.medium)
        whiteBoxView.contentView.addArrangedSubview(createCallLabel())
        whiteBoxView.contentView.addSpacerView(40.0)
        whiteBoxView.contentView.addArrangedSubview(createExplanationView())
        whiteBoxView.contentView.addSpacerView(NSPadding.large)

        addDeleteButton(whiteBoxView)

        return whiteBoxView
    }

    private func makeCallAgainView() -> NSSimpleModuleBaseView {
        let whiteBoxView = NSSimpleModuleBaseView(title: "messages_detail_call_again".ub_localized, subtitle: "report_detail_positive_test_box_subtitle".ub_localized, boldText: "infoline_tel_number".ub_localized, text: "messages_detail_guard_text".ub_localized, image: UIImage(named: "iillu-call"), subtitleColor: .ns_blue, bottomPadding: false)

        whiteBoxView.contentView.addSpacerView(NSPadding.medium)

        let callButton = NSButton(title: "messages_detail_call_button".ub_localized, style: .uppercase(.ns_blue))

        callButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.call()
        }

        whiteBoxView.contentView.addArrangedSubview(callButton)
        whiteBoxView.contentView.addSpacerView(NSPadding.medium)
        whiteBoxView.contentView.addArrangedSubview(createCallLabel())
        whiteBoxView.contentView.addSpacerView(40.0)
        whiteBoxView.contentView.addArrangedSubview(createExplanationView())
        whiteBoxView.contentView.addSpacerView(NSPadding.large)

        addDeleteButton(whiteBoxView)

        return whiteBoxView
    }

    private func addDeleteButton(_ whiteBoxView: NSSimpleModuleBaseView) {
        whiteBoxView.contentView.addDividerView(inset: -NSPadding.large)

        let deleteButton = NSButton(title: "delete_reports_button".ub_localized, style: .borderlessUppercase(.ns_blue))

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
            let alert = UIAlertController(title: nil, message: "delete_reports_dialog".ub_localized, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "delete_reports_button".ub_localized, style: .destructive, handler: { _ in
                TracingManager.shared.deleteReports()
            }))
            alert.addAction(UIAlertAction(title: "cancel".ub_localized, style: .cancel, handler: { _ in

            }))
            self?.present(alert, animated: true, completion: nil)
        }
    }

    private func createCallLabel() -> NSLabel {
        let label = NSLabel(.smallRegular)
        callLabels.append(label)
        return label
    }

    private func createExplanationView() -> UIView {
        let ev = NSExplanationView(title: "messages_detail_explanation_title".ub_localized, texts: ["messages_detail_explanation_text1".ub_localized, "messages_detail_explanation_text2".ub_localized, "messages_detail_explanation_text4".ub_localized], edgeInsets: .zero)

        let wrapper = UIView()
        let daysLeftLabel = NSLabel(.textBold)
        daysLeftLabels.append(daysLeftLabel)
        wrapper.addSubview(daysLeftLabel)
        daysLeftLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(30)
        }

        ev.stackView.insertArrangedSubview(wrapper, at: 3)
        ev.stackView.setCustomSpacing(NSPadding.small, after: ev.stackView.arrangedSubviews[2])

        var infoBoxViewModel = NSInfoBoxView.ViewModel(title: "messages_detail_free_test_title".ub_localized,
                                                       subText: "messages_detail_free_test_text".ub_localized,
                                                       titleColor: .ns_text,
                                                       subtextColor: .ns_text)
        infoBoxViewModel.image = UIImage(named: "ic-info-on")
        infoBoxViewModel.backgroundColor = .ns_blueBackground
        infoBoxViewModel.titleLabelType = .textBold

        let infoBoxView = NSInfoBoxView(viewModel: infoBoxViewModel)

        ev.stackView.addArrangedSubview(infoBoxView)

        return ev
    }

    // MARK: - Logic

    private func call() {
        guard let lastReport = reports.last else { return }

        let phoneNumber = "infoline_tel_number".ub_localized
        PhoneCallHelper.call(phoneNumber)

        UserStorage.shared.registerPhoneCall(identifier: lastReport.identifier)
        UIStateManager.shared.refresh()
    }
}

extension NSReportsDetailReportViewController: NSHitTestDelegate {
    func overrideHitTest(_ point: CGPoint, with _: UIEvent?) -> Bool {
        if overrideHitTestAnyway, useFullScreenHeaderAnimation {
            return true
        }

        return point.y + stackScrollView.scrollView.contentOffset.y < startPositionScrollView
    }
}
