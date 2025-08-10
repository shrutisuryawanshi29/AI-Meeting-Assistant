//
//  CalendarManager.swift
//  AIMeetingAssistant
//
//  Created by Shruti Suryawanshi on 8/10/25.
//

import Foundation
import EventKit

final class CalendarManager {
    let store = EKEventStore()

    func requestAccess(completion: @escaping (Bool) -> Void) {
        store.requestAccess(to: .reminder) { granted, error in
            completion(granted)
        }
    }

    func createReminder(title: String, notes: String?, due: Date?) throws {
        let reminder = EKReminder(eventStore: store)
        reminder.title = title
        reminder.notes = notes
        if let due = due {
            reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: due)
        }
        reminder.calendar = store.defaultCalendarForNewReminders()
        try store.save(reminder, commit: true)
    }
}
