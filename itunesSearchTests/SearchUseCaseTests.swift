//
//  SearchUseCaseTests.swift
//  itunesSearchTests
//
//  Created by K P on 2025-07-01.
//

import XCTest
@testable import itunesSearch

final class SearchUseCaseTests: XCTestCase {
    func testExecuteReturnsTracks() async throws {
        // Given
        let mockService = MockService()
        let expectedTracks = [Track(trackName: "Test",
                                    artistName: "Artist",
                                    releaseDate: nil,
                                    artworkUrl100: nil)]
        mockService.result = .success(expectedTracks)
        let useCase = SearchUseCase(service: mockService)
        
        // When
        let tracks = try await useCase.execute(term: "test")
        
        // Then
        XCTAssertEqual(tracks.count, expectedTracks.count)
        XCTAssertEqual(mockService.calledWithTerm, "test")
    }
    
    func testExecuteThrowsError() async {
        // Given
        let mockService = MockService()
        let expectedError = NSError(domain: "TestError", code: 1, userInfo: nil)
        mockService.result = .failure(expectedError)
        let useCase = SearchUseCase(service: mockService)
        
        // When
        do {
            _ = try await useCase.execute(term: "test")
            // Then
            XCTFail("Expected error but got success")
        } catch {
            // Then
            XCTAssertEqual(error as NSError, expectedError)
        }
    }
}

// MARK: - Mock Service

final class MockService: ITunesServiceProtocol {
    var calledWithTerm: String?
    var calledWithLimit: Int?
    var calledWithOffset: Int?
    var result: Result<[Track], Error> = .success([])

    func searchTracks(for term: String, limit: Int, offset: Int) async throws -> [Track] {
        calledWithTerm = term
        calledWithLimit = limit
        calledWithOffset = offset
        switch result {
        case .success(let tracks):
            return tracks
        case .failure(let error):
            throw error
        }
    }
}
