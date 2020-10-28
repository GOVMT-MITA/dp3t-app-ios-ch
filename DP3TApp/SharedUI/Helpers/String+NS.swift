import UIKit

extension String {
    var ub_localized: String {
        let path = Bundle.main.path(forResource: LanguageHelper.getAppLocale(), ofType: "lproj")
        let bundle = Bundle(path: path!)
        
        return NSLocalizedString(self,tableName: nil, bundle:  bundle!, value:"", comment: "")
    }

    static var languageKey: String {
        "language_key".ub_localized
    }

    static var defaultLanguageKey: String {
        LanguageHelper.getAppLocale()
    }
}
