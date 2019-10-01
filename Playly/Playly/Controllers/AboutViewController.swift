//
//  AboutViewController.swift
//  Playly
//
//  Created by Max on 10/1/19.
//  Copyright © 2019 Max Diachenko. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {
    @IBAction func website(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "http://maxdiachenko.com")!)
    }

    @IBAction func onReportProblemClick(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "https://github.com/Maqsim/Playly/issues/new")!)
    }
}
