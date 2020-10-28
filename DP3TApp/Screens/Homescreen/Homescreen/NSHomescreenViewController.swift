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

class NSHomescreenViewController: NSTitleViewScrollViewController {
    // MARK: - Views

    private let infoBoxView = HomescreenInfoBoxView()
    private let informationView = NSInformationView()
    private let handshakesModuleView = NSEncountersModuleView()
    private let reportsView = NSReportsModuleView()

    private let whatToDoSymptomsButton = NSWhatToDoButton(title: "whattodo_title_symptoms".ub_localized, subtitle: "whattodo_subtitle_symptoms".ub_localized, image: UIImage(named: "img_symptoms"))

    private let whatToDoPositiveTestButton = NSWhatToDoButton(title: "whattodo_title_positivetest".ub_localized, subtitle: "whattodo_subtitle_positivetest".ub_localized, image: UIImage(named: "img_get_tested"))

    private let debugScreenButton = NSButton(title: "debug_settings_title".ub_localized, style: .outlineUppercase(.ns_red))

    private var lastState: UIStateModel = .init()

    private let appTitleView = NSAppTitleView()
    
    private var languageSelectionButton = UIBarButtonItem()

    // MARK: - View

    override init() {
        super.init()

        titleView = appTitleView
        //Append spaces to allow space for menu
        title = ("app_name".ub_localized + "        \u{200c}")

        tabBarItem.image = UIImage(named: "ic-tracing")
        tabBarItem.title = "tab_tracing_title".ub_localized

        // always load view at init, even if app starts at reports detail
        loadViewIfNeeded()
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ns_backgroundSecondary

        setupLayout()

        informationView.touchUpCallback = {
            if let url = URL(string: "faq_button_url".ub_localized) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }

        reportsView.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentReportsDetail()
        }

        UIStateManager.shared.addObserver(self, block: { [weak self] state in
            guard let strongSelf = self else { return }
            strongSelf.updateState(state)
        })

