//  AppDelegate.swift
//  Playly – application for controlling iTunes playback from toolbar
//
//  Created by Max on 9/27/19.
//  Copyright © 2019 Max Diachenko. All rights reserved.

import Cocoa
import Paddle
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let mainStoryboard = NSStoryboard(name: "Main", bundle: nil)
    let iTunes = ITunesHelper.iTunes()
    let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    let haptic = NSHapticFeedbackManager.defaultPerformer
    let menu = NSMenu()
    let statusItemNext = NSStatusBar.system.statusItem(withLength: 25)
    let statusItemPlay = NSStatusBar.system.statusItem(withLength: 22)
    let statusItemPrev = NSStatusBar.system.statusItem(withLength: 25)

    var AboutWindowController: NSWindowController? = nil
    var UpdaterWindowController: NSWindowController? = nil
    var preferences = Preferences()
    var isPlayerLaunching = false

    // Paddle
    let myPaddleVendorID = "102595"
    let myPaddleProductID = "572149"
    let myPaddleAPIKey = "823d1b07b1c8cdae8104f9a89be6ff77"
    var paddle: Paddle?
    var paddleProduct: PADProduct?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        checkForOtherInstances()
        initPaddle()
        initToolbar()
        initMenu()

        // Observe for iTunes state change
        ITunesHelper.onStateChange(self, action: #selector(onExternalITunesStateUpdate))

        // Init About window
        AboutWindowController = (mainStoryboard.instantiateController(withIdentifier: "AboutWindowID") as! NSWindowController)
        UpdaterWindowController = (mainStoryboard.instantiateController(withIdentifier: "UpdaterWindowID") as! NSWindowController)

        checkActivationAsync()
    }

    @objc func onExternalITunesStateUpdate() {
        isPlayerLaunching = false

        changePlayIcon()
        updateTooltips()

        if preferences.hideControlsOnQuit && !iTunes.isRunning {
            showControls(false)
        } else {
            showControls()
        }
    }

    func checkForOtherInstances() {
        let allAppInstances = NSWorkspace.shared.runningApplications.filter { app in
            app.bundleIdentifier == Bundle.main.bundleIdentifier
        }

        if allAppInstances.count > 1 {
            quit()
        }
    }

    func updateTooltips() {
        if iTunes.isRunning && iTunes.playerState != .stopped {
            statusItemPlay.button?.toolTip = "\(iTunes.currentTrack?.artist ?? "") – \(iTunes.currentTrack?.name ?? "")"
        } else {
            statusItemPlay.button?.toolTip = nil
        }
    }


    func changePlayIcon(_ forceImageName: String) {
        statusItemPlay.button?.appearsDisabled = false
        statusItemPlay.button?.image = NSImage(named: forceImageName)
    }

    func changePlayIcon() {
        statusItemPlay.button?.appearsDisabled = false

        if preferences.showArtwork && ITunesHelper.isPlaying() {
            let artwork = ITunesHelper.getCurrentPlayingArtwork()

            statusItemPlay.button?.image = artwork != nil ? artwork : NSImage(named: NSImage.touchBarPauseTemplateName)
        } else {
            statusItemPlay.button?.image = NSImage(named: ITunesHelper.isPlaying() ? NSImage.touchBarPauseTemplateName : NSImage.touchBarPlayTemplateName)
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
}
