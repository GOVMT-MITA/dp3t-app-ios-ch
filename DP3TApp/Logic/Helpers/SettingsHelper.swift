import UIKit
import DP3TSDK

class SettingsHelper: NSObject {
    public static let DP3T_LANGUAGE_LEGACY = "DP3T_LANGUAGE"
    public static let LANGUAGE_EN = "en"
    public static let LANGUAGE_MT = "mt-MT"
    
    public static let SETTINGS_LANGUAGE = "settings_language"
    public static let SETTINGS_WIFI_SYNC = "settings_wifi_sync"
    public static let SETTINGS_INTEROP_MODE = "settings_interop_mode"
    public static let SETTINGS_INTEROP_SELECTED_COUNTRIES = "settings_interop_selected_countries"

    public static func getActiveLanguageCode() -> String{
        
        //Return custom locale
        if let currentLanguage = UserDefaults.standard.string(forKey: SETTINGS_LANGUAGE){
            return currentLanguage;
        } else
        //Set default if not present
        {
            var defaultLocale = LANGUAGE_EN
            
            //Migrate legacy
            if let legacyLanguage = UserDefaults.standard.string(forKey: DP3T_LANGUAGE_LEGACY){
                defaultLocale = legacyLanguage
                UserDefaults.standard.removeObject(forKey: DP3T_LANGUAGE_LEGACY)
            }
            
            //Save and return default locale
            UserDefaults.standard.set(defaultLocale, forKey: SETTINGS_LANGUAGE)
            return defaultLocale;
        }
    }
    
    public static func setActiveLanguage(localeCode: String) {
        UserDefaults.standard.set(localeCode, forKey: SETTINGS_LANGUAGE)
    }
    
    public static func getWifiSync() -> Bool {
        if let wifiSync = UserDefaults.standard.object(forKey: SETTINGS_WIFI_SYNC), wifiSync is Bool{
            return wifiSync as! Bool
        } else
        {
            UserDefaults.standard.set(false, forKey: SETTINGS_WIFI_SYNC)
            return false
        }
    }
    
    public static func setWifiSync(wifiSync: Bool) {
        UserDefaults.standard.set(wifiSync, forKey: SETTINGS_WIFI_SYNC)
        DP3TTracing.setForcedWifiSyncStatus(forcedWifiSync: wifiSync)
    }
    
    public static func getInteropState() -> UIStateModel.InteroperabilityState {
        if let interopState = UserDefaults.standard.object(forKey: SETTINGS_INTEROP_MODE), interopState is Int{
            return UIStateModel.InteroperabilityState(rawValue: interopState as! Int)!
        }
        else
        {
            return UIStateModel.InteroperabilityState.legacy
        }
    }
    
    public static func setInteropState(interopState: UIStateModel.InteroperabilityState) {
        UserDefaults.standard.set(interopState.rawValue, forKey: SETTINGS_INTEROP_MODE)
        DP3TTracing.setInteroperabilityState(interopState: getSDKInteropState(interopState: interopState))
        UIStateManager.shared.refresh()
    }
    
    public static func getInteropSelectedCountries() -> [String] {
        if let countries = UserDefaults.standard.stringArray(forKey: SETTINGS_INTEROP_SELECTED_COUNTRIES){
            return countries
        }
        else
        {
            let emptyArray: [String] = []
            UserDefaults.standard.set(emptyArray, forKey: SETTINGS_INTEROP_SELECTED_COUNTRIES)
            return emptyArray
        }
    }
    
    public static func setInteropSelectedCountries(countries: [String]) {
        UserDefaults.standard.set(countries, forKey: SETTINGS_INTEROP_SELECTED_COUNTRIES)
        DP3TTracing.setInteroperabilitySelectedCountries(interopSelectedCountries: countries)
        UIStateManager.shared.refresh()
    }
    
    private static func getSDKInteropState(interopState: UIStateModel.InteroperabilityState) -> InteroperabilityState {
        switch interopState {
        case .eu:
            return .eu
        case .countries_update_pending: fallthrough
        case .countries:
            return .countries
        case .legacy: fallthrough
        case .disabled_silent: fallthrough
        case .disabled: fallthrough
        default:
            return .disabled
        }
    }
}
