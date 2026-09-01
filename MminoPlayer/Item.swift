//
//  Item.swift
//  MminoPlayer
//
//  Created by Leboreng Mathope on 2026/09/01.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
