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

/// The backend environment under which the application runs.
enum Environment {
    case dev
    case test
    case abnahme
    case prod

    /// The current environment, as configured in build settings.
    static var current: Environment {
        #if DEBUG
            return .dev
        #elseif RELEASE_DEV
            return .dev
        #elseif RELEASE_TEST
            return .test
        #elseif RELEASE_ABNAHME
            return .abnahme
        #elseif RELEASE_PROD
            return .prod
        #else
            fatalError("Missing build setting for environment")
        #endif
    }

    var codegenService: Backend {
        switch self {
        case .dev:
            return Backend("https://dummy-auth-url.com", version: "v1")
        case .test:
            return Backend("https://dummy-auth-url.com", version: "v1")
        case .abnahme:
            return Backend("https://dummy-auth-url.com", version: "v1")
        case .prod:
            return Backend("https://dummy-auth-url.com", version: "v1")
        }
    }

    var configService: Backend {
        switch self {
        case .dev:
            return Backend("https://dummy-config-url.com", version: "v1")
        case .test:
            return Backend("https://dummy-config-url.com", version: "v1")
        case .abnahme:
            return Backend("https://dummy-config-url.com", version: "v1")
        case .prod:
            return Backend("https://dummy-config-url.com", version: "v1")
        }
    }

    var publishService: Backend {
        switch self {
        case .dev:
            return Backend("https://dummy-ws-url.com", version: "v1")
        case .test:
            return Backend("https://dummy-ws-url.com", version: "v1")
        case .abnahme:
            return Backend("https://dummy-ws-url.com", version: "v1")
        case .prod:
            return Backend("https://dummy-ws-url.com", version: "v1")
        }
    }
}
