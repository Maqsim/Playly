//
// Created by Max on 10/4/19.
// Copyright (c) 2019 Max Diachenko. All rights reserved.
//

import Cocoa
import Foundation

extension AppDelegate {
    func initMenu() {
        let about = menu.addItem(withTitle: "About Playly", action: #selector(showAboutWindow), keyEquivalent: "")
//        let updater = menu.addItem(withTitle: "Check for Updates...", action: #selector(onCheckForUpdates), keyEquivalent: "")

        if isTrial {
            menu.addItem(withTitle: "Register...", action: #selector(showActivationWindow), keyEquivalent: "")
        }

//        menu.addItem(withTitle: "Help", action: #selector(showAboutWindow), keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Show iTunes", action: #selector(showITunes), keyEquivalent: "")
        let shuffle =  menu.addItem(withTitle: "Shuffle", action: #selector(self.toggleShuffle(_:)), keyEquivalent: "")
        shuffle.state = iTunes.shuffleEnabled as! Bool ? .on : .off
        let playlistsMenu = menu.addItem(withTitle: "Play Playlist", action: nil, keyEquivalent: "")
        menu.addItem(.separator())
        let options =  menu.addItem(withTitle: "Preferences", action: nil, keyEquivalent: "")
        menu.addItem(.separator())
        let quitAll =  menu.addItem(withTitle: "Quit with iTunes", action: #selector(quitWithITunes), keyEquivalent: "q")
        quitAll.keyEquivalentModifierMask = NSEvent.ModifierFlags(arrayLiteral: [.shift, .command])
        menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q")

        // Submenu for Preferences
        let submenu = NSMenu(title: "Preferences")
        let item1 = submenu.addItem(withTitle: "Open at Login", action: #selector(self.toggleLaunchAtLoginOption(_:)), keyEquivalent: "")
        submenu.addItem(.separator())
        let item2 = submenu.addItem(withTitle: "Artwork Inside Play Button", action: #selector(self.toggleShowArtworkOption(_:)), keyEquivalent: "")
        let item3 = submenu.addItem(withTitle: "Hide Controls when iTunes Quit", action: #selector(self.toggleHideControlsOnQuitOption(_:)), keyEquivalent: "")
        submenu.addItem(.separator())
        let item4 = submenu.addItem(withTitle: "Previous Track Button", action: #selector(self.togglePrevTrackOption(_:)), keyEquivalent: "")
        let item5 = submenu.addItem(withTitle: "Next Track Button", action: #selector(self.toggleNextTrackOption(_:)), keyEquivalent: "")

        // Restore options
        item1.state = preferences.launchAtLogin.toStateValue()
        item2.state = preferences.showArtwork.toStateValue()
        item3.state = preferences.hideControlsOnQuit.toStateValue()
        item4.state = preferences.showPrevButton.toStateValue()
        item5.state = preferences.showNextButton.toStateValue()

        let playlists = (iTunes.sources?()[0] as! iTunesSource).userPlaylists?() ?? []
        if playlists.count > 0 {
            // Submenu for Play Playlist
            let submenuPlaylist = NSMenu(title: "Preferences")

            for item in (iTunes.sources?()[0] as! iTunesSource).userPlaylists?() ?? [] {
                let playlist = item as! iTunesPlaylist

                if playlist.tracks?().get()?.count ?? 0 > 0 {
                    let menuItem = submenuPlaylist.addItem(withTitle: playlist.name!, action: #selector(self.playPlaylist(_:)), keyEquivalent: "")
                    menuItem.representedObject = playlist
                }
            }

            menu.setSubmenu(submenuPlaylist, for: playlistsMenu)
        } else {
            menu.removeItem(playlistsMenu)
        }

        menu.setSubmenu(submenu, for: options)
    }

    @objc func toggleShuffle(_ item: NSMenuItem) {
        if item.state == .on {
            item.state = .off
            iTunes.setShuffleEnabled?(false)
        } else {
            item.state = .on
            iTunes.setShuffleEnabled?(true)
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

        if preferences.hideControlsOnQuit && !iTunes.isRunning {
            showControls(false)
        } else {
            showControls()
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

    @objc func playPlaylist(_ item: NSMenuItem) {
        let playlist = item.representedObject as! iTunesPlaylist

        playlist.playOnce?(false)
    }

    @objc func onCheckForUpdates() {
        UpdaterWindowController?.showWindow(self)
    }

    @objc func showITunes() {
        iTunes.activate()
    }

    @objc func showAboutWindow() {
        AboutWindowController?.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }

    @objc func quitWithITunes() {
        iTunes.quit?()
        NSApplication.shared.terminate(self)
    }
}
