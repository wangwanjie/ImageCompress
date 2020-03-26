//
//  AlertHelper.swift
//  ImageCompress
//
//  Created by VanJay on 2020/3/26.
//  Copyright © 2020 VanJay. All rights reserved.
//

import Foundation

func showAlert(style: NSAlert.Style, message: String, informativeText: String) {
    let alert = NSAlert()
    alert.alertStyle = style
    alert.messageText = message
    alert.informativeText = informativeText
    alert.runModal()
}
