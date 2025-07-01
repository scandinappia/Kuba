//
//  TrackCell.swift
//  itunesSearch
//
//  Created by K P on 2025-07-01.
//

import UIKit

final class TrackCell: UITableViewCell {
    static let reuseId = "TrackCell"
    
    private let artworkImageView = UIImageView()
    private let trackNameLabel = UILabel()
    private let artistNameLabel = UILabel()
    private let releaseDateLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupViews() {
        artworkImageView.contentMode = .scaleAspectFit
        artworkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        trackNameLabel.font = .boldSystemFont(ofSize: 16)
        trackNameLabel.numberOfLines = 0
        trackNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        artistNameLabel.font = .systemFont(ofSize: 14)
        artistNameLabel.textColor = .secondaryLabel
        artistNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        releaseDateLabel.font = .systemFont(ofSize: 12)
        releaseDateLabel.textColor = .secondaryLabel
        releaseDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.font = .systemFont(ofSize: 12)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(artworkImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(releaseDateLabel)
        contentView.addSubview(descriptionLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            artworkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            artworkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            artworkImageView.widthAnchor.constraint(equalToConstant: 100),
            artworkImageView.heightAnchor.constraint(equalToConstant: 100),
            artworkImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
            
            trackNameLabel.leadingAnchor.constraint(equalTo: artworkImageView.trailingAnchor, constant: 8),
            trackNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            trackNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            artistNameLabel.leadingAnchor.constraint(equalTo: trackNameLabel.leadingAnchor),
            artistNameLabel.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor, constant: 4),
            artistNameLabel.trailingAnchor.constraint(equalTo: trackNameLabel.trailingAnchor),
            
            releaseDateLabel.leadingAnchor.constraint(equalTo: trackNameLabel.leadingAnchor),
            releaseDateLabel.topAnchor.constraint(equalTo: artistNameLabel.bottomAnchor, constant: 4),
            releaseDateLabel.trailingAnchor.constraint(equalTo: trackNameLabel.trailingAnchor),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: trackNameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 4),
            descriptionLabel.trailingAnchor.constraint(equalTo: trackNameLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with track: Track) {
        trackNameLabel.text = track.trackName ?? "Unknown"
        artistNameLabel.text = track.artistName ?? "Unknown artist"
        
        if let releaseDateString = track.releaseDate,
           let date = ISO8601DateFormatter().date(from: releaseDateString) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            releaseDateLabel.text = formatter.string(from: date)
        } else {
            releaseDateLabel.text = "Unknown date"
        }
                
        if let urlString = track.artworkUrl100,
           let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self,
                      let data = data,
                      let image = UIImage(data: data),
                      error == nil else {
                    DispatchQueue.main.async {
                        self?.artworkImageView.image = nil
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.artworkImageView.image = image
                }
            }
            task.resume()
        } else {
            artworkImageView.image = nil
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
}
