//
// Created by Max on 10/1/19.
// Copyright (c) 2019 Max Diachenko. All rights reserved.
//

import Foundation
import AppKit
import ScriptingBridge
import iTunesLibrary

class Player {
    // private var musicApp: MusicApplication?
    private var spotifyApp: SpotifyApplication?

    static let shared = Player()
    
    let library = try! ITLibrary(apiVersion: "1.0")

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
    }

    func getArtwork() -> NSImage? {
        let currentTrack: SpotifyTrack = (spotifyApp?.currentTrack)!
        // let currentTrackId: String = currentTrack.id?() as! String
        let artworkURL = URL(string: currentTrack.artworkUrl!)!
        let artworkImage = try! NSImage(data: Data(contentsOf: artworkURL))
        artworkImage!.size = NSSize(width: 22, height: 22)

        return artworkImage
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

    func playPlaylist(_ name: String) {
        NSAppleScript(source: "tell application \"Spotify\" to play playlist \"\(name)\"")?.executeAndReturnError(nil)
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
