//
// Created by Max on 10/1/19.
// Copyright (c) 2019 Max Diachenko. All rights reserved.
//

import Cocoa
import Foundation
import ScriptingBridge

extension Notification.Name {
    static let spotifyPlayerInfo = Notification.Name("com.spotify.client.PlaybackStateChanged")
}

struct Utils {
    static let cache = NSCache<NSString, NSImage>()

    private static func runAppleScript(name: String) {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [Bundle.main.path(forResource: name, ofType: ".scpt", inDirectory: "Resources")!]
        task.launch()
    }

    static func onStateChange(_ sender: Any, action: Selector) {
        DistributedNotificationCenter.default().addObserver(sender, selector: action, name: .spotifyPlayerInfo, object: nil)
    }

    static func launchAndPlay() {
        runAppleScript(name: "run-and-play-music")
    }
}
