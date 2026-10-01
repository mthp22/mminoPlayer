//
//  RepeatMode.swift
//  MminoPlayer
//
//  Repeat mode enumeration for playback

import Foundation

enum RepeatMode: Int, CaseIterable {
    case off = 0
    case one = 1
    case all = 2
    
    var icon: String {
        switch self {
        case .off:
            return "repeat"
        case .one:
            return "repeat.1"
        case .all:
            return "repeat"
        }
    }
    
    var description: String {
        switch self {
        case .off:
            return "Repeat Off"
        case .one:
            return "Repeat One"
        case .all:
            return "Repeat All"
        }
    }
    
    mutating func toggle() {
        switch self {
        case .off:
            self = .one
        case .one:
            self = .all
        case .all:
            self = .off
        }
    }
    
    func next() -> RepeatMode {
        var mode = self
        mode.toggle()
        return mode
    }
}
