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
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
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
        
        NSLayoutConstraint.activate(scrollViewConstraints)
        NSLayoutConstraint.activate(webViewConstraints)
        NSLayoutConstraint.activate(contentLableConstraints)
        NSLayoutConstraint.activate(overviewLabelConstraints)
        NSLayoutConstraint.activate(downloadButtonConstraints)
    }
    
    func configure(with model: ContentPreviewViewModel, navBarYOffset: CGFloat?) {
        contentLable.text = model.title
        overviewLabel.text = model.contentOverview
        self.navBarYOffset = navBarYOffset
                
        guard let url = URL(string: "https://www.youtube.com/embed/\(model.youtubeView.id.videoId)") else { return }
        
        webView.load(URLRequest(url: url))
    }
}
