//
//  File.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/17/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import Foundation
import TorrentKit

protocol FileProtocol: FileRowModel {
    var name: String { get }
}

extension FileProtocol {
    var title: String { name }
}

class File: NSObject, FileProtocol {
    let name: String
    let path: String
    var sizeDetails: String?
    
    init(name: String, path: String, size: UInt64) {
        self.name = name
        self.path = path
        self.sizeDetails = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
    
    override var description: String {
        return name //+ " (\(path))"
    }
}

extension File: Identifiable {
    
    public var id: String { path }

}

class Directory: FileProtocol, CustomStringConvertible {
    
    let name: String
    let path: String
    var sizeDetails: String?

    var files: [FileProtocol]
    
    var allSubDirectories: [Directory] {
        //swiftlint:disable:next force_cast
        return files.filter({ type(of: $0) == Directory.self }) as! [Directory]
    }
    
    var allFiles: [File] {
        //swiftlint:disable:next force_cast
        return files.filter({ type(of: $0) == File.self }) as! [File]
    }
    
    init(name: String, path: String, files: [FileProtocol]? = nil) {
        self.name = name
        self.path = path
        self.files = files ?? []
    }
    
    var description: String {
        return name
    }
    
    class func directory(from fileEntries: [FileEntry]) -> Directory {
        let rootDir = Directory(name: "/", path: "")
        for fileEntry in fileEntries {
            var lastDir = rootDir
            let filePath = fileEntry.path
            let components = filePath.components(separatedBy: "/")
            for (idx, component) in components.enumerated() {
                let isLast = (idx == components.count - 1)
                let path = lastDir.path + "/" + component
                if isLast {
                    let file = File(name: component, path: path, size: fileEntry.size)
                    lastDir.files.append(file)
                } else {
                    var dir: Directory! = lastDir.files.first(where: { $0.name == component }) as? Directory
                    if dir == nil {
                        dir = Directory(name: component, path: path)
                        lastDir.files.append(dir)
                    }
                    lastDir = dir
                }
            }
        }
        return rootDir
    }
    
}
