//
//  Meeting.swift
//  AIMeetingAssistant
//
//  Created by Shruti Suryawanshi on 8/10/25.
//

import Foundation

struct TranscriptSegment: Codable, Identifiable {
    var id = UUID().uuidString
    var speaker: String? // optional label
    var text: String
    var startTime: TimeInterval // seconds
    var duration: TimeInterval // seconds
}

struct Meeting: Codable, Identifiable {
    var id: String = UUID().uuidString
    var title: String
    var createdAt: Date = Date()
    var audioFileName: String? // local filename in Documents
    var transcript: [TranscriptSegment] = []
    var actionItems: [String] = []
}
