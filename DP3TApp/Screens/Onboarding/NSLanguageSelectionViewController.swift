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

class NSLanguageSelectionViewController: NSViewController {
    private let stackScrollView = NSStackScrollView()
    
    private let foregroundImageView = UIImageView()
    
    private let languageENLabel = NSLabel(.title, textAlignment: .center)
    private let languageMTLabel = NSLabel(.title, textAlignment: .center)
    
    let languageENButton = NSButton(title: "", style: .normal(.ns_blue))
    let languageMTButton = NSButton(title: "", style: .normal(.ns_blue))
    
    private var elements: [Any] = []
    
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    private let splashVC = NSSplashViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .setColorsForTheme(lightColor: .ns_background, darkColor: .ns_darkModeBackground2)
        
        elements = [languageENLabel, languageMTLabel, languageENButton, languageMTButton].compactMap { $0 }
        accessibilityElements = elements.compactMap { $0 }
        
        setupStackView()
        setupViews()
        fillViews()
        
        setupAccessibility()
        
        addSplashViewController()
        addStatusBarBlurView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        startSplashCountDown()
    }
    
    private func setupStackView() {
        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackScrollView.stackView.alignment = .center
        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        stackScrollView.addSpacerView(NSPadding.large)
    }

    private func setupViews() {
        let sidePadding = UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large)
        
        addArrangedView(foregroundImageView, spacing: NSPadding.large, insets: UIEdgeInsets(top: NSPadding.large * 4, left: 0, bottom: 0, right: 0))
        addArrangedView(languageENLabel, spacing: NSPadding.large, insets: sidePadding)
        addArrangedView(languageMTLabel, spacing: 1.5 * NSPadding.large, insets: sidePadding)
        addArrangedView(languageENButton, spacing: NSPadding.large, insets: UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large))
        addArrangedView(languageMTButton, spacing: NSPadding.large, insets: UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large))
    }
    
    private func fillViews() {
        foregroundImageView.image = UIImage(named: "onboarding-report")!
        languageENLabel.text = "onboarding_language_title_en".ub_localized
        languageMTLabel.text = "onboarding_language_title_mt".ub_localized
        languageENButton.title = "onboarding_language_button_text_en".ub_localized
        languageMTButton.title = "onboarding_language_button_text_mt".ub_localized
        
        languageENButton.addTarget(self, action: #selector(setENLanguage), for: .touchUpInside)
        languageMTButton.addTarget(self, action: #selector(setMTLanguage), for: .touchUpInside)
    }
    
    private func setupAccessibility() {
        languageENLabel.accessibilityTraits = [.header]
        languageMTLabel.accessibilityTraits = [.header]
    }
    
    private func addSplashViewController() {
        addChild(splashVC)
        view.addSubview(splashVC.view)
        splashVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func startSplashCountDown() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            UIView.animate(withDuration: 0.5) {
                self.splashVC.view.alpha = 0
                self.blurView.alpha = 1
            }
        }
    }
    
    fileprivate func addStatusBarBlurView() {
        blurView.alpha = 0

        view.addSubview(blurView)

        let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0

        blurView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(statusBarHeight)
        }
    }
    
    internal func addArrangedView(_ view: UIView, spacing: CGFloat? = nil, insets: UIEdgeInsets = .zero) {
        let wrapperView = UIView()
        wrapperView.ub_setContentPriorityRequired()
        wrapperView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(insets)
        }

        stackScrollView.stackView.addArrangedSubview(wrapperView)
        
        if let s = spacing {
            stackScrollView.stackView.setCustomSpacing(s, after: wrapperView)
        }
    }
    
    @objc
    private func setENLanguage() {
        setLanguage(language: LanguageHelper.LANGUAGE_EN)
    }
    
    @objc
    private func setMTLanguage() {
        setLanguage(language: LanguageHelper.LANGUAGE_MT)
    }
    
    @objc
    private func setLanguage(language: String) {
        LanguageHelper.setAppLocale(localeCode: language)

        let onboardingViewController = NSOnboardingViewController()
        onboardingViewController.modalPresentationStyle = .fullScreen
        
        let rootVC = UIApplication.shared.windows.first?.rootViewController
        rootVC?.dismiss(animated: false, completion: {
            rootVC?.present(onboardingViewController, animated: false)
        })
    }
}
