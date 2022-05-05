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

    showControls(true, rerender: true)

    let nextTrackLongPressRecognizer = NSPressGestureRecognizer(target: self, action: #selector(self.fastForward(_:)))
    nextTrackLongPressRecognizer.minimumPressDuration = 0.5
    statusItemNext.button?.addGestureRecognizer(nextTrackLongPressRecognizer)

    changePlayIcon()
    updateTooltips()
  }

  @objc func rewind(_ event: NSPressGestureRecognizer) {
    // if !Player.shared.isPlaying || needActivation {
    if !Player.shared.isPlaying {
      return
    }

    if event.state == .began {
      // Haptic feedback
      timer.schedule(deadline: .now(), repeating: 0.3)
      timer.setEventHandler {
        Player.shared.setRelativePosition(-3)
        self.haptic.perform(.generic, performanceTime: .default)
      }
      timer.resume()
    } else if event.state == .ended {
      timer.suspend()
    }
  }

  @objc func fastForward(_ event: NSPressGestureRecognizer) {
    // if !Player.shared.isPlaying || needActivation {
    if !Player.shared.isPlaying {
      return
    }

    if event.state == .began {
      // Haptic feedback
      timer.schedule(deadline: .now(), repeating: 0.1)
      timer.setEventHandler {
        Player.shared.setRelativePosition(3)
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

    if !Player.shared.isRunning {
      return onPlayClick()
    }

    Player.shared.prevTrack()
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

    // Launch player if not running
    if !Player.shared.isRunning {
      isPlayerLaunching = true

      // Loading icon
      if let clockImage = NSImage(named: NSImage.touchBarHistoryTemplateName) {
        clockImage.size = NSSize(width: 15, height: 25)
        statusItemPlay.button?.image = clockImage
        statusItemPlay.button?.appearsDisabled = true
      }

      return Utils.launchAndPlay()
    }

    // Double click
    let isDoubleClick = event.clickCount == 2
    let wasPlaying = !Player.shared.isPlaying

    if isDoubleClick && (!preferences.showNextButton || !preferences.showPrevButton) && wasPlaying {
      let withOption = event.modifierFlags.contains(.option)

      if !preferences.showPrevButton && withOption {
        Player.shared.prevTrack()
        Player.shared.play()
        return
      } else if !preferences.showNextButton {
        Player.shared.nextTrack()
        return
      }
    }

    // Single click
    Player.shared.playpause()
  }

  @objc func onNextClick() {
    if isPlayerLaunching {
      return
    }

    if !Player.shared.isRunning {
      return onPlayClick()
    }

    Player.shared.nextTrack()
  }

}
