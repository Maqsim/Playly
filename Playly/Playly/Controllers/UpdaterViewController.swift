//
//  UpdaterViewController.swift
//  Playly
//
//  Created by Max on 10/6/19.
//  Copyright © 2019 Max Diachenko. All rights reserved.
//

import Cocoa

class UpdaterViewController: NSViewController {
    @IBOutlet var checkLabel: NSTextField!
    @IBOutlet var versionLabel: NSTextField!
    @IBOutlet var loader: NSProgressIndicator!
    @IBOutlet var downloadButton: NSButton!

    let updateManager = UpdateManager.shared
    var latestAvailableVersion: Double?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        let loadingStartedAt = Date()
        loader.startAnimation(self)
        loader.isHidden = false
        versionLabel.isHidden = true
        downloadButton.isHidden = true
        checkLabel.stringValue = "Checking for updates..."

        updateManager.checkForUpdates { hasNewVersion, version in
            if abs(loadingStartedAt.timeIntervalSinceNow) > 1 {
                if hasNewVersion {
                    self.newUpdateAvailable(version!)
                } else {
                    self.allIsUpToDate()
                }

                self.loader.isHidden = true
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if hasNewVersion {
                        self.newUpdateAvailable(version!)
                    } else {
                        self.allIsUpToDate()
                    }

                    self.loader.isHidden = true
                }
            }
        }
    }

    func newUpdateAvailable(_ version: Double) {
        latestAvailableVersion = version
        checkLabel.stringValue = "New version is available!"
        downloadButton.isHidden = false
        versionLabel.isHidden = false
        versionLabel.stringValue = "Version \(version)"
        downloadButton.action = #selector(openBrowserToDownload)
    }

    func allIsUpToDate() {
        checkLabel.stringValue = "You have the latest version of Playly."
    }

    @objc func openBrowserToDownload() {
        // TODO
        NSWorkspace.shared.open(URL(string: "https://playly.app?download_new_version=true")!)
        self.view.window?.close()
    }
}
