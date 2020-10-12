//
//  DateExtension.swift
//  Continuum
//
//  Created by Alex Kennedy on 10/11/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import Foundation

extension Date {
    func stringWith(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
}
