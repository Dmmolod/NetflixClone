//
//  UpcomingViewController.swift
//  NetflixClone
//
//  Created by Дмитрий Молодецкий on 21.08.2022.
//

import UIKit

class UpcomingViewController: UIViewController {
    
    var apiCaller: APICaller?

    private var contents = [Content]()
    
    private let upcomingTable: UITableView = {
        let table = UITableView()
        table.register(ContentTableViewCell.self, forCellReuseIdentifier: ContentTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Upcoming"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        view.addSubview(upcomingTable)
        upcomingTable.delegate = self
        upcomingTable.dataSource = self
        
        fetchUpcoming()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        upcomingTable.frame = view.bounds
    }
    
    private func fetchUpcoming() {
        apiCaller?.get(for: .upcomingMovies) { [weak self] result in
            switch result {
            case .success(let contents):
                self?.contents = contents
                self?.upcomingTable.reloadData()
            case .failure(let error): print(error)
            }
        }
    }
    
}

extension UpcomingViewController: UITableViewDelegate, UITableViewDataSource {
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
        let vc = ContentPreviewViewController()

        apiCaller?.getMovie(with: contentName) { [weak self] result in
            switch result {
            case .success(let videoElement):
                vc.configure(with: ContentPreviewViewModel(title: contentName,
                                                           youtubeView: videoElement,
                                                           posterPath: nil,
                                                           contentOverview: content.overview,
                                                           images: nil),
                             navBarYOffset: nil)
                self?.navigationController?.pushViewController(vc, animated: true)
            case .failure(let error):
                
                self?.apiCaller?.getImages(for: String(content.id), { result in
                    switch result {
                    case .success(let contentImageResponse):
                        vc.configure(with: ContentPreviewViewModel(title: contentName,
                                                                   youtubeView: nil,
                                                                   posterPath: content.posterPath,
                                                                   contentOverview: content.overview,
                                                                   images: contentImageResponse.backdrops),
                                     navBarYOffset: nil)
                        self?.navigationController?.pushViewController(vc, animated: true)
                    case .failure(let error): print(error)
                    }
                })
                print(error)
            }
        }
    }
}
