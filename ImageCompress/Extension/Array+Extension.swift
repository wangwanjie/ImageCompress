//
//  Array+Extension.swift
//  ImageCompress
//
//  Created by VanJay on 2020/3/28.
//  Copyright © 2020 VanJay. All rights reserved.
//

import Foundation

extension Array {
    mutating func removeAtIndexes(indexes: IndexSet) {
        var i: Index? = indexes.last
        while i != nil {
            remove(at: i!)
            i = indexes.integerLessThan(i!)
        }
    }
}
