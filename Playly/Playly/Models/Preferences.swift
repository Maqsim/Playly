//
// Created by Max on 10/1/19.
// Copyright (c) 2019 Max Diachenko. All rights reserved.
//

import Foundation
import AppKit

struct Preferences {
    private let defaults = UserDefaults.standard

    var launchAtLogin: Bool {
        get {
            defaults.object(forKey: "launchAtLogin") as? Bool ?? true
        }

        set {
            defaults.set(newValue, forKey: "launchAtLogin")
        }
    }

    var showPrevButton: Bool {
        get {
            defaults.object(forKey: "showPrevButton") as? Bool ?? true
        }

        set {
            defaults.set(newValue, forKey: "showPrevButton")
        }
    }

    var showNextButton: Bool {
        get {
            defaults.object(forKey: "showNextButton") as? Bool ?? true
        }

        set {
            defaults.set(newValue, forKey: "showNextButton")
        }
    }
}

extension Bool {
    func toStateValue() -> NSControl.StateValue {
        self ? .on : .off
    }
}
