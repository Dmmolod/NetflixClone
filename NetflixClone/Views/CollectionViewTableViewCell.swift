//
//  CollectionViewTableViewCell.swift
//  NetflixClone
//
//  Created by Дмитрий Молодецкий on 21.08.2022.
//

import UIKit

protocol CollectionViewTableViewCellDelegate: AnyObject {
    func collectionViewTableViewCellDidTapCell(viewModel: ContentPreviewViewModel)
}

class CollectionViewTableViewCell: UITableViewCell {
    
    var apiCaller: APICaller?
    
    weak var delegate: CollectionViewTableViewCellDelegate?
    
    private var contents = [Content]()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 140, height: 200)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ContentCollectionViewCell.self, forCellWithReuseIdentifier: ContentCollectionViewCell.identifier)
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .systemPink
        contentView.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    required init?(coder: NSCoder) { nil }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = contentView.bounds
    }
    
    func configure(with contents: [Content]) {
        self.contents = contents
        self.collectionView.reloadData()
    }
    
    private func downloadContent(at indexPath: IndexPath) {
        DataPersistenseManager.shared.downloadContent(with: contents[indexPath.item]) { result in
            switch result {
            case .success(): print("Downloaded to Database")
            case .failure(let error): print(error)
            }
        }
    }
}

extension CollectionViewTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCollectionViewCell.identifier,
                                                            for: indexPath) as? ContentCollectionViewCell else { return UICollectionViewCell()}
        let posterPath = contents[indexPath.item].posterPath
        
        cell.configur(with: posterPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let content = contents[indexPath.item]
        guard let contentName = content.title == nil ? content.name : content.title else { return }
        
        apiCaller?.getMovie(with: contentName + "trailer") { [weak self] result in
            switch result {
            case .success(let videoElement):
                let viewModel = ContentPreviewViewModel(title: contentName,
                                                        youtubeView: videoElement,
                                                        contentOverview: content.overview)
                
                self?.delegate?.collectionViewTableViewCellDidTapCell(viewModel: viewModel)
            case .failure(let error): print(error)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let config = UIContextMenuConfiguration(identifier: nil,
                                                previewProvider: nil) { [weak self] _ in
            let downloadAction = UIAction(title: "Download",
                                          subtitle: nil,
                                          image: nil,
                                          identifier: nil,
                                          discoverabilityTitle: nil,
                                          attributes: [],
                                          state: .off) { _ in
                self?.downloadContent(at: indexPath)
            }
            return UIMenu(title: "",
                          image: nil,
                          identifier: nil,
                          options: .displayInline,
                          children: [downloadAction])
        }
        return config
    }
}
