//
//  String+LanguageItems.swift
//  ViPay
//
//  Created by VanJay on 2019/6/28.
//  Copyright © 2019 VanJay. All rights reserved.
//

import Foundation

func localizedDefault(key: String, value: String? = nil) -> String {
    if let value = value {
        return value.localizedDefault(key: key)
    }
    return "".localizedDefault(key: key)
}

func localizedButton(key: String, value: String? = nil) -> String {
    if let value = value {
        return value.localizedButton(key: key)
    }
    return "".localizedButton(key: key)
}

extension String {
    func localizedDefault(usingTable tableName: String = "Localizable", key: String?, value: String? = nil) -> String {
        let path = Bundle.main.path(forResource: "LocalizableResource", ofType: "bundle")!
        let bundle = Bundle(path: path)
        return localized(usingTable: tableName, in: bundle, key: key, value: value)
    }

    func localizedButton(usingTable tableName: String = "Buttons", key: String?, value: String? = nil) -> String {
        let path = Bundle.main.path(forResource: "LocalizableResource", ofType: "bundle")!
        let bundle = Bundle(path: path)
        return localized(usingTable: tableName, in: bundle, key: key, value: value)
    }
}
