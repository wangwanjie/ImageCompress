//
//  AlertHelper.swift
//  ImageCompress
//
//  Created by VanJay on 2020/3/26.
//  Copyright © 2020 VanJay. All rights reserved.
//

import Foundation

func showAlert(style _: NSAlert.Style, message: String, informativeText: String) {
    let alert = HDAlert(title: message, message: informativeText, style: .warning)
    alert?.addCommonButton(withTitle: "确定", handler: { _ in

    })
    alert?.show(NSApplication.shared.keyWindow)
}
