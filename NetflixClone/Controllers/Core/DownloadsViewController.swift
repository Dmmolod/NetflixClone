//
//  DownloadsViewController.swift
//  NetflixClone
//
//  Created by Дмитрий Молодецкий on 21.08.2022.
//

import UIKit

class DownloadsViewController: UIViewController {
    
    var apiCaller: APICaller?
    private var contents = [ContentItem]()
    
    private let downloadingTable: UITableView = {
        let table = UITableView()
        table.register(ContentTableViewCell.self, forCellReuseIdentifier: ContentTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Downloads"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        view.addSubview(downloadingTable)
        downloadingTable.delegate = self
        downloadingTable.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLocalStorageForDownloads()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.downloadingTable.frame = view.bounds
    }
    
    private func fetchLocalStorageForDownloads() {
        DataPersistenseManager.shared.fetchingContentFromDataBase { [weak self] result in
            switch result {
            case .success(let contents):
                self?.contents = contents
                self?.downloadingTable.reloadData()
            case .failure(let error): print(error)
            }
        }
    }
    
    
}

extension DownloadsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContentTableViewCell.identifier,
                                                       for: indexPath) as? ContentTableViewCell else { return UITableViewCell() }
        let content = contents[indexPath.row]
        let contentViewModel = ContentViewModel(titleName: content.title == nil ? content.name : content.title,
                                                posterPath: content.posterPath)
        cell.configure(with: contentViewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            DataPersistenseManager.shared.deleteContent(with: contents[indexPath.row]) { [weak self] result in
                switch result {
                case .success():
                    self?.contents.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    print("Delete from the database")
                case .failure(let error): print(error)
                }
            }
        default: return
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil,
                                                previewProvider: nil) { [weak self] _ in
            let deleteAction = UIAction(title: "Delete",
                                        state: .off) { _ in
                guard let content = self?.contents[indexPath.row] else { return }
                DataPersistenseManager.shared.deleteContent(with: content) { result in
                    switch result {
                    case .success(): self?.fetchLocalStorageForDownloads()
                    case .failure(let error): print(error)
                    }
                }
            }
            return UIMenu(title: "",
                              image: nil,
                              identifier: nil,
                              options: .destructive,
                              children: [deleteAction])
        }
        return config
    }
}
