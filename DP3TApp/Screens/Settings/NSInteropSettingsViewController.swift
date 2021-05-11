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

import DP3TSDK
import Foundation
import SafariServices

class NSInteropSettingsViewController: NSTitleViewScrollViewController {
    
    var interopPossible : Bool = UIStateManager.shared.uiState.interopDetail.interopPossible
    var interopState : UIStateModel.InteroperabilityState = UIStateManager.shared.uiState.interopDetail.interopState
    var interopSelectedCountries: [String] = UIStateManager.shared.uiState.interopDetail.interopSelectedCountries
    
    var interopConfigCountries: [(name: String, value: String, selected: Bool)] = []
    var interopConfigCountriesPadding: Int = 500
    
    private let groupInteropLabel = NSLabel(.subtitle, textAlignment: .left)
    private let introLabel = NSLabel(.textLight, textAlignment: .left)
    private let privacyButton = NSExternalLinkButton(style: .normal(color: .ns_blue))
    private let faqButton = NSExternalLinkButton(style: .normal(color: .ns_blue))
    private let instructionsLabel = NSLabel(.textBold, textAlignment: .left)
    private let interopUnavailableContainer = UIView()
    private var interopUnavailableIcon = UIImageView()
    private let interopUnavailableLabel = NSLabel(.textBold, textAlignment: .left)
    private let euTitleLabel = NSLabel(.buttonLabel, textAlignment: .left)
    private let euTextLabel = NSLabel(.smallLight, textAlignment: .left)
    private let euSwitch = UISwitch()
    private let countriesTitleLabel = NSLabel(.buttonLabel, textAlignment: .left)
    private let countriesTextLabel = NSLabel(.smallLight, textAlignment: .left)
    private let countriesSwitch = UISwitch()
    private let countriesSelectContainer = UIView()
    private let countriesSelectLabel = NSLabel(.buttonLabel, textAlignment: .left)
    private let countriesSelectButton = NSButton(title: "choose_button".ub_localized, style: .outline(.ns_blue))
    private let disabledTitleLabel = NSLabel(.buttonLabel, textAlignment: .left)
    private let disabledTextLabel = NSLabel(.smallLight, textAlignment: .left)
    private let disabledSwitch = UISwitch()

