//
//  SearchableRecord.swift
//  Continuum
//
//  Created by Alex Kennedy on 10/8/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    func matches(searchTerm: String) -> Bool
}
