//  AppDelegate.swift
//  Playly – application for controlling iTunes playback from toolbar
//
//  Created by Max on 9/27/19.
//  Copyright © 2019 Max Diachenko. All rights reserved.

import Cocoa
import Foundation
import ScriptingBridge

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let mainBundle = Bundle.main
    let app: iTunesApplication = SBApplication(bundleIdentifier: "com.apple.iTunes")!

    // Add toolbar items
    let statusItemNext = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let statusItemPlay = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let statusItemPrev = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItemPrev.button?.target = self
        statusItemPrev.button?.action = #selector(playPrevTrackMusic)
        statusItemPrev.button?.image = NSImage(named: NSImage.goLeftTemplateName)

        statusItemPlay.button?.target = self
        statusItemPlay.button?.action = #selector(playPauseMusic)
        statusItemPlay.length = 22 //  Make width static for different icon widths
        changePlayIcon()

        statusItemNext.button?.target = self
        statusItemNext.button?.action = #selector(playNextTrackMusic)
        statusItemNext.button?.image = NSImage(named: NSImage.goRightTemplateName)

        runAppleScript(name: "request-permission")
    }

    @objc func playPrevTrackMusic() {
        app.previousTrack?()
    }

    @objc func playPauseMusic() {
        if !app.isRunning {
            changePlayIcon(forceFlag: true)
            return runAppleScript(name: "run-and-play")
        }

        app.playpause?()
        changePlayIcon()
    }

    @objc func playNextTrackMusic() {
        app.nextTrack?()
    }

    func changePlayIcon(forceFlag: Bool = false) {
        statusItemPlay.button?.image = NSImage(named: (forceFlag || isITunesPlaying()) ? NSImage.touchBarPauseTemplateName : NSImage.touchBarPlayTemplateName)
    }

    func isITunesPlaying() -> Bool {
        app.playerState == iTunesEPlS.playing;
    }

    func isITunesRunning() -> Bool {
        let command = NSAppleScript(source: "tell application \"iTunes\" to play state is playing")
        var error: NSDictionary? = nil
        let result = command?.executeAndReturnError(&error)

        return result?.booleanValue ?? false
    }

    func runAppleScript(name: String) {
        let task = Process()

        task.launchPath = "/usr/bin/osascript"
        task.arguments = [mainBundle.path(forResource: name, ofType: ".scpt", inDirectory: "scripts")!]
        task.launch()
    }
}
