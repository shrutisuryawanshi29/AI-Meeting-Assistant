//
//  SpeechTranscriber.swift
//  AIMeetingAssistant
//
//  Created by Shruti Suryawanshi on 8/10/25.
//

import Foundation
import Speech

/// Simple wrapper around SFSpeechRecognizer — streams or file transcription.
final class SpeechTranscriber: NSObject, TranscriberProtocol {
    private let speechRecognizer = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    override init() {
        super.init()
    }

    static func requestPermissions(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            // handle if needed
        }
    }

    func startRealtimeTranscription(onPartial: @escaping (TranscriptSegment) -> Void,
                                    onComplete: @escaping ([TranscriptSegment]) -> Void) {
        // This demo uses real-time streaming with SFSpeechRecognizer (best-effort). You may prefer post-meeting file transcription.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true

        let input = audioEngine.inputNode
        let recordingFormat = input.outputFormat(forBus: 0)
        input.installTap(onBus: 0, bufferSize: 4096, format: recordingFormat) { [weak self] (buffer, when) in
            self?.recognitionRequest?.append(buffer)
        }

        try? AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!, resultHandler: { result, error in
            guard error == nil else {
                print("Recognition error: \(String(describing: error))")
                return
            }
            if let r = result {
                // convert transcription segments into TranscriptSegment(s)
                let utteranceText = r.bestTranscription.formattedString
                // Map each segment in r.bestTranscription.segments to TranscriptSegment
                let segments = r.bestTranscription.segments.map { seg -> TranscriptSegment in
                    TranscriptSegment(id: UUID().uuidString,
                                      speaker: nil,
                                      text: seg.substring,
                                      startTime: seg.timestamp,
                                      duration: seg.duration)
                }
                // Send last segment as partial update
                if let last = segments.last {
                    onPartial(last)
                }
                if r.isFinal {
                    onComplete(segments)
                }
            }
        })

        audioEngine.prepare()
        do { try audioEngine.start() } catch { print("audio engine start failed") }
    }

    func transcribeFile(url: URL, completion: @escaping (Result<[TranscriptSegment], Error>) -> Void) {
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        speechRecognizer?.recognitionTask(with: request) { result, error in
            if let err = error {
                completion(.failure(err))
                return
            }
            if let r = result, r.isFinal {
                let segments = r.bestTranscription.segments.map { seg in
                    TranscriptSegment(id: UUID().uuidString, speaker: nil, text: seg.substring, startTime: seg.timestamp, duration: seg.duration)
                }
                completion(.success(segments))
            }
        }
    }
}
