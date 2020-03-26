//
//  AppDelegate.swift
//  ImageCompress
//
//  Created by VanJay on 2020/3/26.
//  Copyright © 2020 VanJay. All rights reserved.
//

import Cocoa
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var helpMenu: NSMenuItem!
//    @IBOutlet weak var updaterMenuItem: NSMenuItem!
    func applicationDidFinishLaunching(_: Notification) {
        helpMenu.action = #selector(showHelp)
        helpMenu.target = self

        SUUpdater.shared()?.delegate = self
        SUUpdater.shared()?.sendsSystemProfile = true
        SUUpdater.shared()?.checkForUpdatesInBackground()
//        updaterMenuItem.action = #selector(checkNewVersion)
//        updaterMenuItem.target = self
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }

    @objc func showHelp() {
        NSWorkspace.shared.open(URL(string: "https://github.com/wangwanjie/ImageCompress")!)
    }

    @objc func checkNewVersion() {}
}

extension AppDelegate: SUUpdaterDelegate {}
