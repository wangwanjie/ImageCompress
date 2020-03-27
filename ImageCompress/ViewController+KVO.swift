//
//  ViewController+KVO.swift
//  ImageCompress
//
//  Created by VanJay on 2020/3/26.
//  Copyright © 2020 VanJay. All rights reserved.
//

import Foundation

extension ViewController {
    // MARK: - KVO

    func addDataSourceObserver() {
        addObserver(self, forKeyPath: "dataSource", options: [.old, .new], context: nil)
    }

    func removeDataSourceObserver() {
        removeObserver(self, forKeyPath: "dataSource")
    }

    override func observeValue(forKeyPath keyPath: String?, of _: Any?, change: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, keyPath == "dataSource" {
            let newValue = change?[NSKeyValueChangeKey.newKey] as? [URL]

            if newValue?.count ?? 0 > 0 {
                selectButton.title = "继续添加"
            } else {
                selectButton.title = "选择图片(支持多选)"
            }
        }
    }
}
