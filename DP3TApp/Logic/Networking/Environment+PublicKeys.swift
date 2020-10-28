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

extension Environment {
    var jwtPublicKey: Data {
        switch self {
        case .dev:
            return Data(base64Encoded: "dummy-key")!
        case .test:
            return Data(base64Encoded: "dummy-key")!
        case .abnahme:
            return Data(base64Encoded: "dummy-key")!
        case .prod:
            return Data(base64Encoded: "dummy-key")!
        }
    }

    var configJwtPublicKey: Data {
        switch self {
        case .dev:
            return Data(base64Encoded: "dummy-key")!
        case .test:
            return Data(base64Encoded: "dummy-key")!
        case .abnahme:
            return Data(base64Encoded: "dummy-key")!
        case .prod:
            return Data(base64Encoded: "dummy-key")!
        }
    }
}
