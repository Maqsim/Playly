//
// Created by Max on 10/6/19.
// Copyright (c) 2019 Max Diachenko. All rights reserved.
//

import Foundation

class UpdateManager {
    static let shared = UpdateManager()
    let currentVersion = Double(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String) as! Double

    private init() {}

    func checkForUpdates(_ callback: @escaping (Bool, Double?) -> Void) {
        let url = URL(string: "https://playly.app/versions/latest.txt")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil || (response as! HTTPURLResponse).statusCode == 404 {
                return callback(false, nil)
            }

            let data = String(bytes: data!, encoding: .utf8) as! String
            let version = Double(data.components(separatedBy: .newlines)[0]) as! Double

            callback(version > self.currentVersion, version)

        }
        task.resume()
    }
}
