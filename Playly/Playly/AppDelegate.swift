//  AppDelegate.swift
//  Playly – application for controlling iTunes playback from toolbar
//
//  Created by Max on 9/27/19.
//  Copyright © 2019 Max Diachenko. All rights reserved.

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let mainStoryboard = NSStoryboard(name: "Main", bundle: nil)
    var AboutWindowController: NSWindowController? = nil
    let iTunes = ITunesHelper.iTunes()
    var preferences = Preferences()

    // Add toolbar items
    let statusItemNext = NSStatusBar.system.statusItem(withLength: 25)
    let statusItemPlay = NSStatusBar.system.statusItem(withLength: 22)
    let statusItemPrev = NSStatusBar.system.statusItem(withLength: 25)

    // Menu
    let menu = NSMenu()

    var startedPressing = false
    var startedPressingAt: Date?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        LaunchAtLogin.isEnabled = preferences.launchAtLogin
        constructStatusBar()
        constructMenu()

        // Check iTunes play state every second
        ITunesHelper.onStateChange(self, action: #selector(onExternalITunesStateUpdate))

        // Check permission ask it if App launch first time
        ITunesHelper.requestPermission()

        // Init About window
        AboutWindowController = (mainStoryboard.instantiateController(withIdentifier: "AboutWindowID") as! NSWindowController)
    }
    
    @objc func onExternalITunesStateUpdate() {
        changePlayIcon()
        updateTooltips()
    }

    func constructStatusBar() {
        // Prev button
        statusItemPrev.button?.action = #selector(onPrevClick)
        statusItemPrev.button?.sendAction(on: [.leftMouseDown, .leftMouseUp])
        statusItemPrev.button?.image = NSImage(named: NSImage.touchBarRewindTemplateName)
        statusItemPrev.button?.image?.size = NSSize(width: 13, height: 25)
        if !preferences.showPrevButton { statusItemPrev.length = 0 }

        // Play/Pause button
        statusItemPlay.button?.action = #selector(onPlayClick)
        statusItemPlay.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])

        // Next button
        statusItemNext.button?.action = #selector(onNextClick)
        statusItemNext.button?.sendAction(on: [.leftMouseDown, .leftMouseUp])
        statusItemNext.button?.image = NSImage(named: NSImage.touchBarFastForwardTemplateName)
        statusItemNext.button?.image?.size = NSSize(width: 13, height: 25)
        if !preferences.showNextButton { statusItemNext.length = 0 }

        changePlayIcon()
        updateTooltips()
    }

    func constructMenu() {
                      menu.addItem(withTitle: "About Playly", action: #selector(showAboutWindow), keyEquivalent: "")
                      menu.addItem(.separator())
        let options = menu.addItem(withTitle: "Options", action: nil, keyEquivalent: "")
                      menu.addItem(.separator())
                      menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q")

        // Submenu for Options
        let submenu = NSMenu(title: "Options")
        let item1 = submenu.addItem(withTitle: "Open at Login", action: #selector(self.toggleLaunchAtLoginOption(_:)), keyEquivalent: "")
                    submenu.addItem(.separator())
        let item2 = submenu.addItem(withTitle: "Show Artwork", action: #selector(self.toggleShowArtworkOption(_:)), keyEquivalent: "")
        let item3 = submenu.addItem(withTitle: "Show Previous Track", action: #selector(self.togglePrevTrackOption(_:)), keyEquivalent: "")
        let item4 = submenu.addItem(withTitle: "Show Next Track", action: #selector(self.toggleNextTrackOption(_:)), keyEquivalent: "")

        // Restore options
        item1.state = preferences.launchAtLogin.toStateValue()
        item2.state = preferences.showArtwork.toStateValue()
        item3.state = preferences.showPrevButton.toStateValue()
        item4.state = preferences.showNextButton.toStateValue()

        menu.setSubmenu(submenu, for: options)
    }

    func updateTooltips() {
        if iTunes.isRunning {
            statusItemPlay.button?.toolTip = "\(iTunes.currentTrack?.artist ?? "") – \(iTunes.currentTrack?.name ?? "")"
        } else {
            statusItemPlay.button?.toolTip = nil
        }
    }

    @objc func toggleLaunchAtLoginOption(_ item: NSMenuItem) {
        if item.state == .on {
            item.state = .off
            LaunchAtLogin.isEnabled = false
            preferences.launchAtLogin = false
        } else {
            item.state = .on
            LaunchAtLogin.isEnabled = true
            preferences.launchAtLogin = true
        }
    }

    @objc func toggleShowArtworkOption(_ item: NSMenuItem) {
        if item.state == .on {
            item.state = .off
            preferences.showArtwork = false
        } else {
            item.state = .on
            preferences.showArtwork = true
        }

        changePlayIcon()
    }

    @objc func togglePrevTrackOption(_ item: NSMenuItem) {
        if item.state == .on {
            item.state = .off
            statusItemPrev.length = 0 // use length over isVisible to keep order when re-enabling
            preferences.showPrevButton = false
        } else {
            item.state = .on
            statusItemPrev.length = 25
            preferences.showPrevButton = true
        }
    }

    @objc func toggleNextTrackOption(_ item: NSMenuItem) {
        if item.state == .on {
            item.state = .off
            statusItemNext.length = 0 // use length over isVisible to keep order when re-enabling
            preferences.showNextButton = false
        } else {
            item.state = .on
            statusItemNext.length = 25
            preferences.showNextButton = true
        }
    }

    @objc func onPrevClick() {
        let isPressing = NSApp.currentEvent?.type == .leftMouseDown
        let wasLongPress = abs(startedPressingAt?.timeIntervalSinceNow ?? 0) > 1

        if isPressing { // Start pressing
            startedPressing = true
            startedPressingAt = Date()

            iTunes.rewind?()
        } else if startedPressing && wasLongPress { // End pressing
            startedPressing = false
            startedPressingAt = nil

            iTunes.resume?()
        } else { // Click
            startedPressing = false
            startedPressingAt = nil

            iTunes.resume?()
            iTunes.backTrack?()
        }
    }

    @objc func onPlayClick() {
        let isRightClick = NSApp.currentEvent?.type == .rightMouseUp
        if isRightClick {
            return statusItemPlay.popUpMenu(menu)
        }

        if !iTunes.isRunning {
            changePlayIcon(NSImage.touchBarPauseTemplateName)
            return ITunesHelper.launchAndPlay()
        }

        iTunes.playpause?()
    }

    @objc func onNextClick() {
        let isPressing = NSApp.currentEvent?.type == .leftMouseDown
        let wasLongPress = abs(startedPressingAt?.timeIntervalSinceNow ?? 0) > 1

        if isPressing { // Start pressing
            startedPressing = true
            startedPressingAt = Date()

            iTunes.fastForward?()
        } else if startedPressing && wasLongPress { // End pressing
            startedPressing = false
            startedPressingAt = nil

            iTunes.resume?()
        } else { // Click
            startedPressing = false
            startedPressingAt = nil

            iTunes.nextTrack?()
        }
    }

    func changePlayIcon(_ forceImage: String? = nil) {
        if forceImage != nil {
            statusItemPlay.button?.image = NSImage(named: forceImage!)
        } else {
            let isPlaying = iTunes.playerState == .playing

            if preferences.showArtwork && isPlaying {
                let artworkImage: NSImage = (iTunes.currentTrack?.artworks?()[0] as AnyObject).data
                artworkImage.size = NSSize(width: 22, height: 22)

                statusItemPlay.button?.image = artworkImage
            } else {
                statusItemPlay.button?.image = NSImage(named: isPlaying ? NSImage.touchBarPauseTemplateName : NSImage.touchBarPlayTemplateName)
            }
        }
    }

    @objc func showAboutWindow() {
        AboutWindowController?.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}
