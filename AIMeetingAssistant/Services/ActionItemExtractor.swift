//
//  ActionItemExtractor.swift
//  AIMeetingAssistant
//
//  Created by Shruti Suryawanshi on 8/10/25.
//

import Foundation
import NaturalLanguage

struct ActionItem {
    let text: String
    let detectedDate: Date?
}

final class ActionItemExtractor {
    static func extractActionItems(from transcriptSegments: [TranscriptSegment]) -> [String] {
        var results: [String] = []
        // Combine segments into sentences with timestamps
        let fullText = transcriptSegments.map { $0.text }.joined(separator: " ")

        // Sentence tokenizer
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = fullText
        tokenizer.enumerateTokens(in: fullText.startIndex..<fullText.endIndex) { range, _ in
            let sentence = String(fullText[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            if isLikelyActionItem(sentence) {
                results.append(sentence)
            }
            return true
        }
        return results
    }

    private static func isLikelyActionItem(_ sentence: String) -> Bool {
        // Heuristics: imperative mood (starts with verb), presence of keywords, or explicit requests
        let lower = sentence.lowercased()
        let keywords = ["please", "assign", "action", "todo", "we should", "can you", "let's", "let us", "i will", "we will", "you will", "deadline", "due"]
        for k in keywords where lower.contains(k) { return true }

        // Check starting token with NLTagger for part-of-speech
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = sentence
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        var foundVerbFirst = false
        tagger.enumerateTags(in: sentence.startIndex..<sentence.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            if let tag = tag {
                if tag == .verb {
                    foundVerbFirst = true
                }
            }
            // stop after first token
            return false
        }
        if foundVerbFirst { return true }
        return false
    }
}
