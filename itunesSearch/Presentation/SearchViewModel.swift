//
//  SearchViewModel.swift
//  itunesSearch
//
//  Created by K P on 2025-07-01.
//

import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var tracks: [Track] = []
    @Published var term: String = ""
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let searchUseCase: SearchUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    private var currentOffset = 0
    private let limit = 10
    private var hasMoreResults = true

    init(searchUseCase: SearchUseCaseProtocol) {
        self.searchUseCase = searchUseCase

        $term
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] term in
                guard let self else { return }
                Task {
                    await self.startNewSearch(term)
                }
            }
            .store(in: &cancellables)
    }

    func loadMoreIfNeeded(currentIndex: Int) {
        guard currentIndex >= tracks.count - 3 else { return }
        search(term)
    }

    private func startNewSearch(_ term: String) async {
        currentOffset = 0
        hasMoreResults = true
        tracks = []
        search(term)
    }

    private func search(_ term: String) {
        guard !term.isEmpty, !isLoading, hasMoreResults else { return }
        isLoading = true

        Task {
            do {
                let newTracks = try await searchUseCase.execute(term: term,
                                                                limit: limit,
                                                                offset: currentOffset)
                self.tracks.append(contentsOf: newTracks)
                self.currentOffset += newTracks.count
                self.hasMoreResults = newTracks.count == self.limit
                self.errorMessage = nil
            } catch {
                self.errorMessage = error.localizedDescription
                self.hasMoreResults = false
            }
            self.isLoading = false
        }
    }
}
