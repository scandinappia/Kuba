//
//  SearchViewModel.swift
//  itunesSearch
//
//  Created by K P on 2025-07-01.
//

import Foundation
import Combine

final class SearchViewModel: ObservableObject {
    @Published var tracks: [Track] = []
    @Published var query: String = ""
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private let searchUseCase: SearchUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(searchUseCase: SearchUseCaseProtocol) {
        self.searchUseCase = searchUseCase
        
        $query
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] term in
                guard let self else { return }
                
                Task {
                    await self.search(term)
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func search(_ term: String) async {
        guard !query.isEmpty else {
            tracks = []
            return
        }
        isLoading = true
        do {
            let results = try await searchUseCase.execute(term: term)
            tracks = results
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
