//
// Created by Max on 10/1/19.
// Copyright (c) 2019 Max Diachenko. All rights reserved.
//

import Cocoa
import Foundation
import ScriptingBridge

extension Notification.Name {
  static let spotifyPlayerInfo = Notification.Name("com.spotify.client.PlaybackStateChanged")
}

struct Utils {
  static func onStateChange(_ sender: Any, action: Selector) {
    DistributedNotificationCenter.default().addObserver(sender, selector: action, name: .spotifyPlayerInfo, object: nil)
  }

  static func launchAndPlay() {
    guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.spotify.client") else {
      return
    }

    let path = "/bin"
    let configuration = NSWorkspace.OpenConfiguration()
    configuration.arguments = [path]
    NSWorkspace.shared.openApplication(at: url, configuration: configuration) { app, _ in
      if app != nil {
        Player.shared.play()
      }
    }
  }
}
