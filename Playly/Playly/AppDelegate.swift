//  AppDelegate.swift
//  Playly – application for controlling iTunes playback from toolbar
//
//  Created by Max on 9/27/19.
//  Copyright © 2019 Max Diachenko. All rights reserved.

import Cocoa
import ScriptingBridge

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var startedPressing: Bool = false
    var startedPressingAt: Date?
    let mainBundle = Bundle.main
    let iTunes: iTunesApplication = SBApplication(bundleIdentifier: "com.apple.iTunes")!
    let aboutView = ViewController()

    // Add toolbar items
    let statusItemNext = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let statusItemPlay = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let statusItemPrev = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    // Menu
    let menu = NSMenu()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        LaunchAtLogin.isEnabled = true
        constructStatusBarItems()
        constructMenu()
        runAppleScript(name: "request-permission")

        Timer.scheduledTimer(timeInterval: 1, target: self, selector: "checkITunesState", userInfo: nil, repeats: true)
    }

    @objc func checkITunesState() {
        changePlayIcon()
        updateTooltips()
    }

    func constructStatusBarItems() {
        // Prev button
        statusItemPrev.button?.action = "onPrevClick"
        statusItemPrev.button?.sendAction(on: [.leftMouseDown, .leftMouseUp])
        statusItemPrev.button?.image = NSImage(named: NSImage.touchBarRewindTemplateName)
        statusItemPrev.button?.image?.size = NSSize(width: 13, height: 25)

        // Play/Pause button
        statusItemPlay.button?.action = "onPlayClick"
        statusItemPlay.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        statusItemPlay.length = 22 //  Make button width static to look the same for different icons
        changePlayIcon()

        // Next button
        statusItemNext.button?.action = "onNextClick"
        statusItemNext.button?.sendAction(on: [.leftMouseDown, .leftMouseUp])
        statusItemNext.button?.image = NSImage(named: NSImage.touchBarFastForwardTemplateName)
        statusItemNext.button?.image?.size = NSSize(width: 13, height: 25)

        updateTooltips()
    }

    func constructMenu() {
                      menu.addItem(withTitle: "About Playly", action: #selector(showAboutWindow), keyEquivalent: "")
        let options = menu.addItem(withTitle: "Options", action: nil, keyEquivalent: "")
                      menu.addItem(.separator())
                      menu.addItem(withTitle: "Quit", action: "quit", keyEquivalent: "q")

        // Submenu for Options
        let submenu = NSMenu(title: "Options")
        let item1 = submenu.addItem(withTitle: "Launch At Login", action: #selector(self.toggleLaunchAtLoginOption(_:)), keyEquivalent: "")
                    submenu.addItem(.separator())
        let item2 = submenu.addItem(withTitle: "Show Previous Track", action: #selector(self.togglePrevTrackOption(_:)), keyEquivalent: "")
        let item3 = submenu.addItem(withTitle: "Show Next Track", action: #selector(self.toggleNextTrackOption(_:)), keyEquivalent: "")
        (item1.state, item2.state, item3.state) = (.on, .on, .on)

        menu.setSubmenu(submenu, for: options)
    }

    func updateTooltips() {
        statusItemPlay.button?.toolTip = "\(iTunes.currentTrack?.artist ?? "") – \(iTunes.currentTrack?.name ?? "") (\(secondsToString(TimeInterval(iTunes.playerPosition!))))"
    }

    @objc func toggleLaunchAtLoginOption(_ item: NSMenuItem) {
        if item.state == .on {
            item.state = .off
            LaunchAtLogin.isEnabled = false
        } else {
            item.state = .on
            LaunchAtLogin.isEnabled = true
        }
    }

    @objc func togglePrevTrackOption(_ item: NSMenuItem) {
        if item.state == .on {
            item.state = .off
            statusItemPrev.length = 0 // use length over isVisible to keep order when re-enabling
        } else {
            item.state = .on
            statusItemPrev.length = NSStatusItem.variableLength
        }
    }

    @objc func toggleNextTrackOption(_ item: NSMenuItem) {
        if item.state == .on {
            item.state = .off
            statusItemNext.length = 0 // use length over isVisible to keep order when re-enabling
        } else {
            item.state = .on
            statusItemNext.length = NSStatusItem.variableLength
        }
    }

    @objc func onPrevClick() {
        let isPressing = NSApp.currentEvent?.type == NSEvent.EventType.leftMouseDown

        if isPressing { // Start pressing
            startedPressing = true
            startedPressingAt = Date()

            iTunes.rewind?()
        } else if startedPressing && abs(startedPressingAt?.timeIntervalSinceNow ?? 0) > 1 { // End pressing
            startedPressing = false
            startedPressingAt = nil

            iTunes.resume?()
        } else { // Click
            startedPressing = false
            startedPressingAt = nil

            iTunes.backTrack?()
        }

        updateTooltips()
    }

    @objc func onPlayClick() {
        let isRightClick = NSApp.currentEvent?.type == NSEvent.EventType.rightMouseUp
        if isRightClick {
            return statusItemPlay.popUpMenu(menu)
        }

        // Left click

        if !iTunes.isRunning {
            changePlayIcon(true)
            return runAppleScript(name: "run-and-play")
        }

        iTunes.playpause?()
        changePlayIcon()
        updateTooltips()
    }

    @objc func onNextClick() {
        let isPressing = NSApp.currentEvent?.type == NSEvent.EventType.leftMouseDown

        if isPressing { // Start pressing
            startedPressing = true
            startedPressingAt = Date()

            iTunes.fastForward?()
        } else if startedPressing && abs(startedPressingAt?.timeIntervalSinceNow ?? 0) > 1 { // End pressing
            startedPressing = false
            startedPressingAt = nil

            iTunes.resume?()
        } else { // Click
            startedPressing = false
            startedPressingAt = nil

            iTunes.nextTrack?()
        }

        updateTooltips()
    }

    func changePlayIcon(_ forceFlag: Bool? = nil) {
        statusItemPlay.button?.image = NSImage(named: (forceFlag != nil && forceFlag == true || isPlaying()) ? NSImage.touchBarPauseTemplateName : NSImage.touchBarPlayTemplateName)
    }

    func isPlaying() -> Bool {
        iTunes.playerState == .playing;
    }

    func runAppleScript(name: String) {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [mainBundle.path(forResource: name, ofType: ".scpt", inDirectory: "scripts")!]
        task.launch()
    }

    @objc func showAboutWindow() {
        let mainStoryboard = NSStoryboard.init(name: "Main", bundle: nil)
        let myWindowController = mainStoryboard.instantiateController(withIdentifier: "foo") as! NSWindowController
        myWindowController.showWindow(self)
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }

    func secondsToString(_ seconds: TimeInterval) -> String {
        if seconds.isNaN {
            return "00:00"
        }
        let Min = Int(seconds / 60)
        let Sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", Min, Sec)
    }
}
