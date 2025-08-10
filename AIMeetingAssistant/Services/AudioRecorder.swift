//
//  AudioRecorder.swift
//  AIMeetingAssistant
//
//  Created by Shruti Suryawanshi on 8/10/25.
//

import Foundation
import AVFoundation

final class AudioRecorder: NSObject, ObservableObject {
    private let engine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    private var audioURL: URL?

    func startRecording(filename: String) throws -> URL {
        let doc = FileHelpers.documentsDirectory
        let url = doc.appendingPathComponent(filename)
        audioURL = url

        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)

        // Prepare AVAudioFile
        audioFile = try AVAudioFile(forWriting: url, settings: format.settings)

        input.installTap(onBus: 0, bufferSize: 4096, format: format) { [weak self] (buffer, time) in
            guard let strong = self else { return }
            do {
                try strong.audioFile?.write(from: buffer)
            } catch {
                print("Write error: \(error)")
            }
        }

        engine.prepare()
        try engine.start()
        return url
    }

    func stopRecording() {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        audioFile = nil
    }
}
