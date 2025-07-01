//
//  SearchUseCase.swift
//  itunesSearch
//
//  Created by K P on 2025-07-01.
//

import Foundation

protocol SearchUseCaseProtocol {
    func execute(term: String, limit: Int, offset: Int) async throws -> [Track]
}

final class SearchUseCase: SearchUseCaseProtocol {
    private let service: ITunesServiceProtocol
    
    init(service: ITunesServiceProtocol) {
        self.service = service
    }
    
    func execute(term: String, limit: Int = 10, offset: Int = 0) async throws -> [Track] {
        try await service.searchTracks(for: term, limit: limit, offset: offset)
    }
}

// MARK: - Errors

enum SearchUseCaseError: Error {
    case invalidURL
}
