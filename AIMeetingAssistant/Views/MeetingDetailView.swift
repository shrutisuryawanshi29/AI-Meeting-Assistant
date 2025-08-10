//
//  MeetingDetailView.swift
//  AIMeetingAssistant
//
//  Created by Shruti Suryawanshi on 8/10/25.
//

import SwiftUI
import AVFoundation

struct MeetingDetailView: View {
    @EnvironmentObject var store: MeetingStore
    @State var meeting: Meeting
    @State private var player: AVAudioPlayer?
    @State private var selectedSegment: TranscriptSegment?
    @State private var newSpeakerName: String = ""

    var body: some View {
        VStack {
            if let file = meeting.audioFileName {
                Button("Play audio") { playAudio(fileName: file) }
            }
            List {
                Section(header: Text("Transcript")) {
                    ForEach(meeting.transcript) { seg in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(seg.speaker ?? "Unknown").font(.caption).foregroundColor(.secondary)
                                Spacer()
                                Text(String(format: "%.1fs", seg.startTime)).font(.caption2)
                            }
                            Text(seg.text).padding(.vertical, 2)
                            HStack {
                                Button("Assign Speaker") { selectedSegment = seg; newSpeakerName = seg.speaker ?? "" }
                                Spacer()
                            }
                        }
                    }
                }

                Section(header: Text("Action Items")) {
                    ForEach(meeting.actionItems, id: \ .self) { item in
                        Text(item)
                    }
                }
            }
        }
        .sheet(item: $selectedSegment) { seg in
            VStack { Text("Assign speaker")
                TextField("Speaker name", text: $newSpeakerName).padding()
                Button("Save") {
                    assignSpeaker(seg: seg, name: newSpeakerName)
                }
            }.padding()
        }
        .navigationTitle(meeting.title)
    }

    func playAudio(fileName: String) {
        let url = FileHelpers.documentsDirectory.appendingPathComponent(fileName)
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Play error: \(error)")
        }
    }

    func assignSpeaker(seg: TranscriptSegment, name: String) {
        if let idx = meeting.transcript.firstIndex(where: { $0.id == seg.id }) {
            meeting.transcript[idx].speaker = name
            store.update(meeting)
        }
        selectedSegment = nil
    }
}
