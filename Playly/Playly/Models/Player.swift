//
// Created by Max on 10/1/19.
// Copyright (c) 2019 Max Diachenko. All rights reserved.
//

import Foundation
import AppKit
import ScriptingBridge

class Player {
//     private var musicApp: MusicApplication?
    private var spotifyApp: SpotifyApplication?

    static let shared = Player()
    
    // let library = try! ITLibrary(apiVersion: "1.0")

    var isRunning: Bool {
        spotifyApp!.isRunning
    }

    var isShuffling: Bool {
        spotifyApp!.shuffling ?? false
    }

    var isPlaying: Bool {
        isRunning && spotifyApp!.playerState == .playing
    }

    var isStopped: Bool {
        spotifyApp!.playerState == .stopped
    }

    var trackName: String {
        "\(spotifyApp?.currentTrack?.artist ?? "") – \(spotifyApp?.currentTrack?.name ?? "")"
    }

    private init() {
        spotifyApp = SBApplication(bundleIdentifier: "com.spotify.client")
//         musicApp = SBApplication(bundleIdentifier: "com.apple.Music")
    }

    func getArtwork(completion: @escaping (NSImage?) -> Void) {
        guard let currentTrack = spotifyApp?.currentTrack,
              let artworkUrlString = currentTrack.artworkUrl,
              let artworkURL = URL(string: artworkUrlString) else {
            completion(nil)
            return
        }

        // Perform the request asynchronously
        URLSession.shared.dataTask(with: artworkURL) { data, response, error in
            if let error = error {
                print("Failed to fetch artwork: \(error)")
                completion(nil)
                return
            }

            guard let data = data, let artworkImage = NSImage(data: data) else {
                print("Invalid image data")
                completion(nil)
                return
            }

            // Resize the image to the desired size
            artworkImage.size = NSSize(width: 22, height: 22)

            // Call the completion handler with the image
            completion(artworkImage)
        }.resume()
    }

    func setRelativePosition(_ offsetTime: Double) {
        spotifyApp?.setPlayerPosition?((spotifyApp?.playerPosition! ?? 0) + offsetTime)
    }

    func setShuffling(state: Bool) {
        spotifyApp?.setShuffling?(state)
    }

    func backTrack() {
        // TODO back track
        spotifyApp?.previousTrack?()
    }

    func prevTrack() {
        spotifyApp?.previousTrack?()
    }

    func nextTrack() {
        spotifyApp?.nextTrack?()
    }

    func play() {
        spotifyApp?.play?()
    }

    func pause() {
        spotifyApp?.pause?()
    }

    func playpause() {
        spotifyApp?.playpause?()
    }

//    func getPlaylists() -> [ITLibPlaylist] {
//        library.allPlaylists
//    }

    func activate() {
        spotifyApp?.activate()
    }

    func quit() {
        // TODO
      // spotifyApp.
    }
}
