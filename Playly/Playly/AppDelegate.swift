//  AppDelegate.swift
//  Playly – application for controlling iTunes playback from toolbar
//
//  Created by Max on 9/27/19.
//  Copyright © 2019 Max Diachenko. All rights reserved.

import Cocoa
import Paddle

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
    var preferences = Preferences()

    // Paddle
    let myPaddleVendorID = "102595"
    let myPaddleProductID = "572149"
    let myPaddleAPIKey = "823d1b07b1c8cdae8104f9a89be6ff77"
    var paddle: Paddle?
    var paddleProduct: PADProduct?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        checkForOtherInstances()
        initPaddle()
        constructToolbar()
        constructMenu()

        // Check iTunes play state
        ITunesHelper.onStateChange(self, action: #selector(onExternalITunesStateUpdate))

        // Init About window
        AboutWindowController = (mainStoryboard.instantiateController(withIdentifier: "AboutWindowID") as! NSWindowController)

        checkActivationAsync()
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

    func checkForOtherInstances() {
        let allAppInstances = NSWorkspace.shared.runningApplications.filter { app in
            app.bundleIdentifier == Bundle.main.bundleIdentifier
        }

        if allAppInstances.count > 1 {
            quit()
        }
    }

    func updateTooltips() {
        if iTunes.isRunning {
            statusItemPlay.button?.toolTip = "\(iTunes.currentTrack?.artist ?? "") – \(iTunes.currentTrack?.name ?? "")"
        } else {
            statusItemPlay.button?.toolTip = nil
        }
    }

    func changePlayIcon(_ forceImage: String? = nil) {
        statusItemPlay.button?.appearsDisabled = false

        if forceImage != nil {
            statusItemPlay.button?.image = NSImage(named: forceImage!)
        } else {
            if preferences.showArtwork && ITunesHelper.isPlaying() {
                statusItemPlay.button?.image = ITunesHelper.getCurrentPlayingArtwork()
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
}
