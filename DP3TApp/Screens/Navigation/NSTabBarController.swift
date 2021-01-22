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

class NSTabBarController: UITabBarController {
    var homescreen = NSHomescreenViewController()
    
    private var languageSelectionButton = UIBarButtonItem()

    enum Tab: Int, CaseIterable {
        case homescreen
    }

    func viewControler(for tab: Tab) -> NSViewController {
        switch tab {
        case .homescreen:
            return homescreen
        }
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        style()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = Tab.allCases.map(viewControler(for:))

        navigationItem.title = ("app_name".ub_localized + "        \u{200c}")

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

        let swissFlagImage = UIImage(named: "img_national_crest")?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIImageView(image: swissFlagImage))

        // Show back button without text
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !UserStorage.shared.hasCompletedOnboarding {
            let currentLocale = LanguageHelper.getAppLocale()
            languageSelectionButton.title = currentLocale == LanguageHelper.LANGUAGE_EN ? "EN/mt" : "en/MT"
            homescreen = NSHomescreenViewController()
            viewControllers = Tab.allCases.map(viewControler(for:))
            self.selectedIndex = currentTab.rawValue
        }
    }
    
    @objc private func languageButtonPressed() {
        let currentLocale = LanguageHelper.getAppLocale()
        let newLocale = currentLocale == LanguageHelper.LANGUAGE_EN ? LanguageHelper.LANGUAGE_MT : LanguageHelper.LANGUAGE_EN
        LanguageHelper.setAppLocale(localeCode: newLocale)
        languageSelectionButton.title = newLocale == LanguageHelper.LANGUAGE_EN ? "EN/mt" : "en/MT"
        homescreen = NSHomescreenViewController()
        viewControllers = Tab.allCases.map(viewControler(for:))
        self.selectedIndex = currentTab.rawValue
    }

    @objc private func infoButtonPressed() {
        present(NSNavigationController(rootViewController: NSAboutViewController()), animated: true)
    }

    var currentTab: Tab {
        get {
            guard let tab = Tab(rawValue: selectedIndex) else {
                fatalError()
            }
            return tab
        }
        set {
            selectedIndex = newValue.rawValue
        }
    }

    var currentViewController: NSViewController {
        viewControler(for: currentTab)
    }

    var currentNavigationController: NSNavigationController {
        guard let navigationController = navigationController as? NSNavigationController else {
            fatalError()
        }
        return navigationController
    }

    private func style() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .ns_moduleBackground
        setTabBarItemColors(appearance.stackedLayoutAppearance)
        setTabBarItemColors(appearance.inlineLayoutAppearance)
        setTabBarItemColors(appearance.compactInlineLayoutAppearance)
        tabBar.standardAppearance = appearance
        tabBar.isHidden = true
    }

    private func setTabBarItemColors(_ itemAppearance: UITabBarItemAppearance) {
        let normalAttributes = [NSAttributedString.Key.foregroundColor: UIColor.ns_tabbarNormalBlue,
                                NSAttributedString.Key.font: NSLabelType.ultraSmallBold.font]

        itemAppearance.normal.iconColor = .ns_tabbarNormalBlue
        itemAppearance.focused.iconColor = .ns_tabbarNormalBlue
        itemAppearance.disabled.iconColor = .ns_tabbarNormalBlue

        itemAppearance.normal.titleTextAttributes = normalAttributes
        itemAppearance.focused.titleTextAttributes = normalAttributes
        itemAppearance.disabled.titleTextAttributes = normalAttributes

        itemAppearance.selected.iconColor = .ns_tabbarSelectedBlue
        itemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.ns_tabbarSelectedBlue,
                                                       NSAttributedString.Key.font: NSLabelType.ultraSmallBold.font]
    }
}
