//
//  ContentPreviewViewController.swift
//  NetflixClone
//
//  Created by Дмитрий Молодецкий on 22.08.2022.
//

import UIKit
import WebKit

class ContentPreviewViewController: UIViewController {
    
    private var navBarYOffset: CGFloat?
    
    private var images: [UIImage?] = []
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private var postersScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private var posterPaths: [ContentImage]? {
        didSet {
            updatePoster()
        }
    }
    
    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    private let contentLable: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.text = "Harry Potter"
        return label
    }()
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        label.text = "This is the best movie for a children on the world!"
        return label
    }()
    private let downloadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Download", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.label.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(postersScrollView)
        scrollView.addSubview(webView)
        scrollView.addSubview(contentLable)
        scrollView.addSubview(overviewLabel)
        scrollView.addSubview(downloadButton)
        
        applyConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.transform = .identity
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        guard let navBarYOffset = navBarYOffset else { return }
        navigationController?.navigationBar.frame.origin.y = navBarYOffset    }
    
    private func applyConstraints() {
        
        let scrollViewConstraints = [
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
        let webViewConstraints = [
            webView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            webView.heightAnchor.constraint(equalToConstant: 300),
            webView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ]
        let contentLableConstraints = [
            contentLable.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 20),
            contentLable.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor,constant: 20),
            contentLable.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
        ]
        let overviewLabelConstraints = [
            overviewLabel.topAnchor.constraint(equalTo: contentLable.bottomAnchor, constant: 20),
            overviewLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            overviewLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
        ]
        let downloadButtonConstraints = [
            downloadButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            downloadButton.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 25),
            downloadButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            downloadButton.widthAnchor.constraint(equalToConstant: 120),
            downloadButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        let postersScrollViewConstraints = [
            postersScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            postersScrollView.heightAnchor.constraint(equalToConstant: 300),
            postersScrollView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            postersScrollView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(scrollViewConstraints)
        NSLayoutConstraint.activate(webViewConstraints)
        NSLayoutConstraint.activate(contentLableConstraints)
        NSLayoutConstraint.activate(overviewLabelConstraints)
        NSLayoutConstraint.activate(downloadButtonConstraints)
        NSLayoutConstraint.activate(postersScrollViewConstraints)
    }
    
    func configure(with model: ContentPreviewViewModel, navBarYOffset: CGFloat?) {
        contentLable.text = model.title
        overviewLabel.text = model.contentOverview
        self.navBarYOffset = navBarYOffset
        
        if let videoId = model.youtubeView?.id.videoId {
            webView.isHidden = false
            guard let url = URL(string: "https://www.youtube.com/embed/\(videoId)") else { return }
        
            webView.load(URLRequest(url: url))
        } else {
            webView.isHidden = true
            self.posterPaths = model.images
        }
    }
    
    private func updatePoster() {
        guard let posterPaths = posterPaths else { return }
        
        let imagesGroup = DispatchGroup()
        
        for imageIndex in 0..<(posterPaths.count > 10 ? 10 : posterPaths.count) {
            imagesGroup.enter()
            
            ImageManager(posterPaths[imageIndex].filePath).fetch(completion: { [weak self] image in
                self?.images.append(image)
                imagesGroup.leave()
            })
        }
        
        imagesGroup.notify(queue: .main) { [weak self] in
            self?.configPosterScrollView()
        }
    }
    
    private func configPosterScrollView() {
        if images.isEmpty { return }

        let imagesForScroll = images.map { UIImageView(image: $0) }
        let stackView = UIStackView(arrangedSubviews: imagesForScroll)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        postersScrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: postersScrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: postersScrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: postersScrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: postersScrollView.trailingAnchor),
            stackView.widthAnchor.constraint(equalToConstant: view.bounds.width * CGFloat(images.count))
        ])
    }
}
