//
//  SearchResultsViewController.swift
//  NetflixClone
//
//  Created by Дмитрий Молодецкий on 22.08.2022.
//

import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    func searchResultsViewControllerDidTapItem(_ viewModel: ContentPreviewViewModel)
}

class SearchResultsViewController: UIViewController {
    
    weak var delegate: SearchResultsViewControllerDelegate?
    var apiCaller: APICaller?
    var contents = [Content]()
    
    let searchResultsCollectionView: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width/3 - 5, height: 200)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10
        let colectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colectionView.register(ContentCollectionViewCell.self, forCellWithReuseIdentifier: ContentCollectionViewCell.identifier)
        return colectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemCyan
        
        view.addSubview(searchResultsCollectionView)
        searchResultsCollectionView.delegate = self
        searchResultsCollectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchResultsCollectionView.frame = view.bounds
    }
}

extension SearchResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCollectionViewCell.identifier,
                                                            for: indexPath) as? ContentCollectionViewCell else { return UICollectionViewCell() }
        let posterPath = contents[indexPath.item].posterPath
        cell.configur(with: posterPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let content = contents[indexPath.item]
        let contentName = (content.title == nil ? content.name : content.title) ?? ""

        apiCaller?.getMovie(with: contentName) { [weak self] result in
            switch result {
            case .success(let videoElement):
                self?.delegate?.searchResultsViewControllerDidTapItem(ContentPreviewViewModel(title: contentName,
                                                                                              youtubeView: videoElement,
                                                                                              posterPath: nil,
                                                                                              contentOverview: content.overview,
                                                                                              images: nil))
            case .failure(let error):
                self?.apiCaller?.getImages(for: String(content.id), { result in
                    guard let contentImageResponse = try? result.get() else { return }
                    self?.delegate?.searchResultsViewControllerDidTapItem(ContentPreviewViewModel(title: contentName,
                                                                                                  youtubeView: nil,
                                                                                                  posterPath: content.posterPath,
                                                                                                  contentOverview: content.overview,
                                                                                                  images: contentImageResponse.backdrops))
                })
                print(error)
            }
        }
    }
}
