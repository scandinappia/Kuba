//
//  SearchResponse.swift
//  itunesSearch
//
//  Created by K P on 2025-07-01.
//

import Foundation

struct SearchResponse: Decodable {
    let results: [Track]
}
