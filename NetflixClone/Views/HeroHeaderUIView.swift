//
//  HeroHeaderUIView.swift
//  NetflixClone
//
//  Created by Дмитрий Молодецкий on 21.08.2022.
//

import UIKit

class HeroHeaderUIView: UIView {
    
    private struct Constant {
        static var buttonLeadingOffset: CGFloat = 90
        static var buttonBottomOffset: CGFloat = 50
        static var betweenButtonOffset: CGFloat = 30
        static var buttonCornerRadius: CGFloat = 5
        static var buttonBorderWidth: CGFloat = 1
    }
    
    private var posterPath: String? {
        didSet {
            heroImageView.image = nil
            updatePoster()
        }
    }
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.setTitle("Play", for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = Constant.buttonBorderWidth
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = Constant.buttonCornerRadius
        return button
    }()
    
    private let downloadButton: UIButton = {
        let button = UIButton()
        button.setTitle("Download", for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = Constant.buttonBorderWidth
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = Constant.buttonCornerRadius
        return button
    }()
    
    private let heroImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "heroImage")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(heroImageView)
        addGradient()
        addSubview(playButton)
        addSubview(downloadButton)
        applyConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heroImageView.frame = bounds
    }
    
    required init?(coder: NSCoder) { nil }
    
    func configure(with model: ContentViewModel) {
        self.posterPath = model.posterPath
    }
    
    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.systemBackground.cgColor
        ]
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
    }
    
    private func applyConstraints() {
        let playButtonConstraints = [
            playButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constant.buttonLeadingOffset),
            playButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constant.buttonBottomOffset),
            playButton.widthAnchor.constraint(equalTo: downloadButton.widthAnchor),
            playButton.trailingAnchor.constraint(greaterThanOrEqualTo: downloadButton.leadingAnchor, constant: -Constant.betweenButtonOffset)
        ]
        
        let downloadButtonConstraints = [
            downloadButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constant.buttonLeadingOffset),
            downloadButton.bottomAnchor.constraint(equalTo: playButton.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(playButtonConstraints)
        NSLayoutConstraint.activate(downloadButtonConstraints)
    }
    
    private func updatePoster() {
        guard let posterPath = posterPath else { return }
        let imageManager = ImageManager(posterPath)
        imageManager.fetch { [weak self] poster in
            if posterPath == self?.posterPath {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3) {
                        self?.heroImageView.alpha = 0
                    } completion: { _ in
                        self?.heroImageView.image = poster
                        UIView.animate(withDuration: 0.3) {
                            self?.heroImageView.alpha = 1
                        }
                    }
                }
            }
        }
    }
}
