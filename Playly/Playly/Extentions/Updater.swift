//
// Created by Max on 10/6/19.
// Copyright (c) 2019 Max Diachenko. All rights reserved.
//

import Foundation

extension AppDelegate {
    var currentVersion: Double {
        get {
            Double(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String) as! Double
        }
    }

    func checkForUpdates() {
        let url = URL(string: "https://playly.app/versions/latest.txt")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil || (response as! HTTPURLResponse).statusCode == 404 {
                return
            }

            let data = String(bytes: data!, encoding: .utf8) as! String
            let version = Double(data.components(separatedBy: .newlines)[0]) as! Double

            if version + 1 > self.currentVersion {
                self.UpdaterWindowController?.showWindow(self)
            }
        }
        task.resume()
    }
}
