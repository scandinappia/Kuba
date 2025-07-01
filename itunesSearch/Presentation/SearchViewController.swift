//
//  SearchViewController.swift
//  itunesSearch
//
//  Created by K P on 2025-07-01.
//

import UIKit
import SwiftUI
import Combine

final class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let viewModel: SearchViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let errorLabel = UILabel()
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupViews()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        setupSearchBar()
        setupTableView()
        addSubviews()
        setupConstraints()
    }

    private func setupSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search music"
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
    }

    private func setupTableView() {
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .onDrag

        loadingIndicator.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        tableView.tableFooterView = nil
    }

    private func addSubviews() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.$tracks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                guard let self else { return }
                if loading {
                    self.tableView.tableFooterView = self.loadingIndicator
                    self.loadingIndicator.startAnimating()
                } else {
                    self.loadingIndicator.stopAnimating()
                    self.tableView.tableFooterView = nil
                }
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let self = self, let message = error, !message.isEmpty {
                    self.showError(message)
                }
            }
            .store(in: &cancellables)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.tracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.reuseId, for: indexPath) as? TrackCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.tracks[indexPath.row])
        viewModel.loadMoreIfNeeded(currentIndex: indexPath.row)
        return cell
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.backgroundColor = .systemRed
        errorLabel.textColor = .white
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0

        if errorLabel.superview == nil {
            errorLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(errorLabel)

            NSLayoutConstraint.activate([
                errorLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                errorLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
            ])
        }

        errorLabel.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.errorLabel.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            UIView.animate(withDuration: 0.3, animations: {
                self.errorLabel.alpha = 0
            }) { _ in
                self.errorLabel.removeFromSuperview()
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.term = searchText
    }
}

// MARK: - SwiftUI

struct SearchView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SearchViewController {
        let service = ITunesService()
        let useCase = SearchUseCase(service: service)
        let viewModel = SearchViewModel(searchUseCase: useCase)
        return SearchViewController(viewModel: viewModel)
    }
    
    func updateUIViewController(_ uiViewController: SearchViewController, context: Context) { }
}
