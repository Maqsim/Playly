//  AppDelegate.swift
//  Playly – application for controlling iTunes playback from toolbar
//
//  Created by Max on 9/27/19.
//  Copyright © 2019 Max Diachenko. All rights reserved.

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let mainStoryboard = NSStoryboard(name: "Main", bundle: nil)
    let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    let haptic = NSHapticFeedbackManager.defaultPerformer
    let menu = NSMenu()
    var preferences = Preferences()
    let statusItemNext = NSStatusBar.system.statusItem(withLength: Preferences.MENU_ICON_WIDTH)
    let statusItemPlay = NSStatusBar.system.statusItem(withLength: 22)
    let statusItemPrev = NSStatusBar.system.statusItem(withLength: Preferences.MENU_ICON_WIDTH)

    var AboutWindowController: NSWindowController? = nil
    var UpdaterWindowController: NSWindowController? = nil
    var isPlayerLaunching = false

    // Paddle
//    let myPaddleVendorID = "102595"
//    let myPaddleProductID = "572149"
//    let myPaddleAPIKey = "823d1b07b1c8cdae8104f9a89be6ff77"
//    var paddle: Paddle?
//    var paddleProduct: PADProduct?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        checkForOtherInstances()
//        initPaddle()
        initToolbar()
        initMenu()

        // Observe for iTunes state change
        Utils.onStateChange(self, action: #selector(onExternalSpotifyStateUpdate))

        // Init About window
        AboutWindowController = (mainStoryboard.instantiateController(withIdentifier: "AboutWindowID") as! NSWindowController)
        UpdaterWindowController = (mainStoryboard.instantiateController(withIdentifier: "UpdaterWindowID") as! NSWindowController)

//        checkActivationAsync()
    }

    @objc func onExternalSpotifyStateUpdate() {
        isPlayerLaunching = false

        changePlayIcon()
        updateTooltips()

        if preferences.hideControlsOnQuit && !Player.shared.isRunning {
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
        if Player.shared.isRunning && !Player.shared.isStopped {
            statusItemPlay.button?.toolTip = Player.shared.trackName
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

        if preferences.showArtwork && Player.shared.isPlaying {
            let artwork = Player.shared.getArtwork()
            statusItemPlay.button?.image = artwork != nil ? artwork : NSImage(named: NSImage.touchBarPauseTemplateName)
        } else {
            statusItemPlay.button?.image = NSImage(named: Player.shared.isPlaying ? NSImage.touchBarPauseTemplateName : NSImage.touchBarPlayTemplateName)
        }
    }

    func showControls(_ isEnabled: Bool = true) {
        showControls(item: statusItemPrev, isEnabled: preferences.showPrevButton && isEnabled)
        showControls(item: statusItemNext, isEnabled: preferences.showNextButton && isEnabled)
    }

    func showControls(item: NSStatusItem, isEnabled: Bool = true) {
        // Used NSStatusItem length over isVisible to keep order when re-enabling
        item.length = isEnabled ? Preferences.MENU_ICON_WIDTH : 0
    }
}
