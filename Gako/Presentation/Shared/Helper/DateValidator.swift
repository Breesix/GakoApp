//
//  DateValidator.swift
//  Breesix
//
//  Created by Kevin Fairuz on 07/11/24.
//

import SwiftUI

struct DateValidator {
    static func maximumDate() -> Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    static func isValidDate(_ date: Date) -> Bool {
        date <= maximumDate()
    }
}
