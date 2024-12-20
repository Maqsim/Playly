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
    let statusItemNext = NSStatusBar.system.statusItem(withLength: 30)
    let statusItemPlay = NSStatusBar.system.statusItem(withLength: 22)
    let statusItemPrev = NSStatusBar.system.statusItem(withLength: 30)

    var AboutWindowController: NSWindowController? = nil
    var UpdaterWindowController: NSWindowController? = nil
    var isPlayerLaunching = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        checkForOtherInstances()
        initToolbar()
        initMenu()

        // Observe for Spotify state change
        Utils.onStateChange(self, action: #selector(onExternalSpotifyStateUpdate))

        // Init About window
        AboutWindowController = (mainStoryboard.instantiateController(withIdentifier: "AboutWindowID") as! NSWindowController)
    }

    @objc func onExternalSpotifyStateUpdate() {
        isPlayerLaunching = false

        changePlayIcon()
        updateTooltips()

        if preferences.hideControlsOnQuit && !Player.shared.isRunning {
            showControls(false)
        } else if preferences.hideControlsOnQuit {
            showControls()
        }

        if Player.shared.isRunning {
            preferences.isShuffling = Player.shared.isShuffling;
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
            Player.shared.getArtwork { image in
                DispatchQueue.main.async {
                    // Update your UI with the artwork
                    if let artwork = image {
                        self.statusItemPlay.button?.image = artwork
                    } else {
                        self.statusItemPlay.button?.image = NSImage(named: NSImage.touchBarPauseTemplateName)
                    }
                }
            }
        } else {
            statusItemPlay.button?.image = NSImage(named: Player.shared.isPlaying ? NSImage.touchBarPauseTemplateName : NSImage.touchBarPlayTemplateName)
        }
    }

    func showControls(_ isEnabled: Bool = true, rerender: Bool = false) {
        if isEnabled && rerender {
            statusItemPrev.isVisible = false
            statusItemPlay.isVisible = false
            statusItemNext.isVisible = false

            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.statusItemNext.isVisible = self.preferences.showNextButton && isEnabled
                self.statusItemPlay.isVisible = isEnabled
                self.statusItemPrev.isVisible = self.preferences.showPrevButton && isEnabled
            }
        } else if !rerender {
            statusItemNext.isVisible = preferences.showNextButton && isEnabled
            statusItemPlay.isVisible = isEnabled
            statusItemPrev.isVisible = preferences.showPrevButton && isEnabled
        }
    }
}
