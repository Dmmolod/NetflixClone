//
//  HomeViewController.swift
//  NetflixClone
//
//  Created by Дмитрий Молодецкий on 21.08.2022.
//

import UIKit

enum HomeSectionType: Int, CaseIterable {
    case trendingMovies = 0
    case trendingTv
    case popular
    case upcomingMovies
    case topRated
    
    var urlPath: String {
        switch self {
        case .trendingMovies: return "trending/movie/day"
        case .trendingTv: return "trending/tv/day"
        case .upcomingMovies: return "movie/upcoming"
        case .popular: return "movie/popular"
        case .topRated: return "movie/top_rated"
        }
    }
    
    var title: String {
        guard let index = Self.allCases.firstIndex(of: self) else { return "Oh, sorry" }
        return sectionTitles[index]
    }
    
    private var sectionTitles: [String] {
        [ "Trending Movies", "Trending Tv", "Popular", "Upcoming Movies", "Top rated"]
    }
}

class HomeViewController: UIViewController {
    
    var apiCaller: APICaller?
    
    private var randomTrengindMovie: Content?
    private var headerView: HeroHeaderUIView?
    
    private let homeFeedTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(homeFeedTable)
        
        homeFeedTable.delegate = self
        homeFeedTable.dataSource = self
        
        configureNavBar()
        
        headerView = HeroHeaderUIView(frame: CGRect(x: 0, y: 0,
                                                        width: view.bounds.width,
                                                        height: 450))
        homeFeedTable.tableHeaderView = headerView
        configureHeaderView()
    }
    
    private func configureHeaderView() {
        apiCaller?.get(for: .trendingMovies) { [weak self] result in
            switch result {
            case .success(let contents):
                let currentContent = contents.randomElement()
                self?.randomTrengindMovie = currentContent
                let contentViewModel = ContentViewModel(titleName: currentContent?.title == nil ? currentContent?.name : currentContent?.title,
                                                        posterPath: currentContent?.posterPath)
                self?.headerView?.configure(with: contentViewModel)
            case .failure(let error): print(error.localizedDescription)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeFeedTable.frame = view.bounds
    }
    
    private func configureNavBar() {
        let image = UIImage(named: "netflixLogo")?.withRenderingMode(.alwaysOriginal)
        let barButtonItem = UIBarButtonItem(image: nil, landscapeImagePhone: image, style: .done, target: self, action: nil)
        barButtonItem.image = image
        barButtonItem.title = nil
        
        navigationItem.leftBarButtonItem = barButtonItem
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .done, target: self, action: nil)
        ]
        
        navigationController?.navigationBar.tintColor = .label
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return HomeSectionType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.identifier,
                                                       for: indexPath) as? CollectionViewTableViewCell,
              let sectionType = HomeSectionType(rawValue: indexPath.section) else { return UITableViewCell() }
        
        cell.delegate = self
        cell.apiCaller = apiCaller
        
        apiCaller?.get(for: sectionType) { result in
            switch result {
            case .success(let contents): cell.configure(with: contents)
            case .failure(let error): print(error.localizedDescription)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return HomeSectionType.allCases[section].title
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.textColor = .label
        header.textLabel?.text = header.textLabel?.text?.uppercasedFirstLetter
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffset = view.safeAreaInsets.top
        let offset = scrollView.contentOffset.y + defaultOffset
     
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
    }
}

extension HomeViewController: CollectionViewTableViewCellDelegate {
    
    func collectionViewTableViewCellDidTapCell(viewModel: ContentPreviewViewModel) {
        let vc = ContentPreviewViewController()
        vc.configure(with: viewModel, navBarYOffset: navigationController?.navigationBar.frame.origin.y)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
