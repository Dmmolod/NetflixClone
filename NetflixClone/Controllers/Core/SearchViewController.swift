//
//  SearchViewController.swift
//  NetflixClone
//
//  Created by Дмитрий Молодецкий on 21.08.2022.
//

import UIKit

class SearchViewController: UIViewController {
    
    var apiCaller: APICaller? {
        didSet {
            (searcController.searchResultsController as? SearchResultsViewController)?.apiCaller = apiCaller
        }
    }

    private var contents = [Content]()
    
    private let discoverTable: UITableView = {
        let table = UITableView()
        table.register(ContentTableViewCell.self, forCellReuseIdentifier: ContentTableViewCell.identifier)
        return table
    }()
    
    private let searcController: UISearchController = {
        let controller = UISearchController(searchResultsController: SearchResultsViewController())
        controller.searchBar.placeholder = "Search for a Movie or a Tv show"
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        view.addSubview(discoverTable)
        discoverTable.delegate = self
        discoverTable.dataSource = self
        
        navigationItem.searchController = searcController
        
        navigationController?.navigationBar.tintColor = .label
        
        fetchDiscoverMovies()
        
        searcController.searchResultsUpdater = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        discoverTable.frame = view.bounds
    }
    
    private func fetchDiscoverMovies() {
        apiCaller?.getDiscoverMovies { [weak self] result in
            switch result {
            case .success(let contents):
                self?.contents = contents
                self?.discoverTable.reloadData()
            case .failure(let error): print(error.localizedDescription)
            }
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContentTableViewCell.identifier,
                                                       for: indexPath) as? ContentTableViewCell else { return UITableViewCell() }
        
        let content = contents[indexPath.row]
        let model = ContentViewModel(titleName: content.title == nil ? content.name : content.title,
                                     posterPath: content.posterPath)
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let content = contents[indexPath.row]
        guard let contentName = content.title != nil ? content.title : content.name else { return }
        
        apiCaller?.getMovie(with: contentName) { [weak self] result in
            switch result {
            case .success(let videoElement):
                let vc = ContentPreviewViewController()
                vc.configure(with: ContentPreviewViewModel(title: contentName,
                                                           youtubeView: videoElement,
                                                           contentOverview: content.overview),
                             navBarYOffset: nil)
                
                self?.navigationController?.pushViewController(vc, animated: true)
                
            case .failure(let error): print(error.localizedDescription)
            }
        }
    }
}

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        
        guard let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              query.trimmingCharacters(in: .whitespaces).count >= 3,
              let resultsController = searchController.searchResultsController as? SearchResultsViewController else { return }
        
        resultsController.delegate = self
        apiCaller?.search(with: query) { result in
            switch result {
            case .success(let contents):
                resultsController.contents = contents
                resultsController.searchResultsCollectionView.reloadData()
            case .failure(let error): print(error)
            }
        }
    }
}

extension SearchViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewControllerDidTapItem(_ viewModel: ContentPreviewViewModel) {
        let vc = ContentPreviewViewController()
        vc.configure(with: viewModel, navBarYOffset: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
}
