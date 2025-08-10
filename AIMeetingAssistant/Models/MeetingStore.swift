//
//  MeetingStore.swift
//  AIMeetingAssistant
//
//  Created by Shruti Suryawanshi on 8/9/25.
//

import Foundation
import Combine

final class MeetingStore: ObservableObject {
    @Published private(set) var meetings: [Meeting] = []
    private let fileURL: URL

    init(filename: String = "meetings.json") {
        let doc = FileHelpers.documentsDirectory
        fileURL = doc.appendingPathComponent(filename)
        load()
    }

    func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([Meeting].self, from: data)
            DispatchQueue.main.async { self.meetings = decoded }
        } catch {
            // file not found or decode error -> start empty
            DispatchQueue.main.async { self.meetings = [] }
        }
    }

    func save() {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(self.meetings)
                try data.write(to: self.fileURL, options: [.atomicWrite])
            } catch {
                print("Failed to save meetings: \(error)")
            }
        }
    }

    func add(_ meeting: Meeting) {
        meetings.insert(meeting, at: 0)
        save()
    }

    func update(_ meeting: Meeting) {
        if let idx = meetings.firstIndex(where: { $0.id == meeting.id }) {
            meetings[idx] = meeting
            save()
        }
    }

    func remove(atOffsets offsets: IndexSet) {
        meetings.remove(atOffsets: offsets)
        save()
    }
}