    // MARK: - Init
    override init() {
        super.init()
        title = "interop_mode_title".ub_localized
        
        //Retrieve config countries
        let interopCountries = UserStorage.shared.getInteropCountries()
        
        let language = SettingsHelper.getActiveLanguageCode()
        if(language == SettingsHelper.LANGUAGE_EN) {
            interopConfigCountries = (interopCountries.map({ (country) -> (name: String, value: String, selected: Bool) in
                return (name: country.countryNameEN, value: country.countryCode, selected: interopSelectedCountries.contains(country.countryCode))
            }))
        } else {
            interopConfigCountries = (interopCountries.map({ (country) -> (name: String, value: String, selected: Bool) in
                return (name: country.countryNameMT, value: country.countryCode, selected: interopSelectedCountries.contains(country.countryCode))
            }))
        }
        
        //Update country mode if changes are required
        if(interopState == UIStateModel.InteroperabilityState.countries_update_pending)
        {
            SettingsHelper.setInteropState(interopState: UIStateModel.InteroperabilityState.countries)
            interopState = UIStateModel.InteroperabilityState.countries
        }
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .setColorsForTheme(lightColor: .ns_backgroundSecondary, darkColor: .ns_background)
        
        setupStackScrollView()
        setupLayout()
        
        //Change UI if interop is not possible
        if(!interopPossible) {
            interopUnavailableContainer.isHidden = false
            
            euSwitch.isEnabled = false
            countriesSwitch.isEnabled = false
            countriesSelectContainer.isHidden = true
            disabledSwitch.isEnabled = false
        }
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

        groupInteropLabel.text = "interop_mode_title".ub_localized
        groupInteropLabel.textColor = .ns_blue
        stackScrollView.addArrangedView(groupInteropLabel)
        
        stackScrollView.addSpacerView(NSPadding.large)
        
        introLabel.text = "interop_mode_description".ub_localized
        stackScrollView.addArrangedView(introLabel)
        
        stackScrollView.addSpacerView(NSPadding.large)
        
        privacyButton.title = "onboarding_disclaimer_legal_button".ub_localized
        privacyButton.accessibilityHint = "onboarding_disclaimer_legal_button".ub_localized
        privacyButton.touchUpCallback = { [weak self] in
            if let url = URL(string: "onboarding_disclaimer_legal_button_url".ub_localized) {
                let vc = SFSafariViewController(url: url)
                vc.modalPresentationStyle = .popover
                self?.present(vc, animated: true)
            }
        }
        stackScrollView.addArrangedView(privacyButton)
        
        stackScrollView.addSpacerView(NSPadding.medium)
        
        faqButton.title = "faq_button_title".ub_localized
        faqButton.accessibilityHint = "faq_button_title".ub_localized
        faqButton.touchUpCallback = { [weak self] in
            if let url = URL(string: "faq_button_url".ub_localized) {
                let vc = SFSafariViewController(url: url)
                vc.modalPresentationStyle = .popover
                self?.present(vc, animated: true)
            }
        }
        stackScrollView.addArrangedView(faqButton)
        
        stackScrollView.addSpacerView(NSPadding.large)
        
        instructionsLabel.text = "interop_mode_instructions".ub_localized
        stackScrollView.addArrangedView(instructionsLabel)
        
        stackScrollView.addSpacerView(NSPadding.medium)
        
        interopUnavailableIcon.image = UIImage(named: "ic-error")?.withRenderingMode(.alwaysOriginal)
        interopUnavailableIcon.ub_setContentPriorityRequired()
        interopUnavailableIcon.contentMode = .scaleAspectFit
        interopUnavailableContainer.addSubview(interopUnavailableIcon)
        
        interopUnavailableLabel.text = "interop_mode_unavailable_text".ub_localized
        interopUnavailableContainer.addSubview(interopUnavailableLabel)

        interopUnavailableIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(NSPadding.small)
            make.centerY.equalToSuperview()
            make.size.equalTo(30)
        }

        interopUnavailableLabel.snp.makeConstraints { make in
            make.leading.equalTo(interopUnavailableIcon.snp.trailing).inset(-NSPadding.medium)
            make.top.bottom.trailing.equalToSuperview().inset(NSPadding.medium)
        }
        
        stackScrollView.addArrangedView(interopUnavailableContainer)
        
        interopUnavailableContainer.isHidden = true
        
        stackScrollView.addSpacerView(NSPadding.medium)
        
        let euContainer = UIView();
        
        euTitleLabel.text = "interop_mode_eu_title".ub_localized
        euContainer.addSubview(euTitleLabel)
        
        euTextLabel.text = "interop_mode_eu_text".ub_localized
        euContainer.addSubview(euTextLabel)
        
        let euSwitchContainer = UIView();
        
        euSwitch.onTintColor = .ns_blue
        euSwitchContainer.addSubview(euSwitch)
        
        euContainer.addSubview(euSwitchContainer)
        
        euTitleLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.50)
        }
        
        euTextLabel.snp.makeConstraints { make in
            make.top.equalTo(euTitleLabel.snp.bottom).offset(NSPadding.small)
            make.left.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.50)
        }

        euSwitchContainer.ub_setContentPriorityRequired()
        euSwitchContainer.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.35)
            make.centerY.equalTo(euContainer.snp.centerY)
        }
        
        euSwitch.snp.makeConstraints { make in
            make.centerX.equalTo(euSwitchContainer.snp.centerX)
            make.centerY.equalTo(euSwitchContainer.snp.centerY)
        }
        
        euSwitch.addTarget(self, action: #selector(euSwitchChanged), for: .valueChanged)
        euSwitch.setOn(interopState == UIStateModel.InteroperabilityState.eu, animated: false)
        
        stackScrollView.addArrangedView(euContainer)
        
        stackScrollView.addSpacerView(NSPadding.large)
        
        stackScrollView.addDividerView(inset: 0)
        
        stackScrollView.addSpacerView(NSPadding.large)
        
        let countriesContainer = UIView();
        
        countriesTitleLabel.text = "interop_mode_countries_title".ub_localized
        countriesContainer.addSubview(countriesTitleLabel)
        
        countriesTextLabel.text = "interop_mode_countries_text".ub_localized
        countriesContainer.addSubview(countriesTextLabel)
        
        let countriesSwitchContainer = UIView();
        
        countriesSwitch.onTintColor = .ns_blue
        countriesSwitchContainer.addSubview(countriesSwitch)
        
        countriesContainer.addSubview(countriesSwitchContainer)
        
        countriesTitleLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.50)
        }
        
        countriesTextLabel.snp.makeConstraints { make in
            make.top.equalTo(countriesTitleLabel.snp.bottom).offset(NSPadding.small)
            make.left.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.50)
        }

        countriesSwitchContainer.ub_setContentPriorityRequired()
        countriesSwitchContainer.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.35)
            make.centerY.equalTo(countriesContainer.snp.centerY)
        }
        
        countriesSwitch.snp.makeConstraints { make in
            make.centerX.equalTo(countriesSwitchContainer.snp.centerX)
            make.centerY.equalTo(countriesSwitchContainer.snp.centerY)
        }
        
        countriesSwitch.addTarget(self, action: #selector(countriesSwitchChanged), for: .valueChanged)
        countriesSwitch.setOn(interopState == UIStateModel.InteroperabilityState.countries, animated: false)
        
        stackScrollView.addArrangedView(countriesContainer)
        
        countriesSelectLabel.text = "interop_mode_countries_text_selection".ub_localized
        countriesSelectContainer.addSubview(countriesSelectLabel)
        
        countriesSelectContainer.addSubview(countriesSelectButton)
        
        countriesSelectLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(NSPadding.medium)
            make.left.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.50)
        }

        countriesSelectButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(NSPadding.medium)
            make.right.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.35)
        }
        
        countriesSelectButton.touchUpCallback = { [weak self] in
            self?.countriesSelectButtonTouched()
        }
        
        stackScrollView.addArrangedView(countriesSelectContainer)
        
        //Hide country select container if not necessary
        if(interopState != UIStateModel.InteroperabilityState.countries){
            countriesSelectContainer.isHidden = true
        }
        
        stackScrollView.addSpacerView(NSPadding.large)
        
        stackScrollView.addDividerView(inset: 0)
        
        stackScrollView.addSpacerView(NSPadding.large)
        
        let disabledContainer = UIView();
        
        disabledTitleLabel.text = "interop_mode_disabled_title".ub_localized
        disabledContainer.addSubview(disabledTitleLabel)
        
        disabledTextLabel.text = "interop_mode_disabled_text".ub_localized
        disabledContainer.addSubview(disabledTextLabel)
        
        let disabledSwitchContainer = UIView();
        
        disabledSwitch.onTintColor = .ns_blue
        disabledSwitchContainer.addSubview(disabledSwitch)
        
        disabledContainer.addSubview(disabledSwitchContainer)
        
        disabledTitleLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.50)
        }
        
        disabledTextLabel.snp.makeConstraints { make in
            make.top.equalTo(disabledTitleLabel.snp.bottom).offset(NSPadding.small)
            make.left.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.50)
        }

        disabledSwitchContainer.ub_setContentPriorityRequired()
        disabledSwitchContainer.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.35)
            make.centerY.equalTo(disabledContainer.snp.centerY)
        }
        
        disabledSwitch.snp.makeConstraints { make in
            make.centerX.equalTo(disabledSwitchContainer.snp.centerX)
            make.centerY.equalTo(disabledSwitchContainer.snp.centerY)
        }
        
        disabledSwitch.addTarget(self, action: #selector(disabledSwitchChanged), for: .valueChanged)
        disabledSwitch.setOn(interopState == UIStateModel.InteroperabilityState.disabled, animated: false)
        
        stackScrollView.addArrangedView(disabledContainer)
        
        stackScrollView.addSpacerView(NSPadding.large)
    }
    
    @objc private func euSwitchChanged() {
        if(euSwitch.isOn) {
            countriesSwitch.isOn = false
            countriesSelectContainer.isHidden = true
            disabledSwitch.isOn = false
            
            SettingsHelper.setInteropState(interopState: UIStateModel.InteroperabilityState.eu)
        } else {
            SettingsHelper.setInteropState(interopState: UIStateModel.InteroperabilityState.disabled_silent)
        }
    }
    
    @objc private func countriesSwitchChanged() {
        if(countriesSwitch.isOn) {
            euSwitch.isOn = false
            countriesSelectContainer.isHidden = false
            disabledSwitch.isOn = false
            
            SettingsHelper.setInteropState(interopState: UIStateModel.InteroperabilityState.countries)
        } else {
            countriesSelectContainer.isHidden = true
            
            SettingsHelper.setInteropState(interopState: UIStateModel.InteroperabilityState.disabled_silent)
        }
    }
    
    @objc func countriesSelectButtonTouched() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        let countryScrollView = NSStackScrollView(axis: .vertical, spacing: NSPadding.small)
                
        for (index, country) in interopConfigCountries.enumerated() {
            let countryContainer = UIView();
            
            let countryLabel = NSLabel(.buttonLabel, textAlignment: .left)
            countryLabel.text = country.name
            countryContainer.addSubview(countryLabel)
            
            let countrySwitch = UISwitch()
            countrySwitch.onTintColor = .ns_blue
            countryContainer.addSubview(countrySwitch)
            
            countryLabel.snp.makeConstraints { make in
                make.left.top.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.75)
                make.centerY.equalToSuperview()
            }

            countrySwitch.snp.makeConstraints { make in
                make.right.top.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.25)
                make.centerY.equalToSuperview()
            }
            
            countrySwitch.addTarget(self, action: #selector(countrySelectSwitchChanged(countrySwitch:)), for: .valueChanged)
            countrySwitch.setOn(country.selected, animated: false)
            //Set key for Switch in order to link it to country selection, pad to avoid conflicts
            countrySwitch.tag = index + interopConfigCountriesPadding
            
            countryScrollView.addArrangedView(countryContainer)
        }
        
        alert.view.addSubview(countryScrollView)
        
        countryScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(NSPadding.medium)
        }
        countryScrollView.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -50).isActive = true
        
        let action = UIAlertAction(title: "android_button_ok".ub_localized, style: UIAlertAction.Style.default) {(action:UIAlertAction) in
            for (index, country) in self.interopConfigCountries.enumerated() {
                self.interopConfigCountries[index].selected = self.interopSelectedCountries.contains(country.value)
            }
            SettingsHelper.setInteropSelectedCountries(countries: self.interopSelectedCountries)
        }
        
        alert.addAction(action)
        
        let alertHeight: NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.90)
        alert.view.addConstraint(alertHeight)
        
        self.present(alert, animated: true)
    }
    
    @objc private func countrySelectSwitchChanged(countrySwitch: UISwitch) {
        let countryIndex = countrySwitch.tag - interopConfigCountriesPadding
        let countryCode = interopConfigCountries[countryIndex].value
        
        if(countrySwitch.isOn)
        {
            interopSelectedCountries.append(countryCode)
        } else {
            interopSelectedCountries.removeAll { (entry) -> Bool in
                return entry == countryCode
            }
        }
    }
    
    @objc private func disabledSwitchChanged() {
        if(disabledSwitch.isOn) {
            euSwitch.isOn = false
            countriesSwitch.isOn = false
            countriesSelectContainer.isHidden = true
            
            SettingsHelper.setInteropState(interopState: UIStateModel.InteroperabilityState.disabled)
        } else {
            SettingsHelper.setInteropState(interopState: UIStateModel.InteroperabilityState.disabled_silent)
        }
    }
}
