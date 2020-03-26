//
//  ViewController+Event.swift
//  ImageCompress
//
//  Created by VanJay on 2020/3/26.
//  Copyright © 2020 VanJay. All rights reserved.
//

import Foundation

extension ViewController {
    func handleURLs(urls: [URL]) {
        var finalList = [URL]()
        for url in urls {
            let isDir = HDFileUtil.isDirFilePath(url.path)
            if isDir {
                let allFileInDirAndSubDir = HDFileUtil.getFileListRecursively(url.path)
                for subFilePath in allFileInDirAndSubDir {
                    let subFileURL = URL(string: (subFilePath as NSString).hd_URLEncoded())
                    let pathExtension = subFileURL?.pathExtension
                    if let pathExtension = pathExtension {
                        if supportTypes.contains(pathExtension) {
                            finalList.append(subFileURL!)
                        }
                    }
                }
            } else {
                let pathExtension = url.pathExtension

                if supportTypes.contains(pathExtension) {
                    finalList.append(URL(string: (url.path as NSString).hd_URLEncoded())!)
                }
            }
        }
        dataSource.append(contentsOf: finalList)
        // 去重
        var dictM = [URL: URL]()
        for url in dataSource {
            dictM[url] = url
        }
        dataSource = Array(dictM.values)
        tableView.reloadData()
    }

    @objc func selectButtonClickedHandler() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = supportTypes
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true

        guard let window = view.window else {
            return
        }

        panel.beginSheetModal(for: window) { result in
            if result == .OK {
                let urls = panel.urls
                self.handleURLs(urls: urls)
            }
        }
    }

    @objc func exportButtonClickedHandler() {
        guard dataSource.count > 0 else {
            showAlert(style: .warning, message: "还未选择图片", informativeText: "请选择图片")
            return
        }
        let panel = NSSavePanel()
        if let path = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, false).first {
            panel.directoryURL = URL(fileURLWithPath: path)
        }
        panel.nameFieldStringValue = String("图片名.\(dataSource.first!.pathExtension)")
        panel.message = "请选择保存的路径"
        panel.isExtensionHidden = false
        panel.canCreateDirectories = true

        guard let window = view.window else {
            return
        }

        panel.beginSheetModal(for: window) { result in
            if result == .OK {
                panel.close()

                DispatchQueue.main.async {
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                }

                var index = 0
                let limitedSize: CGFloat = CGFloat(Float(self.textField.stringValue) ?? 500)

                DispatchQueue.global().async {
                    var image: NSImage?
                    for url in self.dataSource {
                        image = NSImage(byReferencingFile: url.path)
                        if let image = image {
                            DispatchQueue.main.async {
                                HDImageCompressTool.compressedImage(image, imageKB: limitedSize) { imageData in
                                    let fileName = url.lastPathComponent
                                    let saveDirPath = panel.url?.deletingLastPathComponent().relativePath
                                    if let saveDirPath = saveDirPath {
                                        let path = String("\(saveDirPath)/\(fileName)")
                                        try! imageData.write(to: URL(fileURLWithPath: path))
                                        index += 1
                                        if index >= self.dataSource.count {
                                            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)

                                            if let directoryURL = panel.directoryURL {
                                                NSWorkspace.shared.open(directoryURL)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    @objc func clearButtonClickedHandler() {
        dataSource.removeAll()
        tableView.reloadData()
    }

    @objc func deleteButtonClickedHandler() {
        guard tableView.numberOfSelectedRows > 0 else {
            showAlert(style: .warning, message: "无选中项", informativeText: "请先选择图片")
            return
        }
        var results = [URL]()
        results.append(contentsOf: dataSource)
        let selectedIndexSet = tableView.selectedRowIndexes

        for i in 0 ..< selectedIndexSet.count {
            if i < results.count {
                let url = results[i]
                print("删除: \(url.path)")
            }

            dataSource.remove(at: i)
        }
        tableView.reloadData()
    }
}
