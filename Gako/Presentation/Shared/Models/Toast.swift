//
//  Toast.swift
//  Gako
//
//  Created by Akmal Hakim on 01/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A model for the toast
//  Usage: Use this model to display a toast
//

import Foundation

struct Toast: Equatable {
    var style: UIConstants.ToastNotification.Style
    var message: String
    var duration: Double = 2
    var width: Double = .infinity
}
