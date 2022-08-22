//
//  ViewController.swift
//  NetflixClone
//
//  Created by Дмитрий Молодецкий on 21.08.2022.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    private let apiCaller: APICaller
    
    init(_ apiCaller: APICaller) {
        self.apiCaller = apiCaller
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        let vc1 = HomeViewController()
        vc1.apiCaller = apiCaller
        let vc2 = UpcomingViewController()
        vc2.apiCaller = apiCaller
        let vc3 = SearchViewController()
        vc3.apiCaller = apiCaller
        let vc4 = DownloadsViewController()
        vc4.apiCaller = apiCaller
                
        let navVc1 = UINavigationController(rootViewController: vc1)
        let navVc2 = UINavigationController(rootViewController: vc2)
        let navVc3 = UINavigationController(rootViewController: vc3)
        let navVc4 = UINavigationController(rootViewController: vc4)
        
        navVc1.tabBarItem.image = UIImage(systemName: "house")
        navVc2.tabBarItem.image = UIImage(systemName: "play.circle")
        navVc3.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        navVc4.tabBarItem.image = UIImage(systemName: "arrow.down.to.line")
        
        navVc1.title = "Home"
        navVc2.title = "Coming Soon"
        navVc3.title = "Top Search"
        navVc4.title = "Downloads"
        
        tabBar.tintColor = .label
        
        setViewControllers([navVc1, navVc2, navVc3, navVc4], animated: true)
    }
}

