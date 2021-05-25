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

import Foundation

class NSSettingsViewController: NSTitleViewScrollViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var languages: [(name: String, value: String)] = [
        ("preferences_language_en".ub_localized, "en"),
        ("preferences_language_mt".ub_localized, "mt-MT")
    ]
    
    private let groupGeneralLabel = NSLabel(.subtitle, textAlignment: .left)
    private let languageLabel = NSLabel(.buttonLabel, textAlignment: .left)
    private let languageButton = NSButton(title: "preferences_language_title".ub_localized, style: .outline(.ns_blue))
    private let wifiTitleLabel = NSLabel(.buttonLabel, textAlignment: .left)
    private let wifiTextLabel = NSLabel(.smallLight, textAlignment: .left)
    private let wifiSwitch = UISwitch()
    private let groupInteropLabel = NSLabel(.subtitle, textAlignment: .left)
    private let interopTitleLabel = NSLabel(.buttonLabel, textAlignment: .left)
    private let interopTextLabel = NSLabel(.smallLight, textAlignment: .left)
    private let interopButton = NSButton(title: "choose_button".ub_localized, style: .outline(.ns_blue))

    // MARK: - Init
    override init() {
        super.init()
        title = "bottom_nav_tab_preferences".ub_localized
        
        tabBarItem.image = UIImage(named: "ic-user")
        tabBarItem.title = "bottom_nav_tab_preferences".ub_localized
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .setColorsForTheme(lightColor: .ns_backgroundSecondary, darkColor: .ns_background)

        setupStackScrollView()
        setupLayout()
    }
    
    // MARK: - Setup
    private func setupStackScrollView() {
        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupLayout() {
        stackScrollView.addSpacerView(NSPadding.large)

        groupGeneralLabel.text = "preferences_general_ios".ub_localized
        groupGeneralLabel.textColor = .ns_blue
        stackScrollView.addArrangedView(groupGeneralLabel)
        
        stackScrollView.addSpacerView(NSPadding.large)
        
        let languageContainer = UIView();
        
        languageLabel.text = "preferences_language_title".ub_localized
        languageContainer.addSubview(languageLabel)
        
        languageButton.title = languages.first(where: { (arg0) -> Bool in
            let (_, value) = arg0
            return value == SettingsHelper.getActiveLanguageCode()
        })?.name
        languageContainer.addSubview(languageButton)
        
        languageLabel.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.50)
        }

        languageButton.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.35)
        }
        
        languageButton.touchUpCallback = { [weak self] in
            self?.languageButtonTouched()
        }
        
        stackScrollView.addArrangedView(languageContainer)
        
        stackScrollView.addSpacerView(NSPadding.large)
        
        let wifiContainer = UIView();
        
        wifiTitleLabel.text = "preferences_wifi_sync_title".ub_localized
        wifiContainer.addSubview(wifiTitleLabel)
        
        wifiTextLabel.text = "preferences_wifi_sync_summary".ub_localized
        wifiContainer.addSubview(wifiTextLabel)
        
        let wifiSwitchContainer = UIView();
        
        wifiSwitch.onTintColor = .ns_blue
        wifiSwitchContainer.addSubview(wifiSwitch)
        
        wifiContainer.addSubview(wifiSwitchContainer)
        
        wifiTitleLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.50)
        }
        
        wifiTextLabel.snp.makeConstraints { make in
            make.top.equalTo(wifiTitleLabel.snp.bottom).offset(NSPadding.small)
            make.left.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.50)
        }

        wifiSwitchContainer.ub_setContentPriorityRequired()
        wifiSwitchContainer.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.35)
            make.centerY.equalTo(wifiContainer.snp.centerY)
        }
        
        wifiSwitch.snp.makeConstraints { make in
            make.centerX.equalTo(wifiSwitchContainer.snp.centerX)
            make.centerY.equalTo(wifiSwitchContainer.snp.centerY)
        }
        
        wifiSwitch.addTarget(self, action: #selector(wifiSwitchChanged), for: .valueChanged)
        wifiSwitch.setOn(SettingsHelper.getWifiSync(), animated: false)
        
        stackScrollView.addArrangedView(wifiContainer)
        
        stackScrollView.addSpacerView(NSPadding.large)
        
        stackScrollView.addDividerView(inset: 0)
        
        stackScrollView.addSpacerView(NSPadding.large)
        
        groupInteropLabel.text = "interop_mode_title".ub_localized
        groupInteropLabel.textColor = .ns_blue
        stackScrollView.addArrangedView(groupInteropLabel)
        
        stackScrollView.addSpacerView(NSPadding.large)
        
        let interopContainer = UIView();
        
        interopTitleLabel.text = "interop_mode_title".ub_localized
        interopContainer.addSubview(interopTitleLabel)
        
        interopTextLabel.text = "interop_mode_instructions".ub_localized
        interopContainer.addSubview(interopTextLabel)
        
        interopContainer.addSubview(interopButton)
        
        interopTitleLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.50)
        }
        
        interopTextLabel.snp.makeConstraints { make in
            make.top.equalTo(interopTitleLabel.snp.bottom).offset(NSPadding.small)
            make.left.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.50)
        }

        interopButton.ub_setContentPriorityRequired()
        interopButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.35)
            make.centerY.equalTo(interopContainer.snp.centerY)
        }
        
        interopButton.touchUpCallback = { [weak self] in
            self?.interopButtonTouched()
        }
        
        stackScrollView.addArrangedView(interopContainer)
        
        interopContainer.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(100)
        }
        
        stackScrollView.addSpacerView(NSPadding.large)
    }

    @objc func languageButtonTouched() {
        let alert = UIAlertController(title: "preferences_language_modal_title".ub_localized, message: "", preferredStyle: .alert)
        
        let languagePicker: UIPickerView = UIPickerView(frame: CGRect(x: 10, y: 50, width: 250, height: 100))
        
        languagePicker.dataSource = self
        languagePicker.delegate = self
        
        languagePicker.selectRow(languages.firstIndex(where: { (arg0) -> Bool in
            let (_, value) = arg0
            return value == SettingsHelper.getActiveLanguageCode()
        })!, inComponent: 0, animated: false)
        
        alert.view.addSubview(languagePicker)
        
        languagePicker.leftAnchor.constraint(equalTo: alert.view.leftAnchor).isActive = true
        languagePicker.rightAnchor.constraint(equalTo: alert.view.rightAnchor).isActive = true
        languagePicker.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -50).isActive = true
        languagePicker.heightAnchor.constraint(equalToConstant: 100).isActive = true

        let action = UIAlertAction(title: "android_button_ok".ub_localized, style: UIAlertAction.Style.default) {(action:UIAlertAction) in
            let selectedLanguage = self.languages[languagePicker.selectedRow(inComponent: 0)]
            
            //Save language
            self.languageButton.title = selectedLanguage.name
            SettingsHelper.setActiveLanguage(localeCode: selectedLanguage.value)
            
            //Refresh interface
            let tabBarController = self.tabBarController as! NSTabBarController
            tabBarController.refreshViewControllers()
        }

        alert.addAction(action)
        
        self.present(alert, animated: true)
    }
    
    @objc private func wifiSwitchChanged() {
        SettingsHelper.setWifiSync(wifiSync: wifiSwitch.isOn)
    }
    
    @objc func interopButtonTouched() {
        navigationController?.pushViewController(NSInteropSettingsViewController(), animated: true)
    }
    
    // MARK: - Language Picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row].name
    }
}
