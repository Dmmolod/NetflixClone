//
//  ContentCollectionViewCell.swift
//  NetflixClone
//
//  Created by Дмитрий Молодецкий on 21.08.2022.
//

import UIKit

class ContentCollectionViewCell: UICollectionViewCell {
    
    private var posterPath: String? {
        didSet {
            posterImageView.image = nil
            updatePoster()
        }
    }
    
    private let activity: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView()
        activity.color = .systemPink
        activity.style = .large
        return activity
    }()
    
    private let posterImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(posterImageView)
        contentView.addSubview(activity)
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        posterImageView.frame = contentView.bounds
        activity.center = contentView.center
    }
    
    func configur(with posterPath: String?) {
        self.posterPath = posterPath
    }
    
    private func updatePoster() {
        guard let posterPath = posterPath else { return }
        let imageManager = ImageManager(posterPath)
        activity.startAnimating()
        
        imageManager.fetch { poster in
            if posterPath == self.posterPath {
                DispatchQueue.main.async { [weak self] in
                    self?.activity.stopAnimating()
                    self?.posterImageView.image = poster
                }
            }
        }

    }
    
}
