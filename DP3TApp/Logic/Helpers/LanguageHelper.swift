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

class LanguageHelper: NSObject {
    public static let DP3T_LANGUAGE = "DP3T_LANGUAGE"
    public static let LANGUAGE_EN = "en"
    public static let LANGUAGE_MT = "mt-MT"

    public static func getAppLocale() -> String{
        //Return custom locale
        if let currentLanguage = UserDefaults.standard.string(forKey: DP3T_LANGUAGE){
            return currentLanguage;
        }
        
        //Save and return default locale
        UserDefaults.standard.set(LANGUAGE_EN, forKey: DP3T_LANGUAGE)
        return LANGUAGE_EN;
    }
    
    public static func setAppLocale(localeCode: String) {
        //Save locale
        UserDefaults.standard.set(localeCode, forKey: DP3T_LANGUAGE)
    }
}
