//
//  ContentView.swift
//  AIMeetingAssistant
//
//  Created by Shruti Suryawanshi on 8/9/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: MeetingStore
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var isRecording = false
    @State private var currentMeeting: Meeting?
    @State private var statusMessage = ""

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Button(action: { startNewMeeting() }) {
                        Label("New Meeting", systemImage: "plus")
                    }
                    Spacer()
                    Button(action: { toggleRecording() }) {
                        if isRecording { Label("Stop", systemImage: "stop.circle") }
                        else { Label("Record", systemImage: "mic.circle") }
                    }
                }.padding()

                Text(statusMessage).font(.caption).padding(.horizontal)

                List {
                    ForEach(store.meetings) { meeting in
                        NavigationLink(destination: MeetingDetailView(meeting: meeting)) {
                            MeetingRowView(meeting: meeting)
                        }
                    }.onDelete(perform: store.remove)
                }
            }
            .navigationTitle("Meetings")
        }
    }

    func startNewMeeting() {
        let meeting = Meeting(title: "Meeting \(Date())")
        store.add(meeting)
        currentMeeting = meeting
    }

    func toggleRecording() {
        guard let meeting = store.meetings.first else { statusMessage = "No meeting created"; return }
        if !isRecording {
            // Start
            let filename = "meeting_\(meeting.id).caf"
            do {
                let url = try audioRecorder.startRecording(filename: filename)
                statusMessage = "Recording to \(url.lastPathComponent)"
                isRecording = true
                // attach filename to meeting and update store
                var m = meeting
                m.audioFileName = url.lastPathComponent
                store.update(m)
            } catch {
                statusMessage = "Failed to start recording: \(error)"
            }
        } else {
            audioRecorder.stopRecording()
            statusMessage = "Stopped recording"
            isRecording = false
            // kick off transcription in background
            guard let meeting = store.meetings.first, let fileName = meeting.audioFileName else { return }
            let url = FileHelpers.documentsDirectory.appendingPathComponent(fileName)
            SpeechTranscriber.requestPermissions { granted in
                if !granted {
                    statusMessage = "Speech permission not granted"
                    return
                }
                let transcriber = SpeechTranscriber()
                transcriber.transcribeFile(url: url) { result in
                    switch result {
                    case .success(let segments):
                        var m = meeting
                        m.transcript = segments
                        m.actionItems = ActionItemExtractor.extractActionItems(from: segments)
                        store.update(m)
                    case .failure(let err):
                        statusMessage = "Transcription failed: \(err)"
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
