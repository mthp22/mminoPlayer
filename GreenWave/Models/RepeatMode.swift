//
//  RepeatMode.swift
//  GreenWave
//
//  Repeat mode enumeration for the audio player
//

import Foundation

enum RepeatMode: Int, CaseIterable {
    case off = 0
    case one = 1
    case all = 2
    
    var icon: String {
        switch self {
        case .off: return "repeat"
        case .one: return "repeat.1"
        case .all: return "repeat"
        }
    }
    
    var next: RepeatMode {
        switch self {
        case .off: return .one
        case .one: return .all
        case .all: return .off
        }
    }
    
    var description: String {
        switch self {
        case .off: return "Repeat Off"
        case .one: return "Repeat One"
        case .all: return "Repeat All"
        }
    }
}
