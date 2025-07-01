//
//  Track.swift
//  itunesSearch
//
//  Created by K P on 2025-07-01.
//

import Foundation

struct Track: Decodable {
    let trackName: String?
    let artistName: String?
    let releaseDate: String?
    let artworkUrl100: String?
    let longDescription: String?
}
