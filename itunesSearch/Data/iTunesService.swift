//
//  ITunesService.swift
//  itunesSearch
//
//  Created by K P on 2025-07-01.
//

import Foundation

protocol ITunesServiceProtocol {
    func searchTracks(for term: String, limit: Int, offset: Int) async throws -> [Track]
}

final class ITunesService: ITunesServiceProtocol {
    func searchTracks(for term: String, limit: Int = 10, offset: Int = 0) async throws -> [Track] {
        let baseURL = "https://itunes.apple.com/search"
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "country", value: "DK"),
            URLQueryItem(name: "media", value: "music"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        guard let url = components?.url else {
            throw SearchUseCaseError.invalidURL
        }

        let (data, urlResponse) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw SearchUseCaseError.invalidResponseFormat
        }
        
        let response = try JSONDecoder().decode(SearchResponse.self, from: data)
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw SearchUseCaseError.httpError
        }
        
        return response.results
    }
}
