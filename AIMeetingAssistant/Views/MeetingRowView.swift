//
//  MeetingRowView.swift
//  AIMeetingAssistant
//
//  Created by Shruti Suryawanshi on 8/10/25.
//

import SwiftUI

struct MeetingRowView: View {
    var meeting: Meeting
    var body: some View {
        VStack(alignment: .leading) {
            Text(meeting.title).font(.headline)
            HStack {
                Text(meeting.createdAt, style: .date).font(.subheadline)
                Spacer()
                Text("Segments: \(meeting.transcript.count)").font(.subheadline)
            }
        }
    }
}
