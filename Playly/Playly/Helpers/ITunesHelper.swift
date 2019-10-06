//
// Created by Max on 10/1/19.
// Copyright (c) 2019 Max Diachenko. All rights reserved.
//

import Cocoa
import Foundation
import ScriptingBridge

extension Notification.Name {
    static let iTunesPlayerInfo = Notification.Name("com.apple.iTunes.playerInfo")
}

struct ITunesHelper {
    static let cache = NSCache<NSString, NSImage>()
    private static let _iTunes: iTunesApplication = SBApplication(bundleIdentifier: "com.apple.iTunes")!

    private static func runAppleScript(name: String) {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [Bundle.main.path(forResource: name, ofType: ".scpt", inDirectory: "Resources")!]
        task.launch()
    }

    static func iTunes() -> iTunesApplication {
        _iTunes
    }

    static func isPlaying() -> Bool {
        _iTunes.isRunning && _iTunes.playerState == .playing
    }

    static func getCurrentPlayingArtwork() -> NSImage? {
        let currentTrack: iTunesTrack = _iTunes.currentTrack!
        let currentTrackId: Int = currentTrack.id?() as! Int
        let cacheKey = NSString(string: String(currentTrackId))

        if let cachedVersion = cache.object(forKey: cacheKey) {
            return cachedVersion
        } else {
            if ((currentTrack.artworks?()[0] as AnyObject).rawData as Data).isEmpty {
                return nil
            }

            let artworkImage: NSImage = (currentTrack.artworks?()[0] as AnyObject).data
            artworkImage.size = NSSize(width: 22, height: 22)

            cache.setObject(artworkImage, forKey: cacheKey)

            return artworkImage
        }
    }

    static func onStateChange(_ sender: Any, action: Selector) {
        DistributedNotificationCenter.default().addObserver(sender, selector: action, name: .iTunesPlayerInfo, object: nil)
    }

    static func launchAndPlay() {
        runAppleScript(name: "run-and-play")
    }
}
