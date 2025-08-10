//
//  TranscriberProtocol.swift
//  AIMeetingAssistant
//
//  Created by Shruti Suryawanshi on 8/10/25.
//

import Foundation

protocol TranscriberProtocol: AnyObject {
    /// Start real-time streaming transcription (optional). Accepts audio buffer chunks if supported.
    func startRealtimeTranscription(onPartial: @escaping (TranscriptSegment) -> Void,
                                    onComplete: @escaping ([TranscriptSegment]) -> Void) -> Void

    /// Transcribe a saved audio file URL (post-meeting)
    func transcribeFile(url: URL, completion: @escaping (Result<[TranscriptSegment], Error>) -> Void)
}
