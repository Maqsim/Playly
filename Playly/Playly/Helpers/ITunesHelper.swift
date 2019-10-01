//
// Created by Max on 10/1/19.
// Copyright (c) 2019 Max Diachenko. All rights reserved.
//

import Foundation
import ScriptingBridge

extension Notification.Name {
    static let iTunesPlayerInfo = Notification.Name("com.apple.iTunes.playerInfo")
}

struct ITunesHelper {
    private static func runAppleScript(name: String) {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [Bundle.main.path(forResource: name, ofType: ".scpt", inDirectory: "Resources")!]
        task.launch()
    }

    static func iTunes() -> iTunesApplication {
        SBApplication(bundleIdentifier: "com.apple.iTunes")!
    }

    static func onStateChange(_ sender: Any, action: Selector) {
        DistributedNotificationCenter.default().addObserver(sender, selector: action, name: .iTunesPlayerInfo, object: nil)
    }

    static func requestPermission() {
        runAppleScript(name: "request-permission")
    }

    static func launchAndPlay() {
        runAppleScript(name: "run-and-play")
    }
}
