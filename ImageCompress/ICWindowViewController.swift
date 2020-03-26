//
//  ICWindowViewController.swift
//  ImageCompress
//
//  Created by VanJay on 2020/3/26.
//  Copyright © 2020 VanJay. All rights reserved.
//

import Foundation

class ICWindowVewController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()

        contentViewController = ViewController()

        shouldCascadeWindows = false
        windowFrameAutosaveName = "ImageCompress"
    }
}
