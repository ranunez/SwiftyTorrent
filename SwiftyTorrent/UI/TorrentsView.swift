//
//  TorrentsView.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/1/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import SwiftUI
import Combine
import TorrentKit

struct TorrentsView: View {
    
    @ObservedObject var model: TorrentsViewModel

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Downloads")) {
                    ForEach(model.torrents, id: \.infoHash) { torrent in
                        NavigationLink(destination: FilesView(model: torrent.directory)) {
                            TorrentRow(model: torrent)
                        }.contextMenu {
                            Button(role: .destructive) { model.remove(torrent) } label: {
                                Label("Remove torrent", systemImage: "trash")
                            }
                            Button(role: .destructive) { model.remove(torrent, deleteFiles: true) } label: {
                                Label("Remove all data", systemImage: "trash")
                            }
                        }.disabled(!torrent.hasMetadata)
                    }
                }
            }
            .refreshable { model.reloadData() }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Torrents")
        }
        .alert(isPresented: model.isPresentingAlert) { () -> Alert in
            Alert(error: model.activeError!)
        }
    }

}

extension Alert {
    init(error: Error) {
        self = Alert(
            title: Text("Error"),
            message: Text(error.localizedDescription),
            dismissButton: .default(Text("OK"))
        )
    }
}
