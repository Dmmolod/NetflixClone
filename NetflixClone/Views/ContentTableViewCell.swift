//
//  ContentTableViewCell.swift
//  NetflixClone
//
//  Created by Дмитрий Молодецкий on 21.08.2022.
//

import UIKit

class ContentTableViewCell: UITableViewCell {
    
    private var posterPath: String? {
        didSet {
            contentPoster.image = nil
            updatePoster()
        }
    }
    
    private let contentPoster: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let contentLable: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playContentButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "play.circle")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(contentPoster)
        contentView.addSubview(contentLable)
        contentView.addSubview(playContentButton)
        
        applyConstraints()
    }
    required init?(coder: NSCoder) { nil }
    
    private func applyConstraints() {
        let contentPosterConstraints = [
            contentPoster.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentPoster.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            contentPoster.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            contentPoster.widthAnchor.constraint(equalToConstant: 110)
        ]
        let contentLableConstraints = [
            contentLable.leadingAnchor.constraint(equalTo: contentPoster.trailingAnchor, constant: 20),
            contentLable.trailingAnchor.constraint(equalTo: playContentButton.leadingAnchor, constant: -20),
            contentLable.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ]
        let playContentButtonConstraints = [
            playContentButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            playContentButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            playContentButton.widthAnchor.constraint(equalToConstant: 30),
            playContentButton.heightAnchor.constraint(equalToConstant: 30)
        ]
        NSLayoutConstraint.activate(contentPosterConstraints)
        NSLayoutConstraint.activate(contentLableConstraints)
        NSLayoutConstraint.activate(playContentButtonConstraints)

    }
    
    func configure(with model: ContentViewModel) {
        posterPath = model.posterPath
        contentLable.text = model.titleName
    }
    
    private func updatePoster() {
        guard let posterPath = posterPath else { return }
        let imageManager = ImageManager(posterPath)
        
        imageManager.fetch { [weak self] poster in
            guard posterPath == self?.posterPath else { return }
            DispatchQueue.main.async {
                self?.contentPoster.image = poster
            }
        }
    }
}
