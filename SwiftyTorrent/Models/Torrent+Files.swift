//
//  Torrent.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/15/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import TorrentKit

extension Torrent {
    
    private static var filesCache = [Data: [FileEntry]]()
    private static var dirsCache = [Data: Directory]()
    
    private var fileEntries: [FileEntry] {
        if Torrent.filesCache[infoHash] == nil {
            Torrent.filesCache[infoHash] = TorrentManager.shared().filesForTorrent(withHash: infoHash)
        }
        return Torrent.filesCache[infoHash]!
    }

    var directory: Directory {
        if Torrent.dirsCache[infoHash] == nil {
            let dir = Directory.directory(from: fileEntries)
           Torrent.dirsCache[infoHash] = dir
        }
        return Torrent.dirsCache[infoHash]!
    }
    
    var title: String {
        return name
    }
    
    var statusDetails: String {
        let progressString = String(format: "%0.2f %%", progress * 100)
        return "\(state.symbol) \(state), \(progressString), seeds: \(numberOfSeeds), peers: \(numberOfPeers)"
    }
    
    var connectionDetails: String {
        let downloadRateString = ByteCountFormatter.string(fromByteCount: Int64(downloadRate), countStyle: .binary)
        let uploadRateString = ByteCountFormatter.string(fromByteCount: Int64(uploadRate), countStyle: .binary)
        return "↓ \(downloadRateString), ↑ \(uploadRateString)"
    }

}
