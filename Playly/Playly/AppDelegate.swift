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
    var lastPlayClickAt: Date?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        LaunchAtLogin.isEnabled = preferences.launchAtLogin
        constructStatusBar()
        constructMenu()

        // Check iTunes play state
        ITunesHelper.onStateChange(self, action: #selector(onExternalITunesStateUpdate))

        // Check permission ask it if App launch first time
        ITunesHelper.requestPermission()

        // Init About window
        AboutWindowController = (mainStoryboard.instantiateController(withIdentifier: "AboutWindowID") as! NSWindowController)
    }
    
    @objc func onExternalITunesStateUpdate() {
        changePlayIcon()
        updateTooltips()

        if preferences.hideControlsOnQuit && !iTunes.isRunning {
            showControls(false)
        } else {
            showControls()
        }
    }

    func constructStatusBar() {
        // Prev button
        statusItemPrev.button?.action = #selector(onPrevClick)
        statusItemPrev.button?.sendAction(on: [.leftMouseDown, .leftMouseUp])
        statusItemPrev.button?.image = NSImage(named: NSImage.touchBarRewindTemplateName)
        statusItemPrev.button?.image?.size = NSSize(width: 13, height: 25)
        if !preferences.showPrevButton { showControls(item: statusItemPrev, isEnabled: false) }

        // Play/Pause button
        statusItemPlay.button?.action = #selector(onPlayClick)
        statusItemPlay.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])

        // Next button
        statusItemNext.button?.action = #selector(onNextClick)
        statusItemNext.button?.sendAction(on: [.leftMouseDown, .leftMouseUp])
        statusItemNext.button?.image = NSImage(named: NSImage.touchBarFastForwardTemplateName)
        statusItemNext.button?.image?.size = NSSize(width: 13, height: 25)
        if !preferences.showNextButton { showControls(item: statusItemNext, isEnabled: false) }

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
        let item2 = submenu.addItem(withTitle: "Artwork Inside Play Button", action: #selector(self.toggleShowArtworkOption(_:)), keyEquivalent: "")
        let item3 = submenu.addItem(withTitle: "Hide Controls on Player Quit", action: #selector(self.toggleHideControlsOnQuitOption(_:)), keyEquivalent: "")
                    submenu.addItem(.separator())
                    submenu.addItem(withTitle: "Controls", action: nil, keyEquivalent: "")
        let item4 = submenu.addItem(withTitle: "Previous Track", action: #selector(self.togglePrevTrackOption(_:)), keyEquivalent: "")
        let item5 = submenu.addItem(withTitle: "Next Track", action: #selector(self.toggleNextTrackOption(_:)), keyEquivalent: "")

        // Restore options
        item1.state = preferences.launchAtLogin.toStateValue()
        item2.state = preferences.showArtwork.toStateValue()
        item3.state = preferences.hideControlsOnQuit.toStateValue()
        item4.state = preferences.showPrevButton.toStateValue()
        item5.state = preferences.showNextButton.toStateValue()

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

    @objc func toggleHideControlsOnQuitOption(_ item: NSMenuItem) {
        if item.state == .on {
            item.state = .off
            preferences.hideControlsOnQuit = false
        } else {
            item.state = .on
            preferences.hideControlsOnQuit = true
        }
    }

    @objc func togglePrevTrackOption(_ item: NSMenuItem) {
        if item.state == .on {
            item.state = .off
            showControls(item: statusItemPrev, isEnabled: false)
            preferences.showPrevButton = false
        } else {
            item.state = .on
            showControls(item: statusItemPrev)
            preferences.showPrevButton = true
        }
    }

    @objc func toggleNextTrackOption(_ item: NSMenuItem) {
        if item.state == .on {
            item.state = .off
            showControls(item: statusItemNext, isEnabled: false)
            preferences.showNextButton = false
        } else {
            item.state = .on
            statusItemNext.length = 25
            showControls(item: statusItemNext)
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
        // Show popup menu on right click
        let isRightClick = NSApp.currentEvent?.type == .rightMouseUp
        if isRightClick {
            return statusItemPlay.popUpMenu(menu)
        }

        // Launch iTunes if not running
        if !iTunes.isRunning {
            // Loading icon
            if let clockImage = NSImage(named: NSImage.touchBarHistoryTemplateName) {
                clockImage.size = NSSize(width: 15, height: 25)
                statusItemPlay.button?.image = clockImage
                statusItemPlay.button?.appearsDisabled = true
            }

            return ITunesHelper.launchAndPlay()
        }

        // Double click
        let isDoubleClick = abs(lastPlayClickAt?.timeIntervalSinceNow ?? 1) < 0.2
        let wasPlaying = !ITunesHelper.isPlaying()

        if isDoubleClick && wasPlaying && !preferences.showNextButton {
            iTunes.nextTrack?()

            lastPlayClickAt = nil
        } else {
            lastPlayClickAt = Date()
        }

        // Single click
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
        statusItemPlay.button?.appearsDisabled = false

        if forceImage != nil {
            statusItemPlay.button?.image = NSImage(named: forceImage!)
        } else {
            if preferences.showArtwork && ITunesHelper.isPlaying() {
                let artworkImage: NSImage = (iTunes.currentTrack?.artworks?()[0] as AnyObject).data
                artworkImage.size = NSSize(width: 22, height: 22)

                statusItemPlay.button?.image = artworkImage
            } else {
                statusItemPlay.button?.image = NSImage(named: ITunesHelper.isPlaying() ? NSImage.touchBarPauseTemplateName : NSImage.touchBarPlayTemplateName)
            }
        }
    }

    func showControls(_ isEnabled: Bool = true) {
        showControls(item: statusItemPrev, isEnabled: preferences.showPrevButton && isEnabled)
        showControls(item: statusItemNext, isEnabled: preferences.showNextButton && isEnabled)
    }

    func showControls(item: NSStatusItem, isEnabled: Bool = true) {
        // Used NSStatusItem length over isVisible to keep order when re-enabling
        item.length = isEnabled ? 25 : 0
    }

    @objc func showAboutWindow() {
        AboutWindowController?.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}
