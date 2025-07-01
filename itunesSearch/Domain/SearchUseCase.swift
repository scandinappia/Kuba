//
//  SearchUseCase.swift
//  itunesSearch
//
//  Created by K P on 2025-07-01.
//

import Foundation

protocol SearchUseCaseProtocol {
    func execute(term: String) async throws -> [Track]
}

final class SearchUseCase: SearchUseCaseProtocol {
    private let service: ITunesServiceProtocol
    
    init(service: ITunesServiceProtocol) {
        self.service = service
    }
    
    func execute(term: String) async throws -> [Track] {
        try await service.searchTracks(for: term)
    }
}

// MARK: - Errors

enum SearchUseCaseError: Error {
    case invalidURL
}
