//
//  DateValidator.swift
//  Gako
//
//  Created by Kevin Fairuz on 07/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Date validator for users cannot select the next day
//  Usage: Use this validator for manage date picker
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
