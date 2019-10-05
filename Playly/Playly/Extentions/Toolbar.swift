//
// Created by Max on 10/4/19.
// Copyright (c) 2019 Max Diachenko. All rights reserved.
//

import Cocoa
import Foundation

extension AppDelegate {
    func initToolbar() {
        // Prev button
        statusItemPrev.button?.action = #selector(onPrevClick)
        statusItemPrev.button?.image = NSImage(named: NSImage.touchBarRewindTemplateName)
        statusItemPrev.button?.image?.size = NSSize(width: 13, height: 25)
        if !preferences.showPrevButton || !iTunes.isRunning && preferences.hideControlsOnQuit {
            showControls(item: statusItemPrev, isEnabled: false)
        }

        let prevTrackLongPressRecognizer = NSPressGestureRecognizer(target: self, action: #selector(self.rewind(_:)))
        prevTrackLongPressRecognizer.minimumPressDuration = 0.5
        statusItemPrev.button?.addGestureRecognizer(prevTrackLongPressRecognizer)

        // Play/Pause button
        statusItemPlay.button?.action = #selector(onPlayClick)
        statusItemPlay.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])

        // Next button
        statusItemNext.button?.action = #selector(onNextClick)
        statusItemNext.button?.image = NSImage(named: NSImage.touchBarFastForwardTemplateName)
        statusItemNext.button?.image?.size = NSSize(width: 13, height: 25)
        if !preferences.showNextButton || !iTunes.isRunning && preferences.hideControlsOnQuit {
            showControls(item: statusItemNext, isEnabled: false)
        }

        let nextTrackLongPressRecognizer = NSPressGestureRecognizer(target: self, action: #selector(self.fastForward(_:)))
        nextTrackLongPressRecognizer.minimumPressDuration = 0.5
        statusItemNext.button?.addGestureRecognizer(nextTrackLongPressRecognizer)

        changePlayIcon()
        updateTooltips()
    }

    @objc func rewind(_ event: NSPressGestureRecognizer) {
        if !ITunesHelper.isPlaying() || needActivation {
            return
        }

        if event.state == .began {
            // Haptic feedback
            timer.scheduleRepeating(deadline: .now(), interval: 0.3)
            timer.setEventHandler {
                self.iTunes.setPlayerPosition?(self.iTunes.playerPosition! - 3)
                self.haptic.perform(.generic, performanceTime: .default)
            }
            timer.resume()
        } else if event.state == .ended {
            timer.suspend()
        }
    }

    @objc func fastForward(_ event: NSPressGestureRecognizer) {
        if !ITunesHelper.isPlaying() || needActivation {
            return
        }

        if event.state == .began {
            // Haptic feedback
            timer.scheduleRepeating(deadline: .now(), interval: 0.1)
            timer.setEventHandler {
                self.iTunes.setPlayerPosition?(self.iTunes.playerPosition! + 3)
                self.haptic.perform(.generic, performanceTime: .default)
            }
            timer.resume()
        } else if event.state == .ended {
            timer.suspend()
        }
    }

    @objc func onPrevClick() {
        if isPlayerLaunching {
            return
        }

        if !iTunes.isRunning {
            return onPlayClick()
        }

        iTunes.backTrack?()
    }

    @objc func onPlayClick() {
        if isPlayerLaunching {
            return
        }

        let event = NSApp.currentEvent!

        // Show popup menu on right click
        let isRightClick = NSApp.currentEvent?.type == .rightMouseUp
        if isRightClick {
            return statusItemPlay.popUpMenu(menu)
        }

        // Launch iTunes if not running
        if !iTunes.isRunning {
            isPlayerLaunching = true

            // Loading icon
            if let clockImage = NSImage(named: NSImage.touchBarHistoryTemplateName) {
                clockImage.size = NSSize(width: 15, height: 25)
                statusItemPlay.button?.image = clockImage
                statusItemPlay.button?.appearsDisabled = true
            }

            return ITunesHelper.launchAndPlay()
        }

        // Double click
        let isDoubleClick = event.clickCount == 2
        let wasPlaying = !ITunesHelper.isPlaying()

        if isDoubleClick && wasPlaying {
            let withOption = NSEvent.ModifierFlags(rawValue: event.modifierFlags.intersection(.deviceIndependentFlagsMask).rawValue * 2) == .option

            if !preferences.showPrevButton && withOption {
                iTunes.previousTrack?()
            } else if !preferences.showNextButton {
                iTunes.nextTrack?()
            }
        }

        // Single click
        iTunes.playpause?()
    }

    @objc func onNextClick() {
        if isPlayerLaunching {
            return
        }

        if !iTunes.isRunning {
            return onPlayClick()
        }

        iTunes.nextTrack?()
    }
}
