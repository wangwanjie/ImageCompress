//
//  ViewController+DragDrop.swift
//  ImageCompress
//
//  Created by VanJay on 2020/3/26.
//  Copyright © 2020 VanJay. All rights reserved.
//

import Foundation

extension ViewController: WJDragDropViewDelegate {
    // 单文件
    func dragDropView(_: WJDragDropView, droppedFileWithURL URL: URL) {
        handleURLs(urls: [URL])
    }

    // 多文件
    func dragDropView(_: WJDragDropView, droppedFilesWithURLs URLs: [URL]) {
        handleURLs(urls: URLs)
    }
}
