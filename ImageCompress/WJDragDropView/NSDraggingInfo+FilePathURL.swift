//
//  NSDraggingInfo+FilePathURL.swift
//  ImageCompress
//
//  Created by VanJay on 2020/3/26.
//  Copyright © 2020 VanJay. All rights reserved.
//

import AppKit
import Foundation

extension NSDraggingInfo {
    var filePathURLs: [URL] {
        var filenames: [String]?
        var urls: [URL] = []

        if #available(OSX 10.13, *) {
            filenames = draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String]
        } else {
            // Fallback on earlier versions
            filenames = draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String]
        }

        if let filenames = filenames {
            for filename in filenames {
                urls.append(URL(fileURLWithPath: filename))
            }
            return urls
        }
        return []
    }
}
