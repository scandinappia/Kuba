//
//  ITunesService.swift
//  itunesSearch
//
//  Created by K P on 2025-07-01.
//

import Foundation

protocol ITunesServiceProtocol {
    func searchTracks(for term: String) async throws -> [Track]
}

final class ITunesService: ITunesServiceProtocol {
    func searchTracks(for term: String) async throws -> [Track] {
        let baseURL = "https://itunes.apple.com/search"
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "country", value: "DK"),
            URLQueryItem(name: "media", value: "music")
        ]
        guard let url = components?.url else {
            throw SearchUseCaseError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        struct SearchResponse: Decodable {
            let results: [Track]
        }
        
        let response = try JSONDecoder().decode(SearchResponse.self, from: data)
        return response.results
    }
}
