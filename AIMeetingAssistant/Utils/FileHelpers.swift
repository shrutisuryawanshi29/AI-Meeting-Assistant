//
//  FileHelpers.swift
//  AIMeetingAssistant
//
//  Created by Shruti Suryawanshi on 8/10/25.
//

import Foundation

enum FileHelpers {
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