        handshakesModuleView.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentEncountersDetail()
        }

        whatToDoPositiveTestButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentWhatToDoPositiveTest()
        }

        whatToDoSymptomsButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentWhatToDoSymptoms()
        }

        // Ensure that Screen builds without animation if app not started on homescreen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.finishTransition?()
            self.finishTransition = nil
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        appTitleView.changeBackgroundRandomly()
        UIStateManager.shared.refresh()

        if !UserStorage.shared.hasCompletedOnboarding {
            let v = UIView()
            v.backgroundColor = .ns_background
            view.addSubview(v)
            v.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                UIView.animate(withDuration: 0.5) {
                    v.alpha = 0.0
                    v.isUserInteractionEnabled = false
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        finishTransition?()
        finishTransition = nil
    }

    private var finishTransition: (() -> Void)?

    // MARK: - Setup

    private func setupLayout() {
        // navigation bar
        let defaultLanguageSelectionTitle = LanguageHelper.getAppLocale() == LanguageHelper.LANGUAGE_EN ? "EN/mt" : "en/MT"
        languageSelectionButton = UIBarButtonItem(title: defaultLanguageSelectionTitle, style: .plain, target: self, action: #selector(languageButtonPressed))
        languageSelectionButton.tintColor = .ns_text
        languageSelectionButton.accessibilityLabel = defaultLanguageSelectionTitle
        
        let image = UIImage(named: "ic-info-outline")
        let aboutButton = UIBarButtonItem(image: image, landscapeImagePhone: image, style: .plain, target: self, action: #selector(infoButtonPressed))
        aboutButton.tintColor = .ns_text
        aboutButton.accessibilityLabel = "accessibility_info_button".ub_localized
        
        navigationItem.setRightBarButtonItems([aboutButton, languageSelectionButton], animated: true)

        // other views
        stackScrollView.addArrangedView(infoBoxView)
        stackScrollView.addSpacerView(NSPadding.medium)
    
        stackScrollView.addArrangedView(informationView)
        stackScrollView.addSpacerView(NSPadding.medium)

        stackScrollView.addArrangedView(handshakesModuleView)
        stackScrollView.addSpacerView(NSPadding.medium)

        stackScrollView.addArrangedView(reportsView)
        stackScrollView.addSpacerView(NSPadding.medium)

        stackScrollView.addArrangedView(whatToDoSymptomsButton)
        stackScrollView.addSpacerView(NSPadding.medium)
        
        stackScrollView.addArrangedView(whatToDoPositiveTestButton)
        stackScrollView.addSpacerView(NSPadding.medium)

        handshakesModuleView.alpha = 0
        reportsView.alpha = 0
        whatToDoSymptomsButton.alpha = 0
        whatToDoPositiveTestButton.alpha = 0

        finishTransition = {
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [.allowUserInteraction], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)

            UIView.animate(withDuration: 0.3, delay: 0.35, options: [.allowUserInteraction], animations: {
                self.handshakesModuleView.alpha = 1
            }, completion: nil)

            UIView.animate(withDuration: 0.3, delay: 0.5, options: [.allowUserInteraction], animations: {
                self.reportsView.alpha = 1
            }, completion: nil)

            UIView.animate(withDuration: 0.3, delay: 0.65, options: [.allowUserInteraction], animations: {
                self.whatToDoSymptomsButton.alpha = 1
            }, completion: nil)

            UIView.animate(withDuration: 0.3, delay: 0.7, options: [.allowUserInteraction], animations: {
                self.whatToDoPositiveTestButton.alpha = 1
            }, completion: nil)

//            #if ENABLE_TESTING
//                UIView.animate(withDuration: 0.3, delay: 0.7, options: [.allowUserInteraction], animations: {
//                    debugScreenContainer.alpha = 1
//                }, completion: nil)
//            #endif
//
//            #if ENABLE_LOGGING
//                UIView.animate(withDuration: 0.3, delay: 0.7, options: [.allowUserInteraction], animations: {
//                    uploadDBContainer.alpha = 1
//                }, completion: nil)
//            #endif
        }
    }

    func updateState(_ state: UIStateModel) {
        appTitleView.uiState = state.homescreen.header
        handshakesModuleView.uiState = state.homescreen.encounters
        reportsView.uiState = state.homescreen

        let isInfected = state.homescreen.reports.report == .infected
        whatToDoSymptomsButton.isHidden = isInfected
        whatToDoPositiveTestButton.isHidden = isInfected

        infoBoxView.uiState = state.homescreen.infoBox

        if let infoId = state.homescreen.infoBox?.infoId,
            state.homescreen.infoBox?.isDismissible == true {
            infoBoxView.closeButtonTouched = { [weak infoBoxView] in
                NSInfoBoxVisibilityManager.shared.dismissedInfoBoxIds.append(infoId)
                UIView.animate(withDuration: 0.3) {
                    infoBoxView?.isHidden = true
                }
            }
        }

        infoBoxView.isHidden = state.homescreen.infoBox == nil

        lastState = state
    }

    // MARK: - Details

    private func presentEncountersDetail() {
        navigationController?.pushViewController(NSEncountersDetailViewController(initialState: lastState.encountersDetail), animated: true)
    }

    func presentReportsDetail(animated: Bool = true) {
        navigationController?.pushViewController(NSReportsDetailViewController(), animated: animated)
    }

    #if ENABLE_TESTING
        private func presentDebugScreen() {
            navigationController?.pushViewController(NSDebugscreenViewController(), animated: true)
        }
    #endif

    private func presentWhatToDoPositiveTest() {
        navigationController?.pushViewController(NSWhatToDoPositiveTestViewController(), animated: true)
    }

    private func presentWhatToDoSymptoms() {
        navigationController?.pushViewController(NSWhatToDoSymptomViewController(), animated: true)
    }

    @objc private func languageButtonPressed() {
        let currentLocale = LanguageHelper.getAppLocale()
        let newLocale = currentLocale == LanguageHelper.LANGUAGE_EN ? LanguageHelper.LANGUAGE_MT : LanguageHelper.LANGUAGE_EN
        LanguageHelper.setAppLocale(localeCode: newLocale)
        languageSelectionButton.title = newLocale == LanguageHelper.LANGUAGE_EN ? "EN/mt" : "en/MT"
        navigationController?.setViewControllers([NSHomescreenViewController()], animated: true)
    }

    @objc private func infoButtonPressed() {
        present(NSNavigationController(rootViewController: NSAboutViewController()), animated: true)
    }

    #if ENABLE_LOGGING
        private let uploadDBButton = NSButton(title: "Upload DB to server", style: .outlineUppercase(.ns_red))
        private let uploadHelper = NSDebugDatabaseUploadHelper()
        private func uploadDatabaseForDebugPurposes() {
            let alert = UIAlertController(title: "Username", message: nil, preferredStyle: .alert)
            alert.addTextField { $0.text = "" }
            alert.addAction(UIAlertAction(title: "Upload", style: .default, handler: { [weak alert, weak self] _ in
                let username = alert?.textFields?.first?.text ?? ""
                self?.uploadDB(with: username)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }

        private func uploadDB(with username: String) {
            let loading = UIAlertController(title: "Uploading...", message: "Please wait", preferredStyle: .alert)
            present(loading, animated: true)

            uploadHelper.uploadDatabase(username: username) { result in
                let alert: UIAlertController
                switch result {
                case .success:
                    alert = UIAlertController(title: "Upload successful", message: nil, preferredStyle: .alert)
                case let .failure(error):
                    alert = UIAlertController(title: "Upload failed", message: error.message, preferredStyle: .alert)
                }

                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                loading.dismiss(animated: false) {
                    self.present(alert, animated: false)
                }
            }
        }
    #endif
}
