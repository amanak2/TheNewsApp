//
//  SpotlightVC.swift
//  TheNewsApp
//
//  Created by Aman Chawla on 07/05/19.
//  Copyright © 2019 Aman Chawla. All rights reserved.
//

import UIKit

class SpotlightVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: VARIABLES
    let searchController = UISearchController(searchResultsController: nil)
    var articles = [Article]()
    var sortedBy: String?
    var q = ""
    
    //MARK: ELEMENTS
    @IBOutlet weak var tableView: UITableView!
    
    let searchImg: UIImageView = {
        let img = UIImageView()
        img.image = #imageLiteral(resourceName: "startSearch")
        return img
    }()
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        
        return refreshControl
    }()
    
    //MARK: VIEWCONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "ArticleCell")
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresher
        } else {
            tableView.addSubview(refresher)
        }
        
        fetchArticles()
        setupNavbar()
        setupSearchBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tabBarController?.tabBar.isHidden = false
        navigationController?.isNavigationBarHidden = false
    }
    
    private func setupNavbar() {
        navigationController?.navigationBar.barTintColor = Theme.tintColor
        navigationController?.navigationBar.isTranslucent = false
    
        let titleLbl = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height))
        titleLbl.textColor = UIColor.white
        titleLbl.text = "Spotlight"
        titleLbl.font = Theme.boldFont
        navigationItem.titleView = titleLbl
        
        let btn = UIButton()
        let btnImg = UIImage(named: "filter")?.withRenderingMode(.alwaysTemplate)
        btn.setImage(btnImg, for: .normal)
        btn.tintColor = Theme.whiteColor
        btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn.addTarget(self, action: #selector(filterBtnPressed), for: .touchUpInside)
        let btnItem = UIBarButtonItem()
        btnItem.customView = btn
        
        self.navigationItem.rightBarButtonItems = [btnItem]
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.barStyle = .blackOpaque
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search News"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    //MARK: DATA FETCH
    private func fetchArticles() {
        
        if q != "" {
            let serverConnect = ServerConnect()
            var page: Int = 1
            
            page = UserUtil.fetchInt(forKey: "searchPage")!
            
            let url = URL(string: "\(EVERYTHING_BASE_URL)q=\(q)&sortBy=\(sortedBy ?? "publishedAt")&pageSize=10&page=\(page)\(API_KEY)")
            
            serverConnect.getArticles(fromUrl: url!) { (data, error) in
                
                if let error = error {
                    print(error)
                }
                
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(NewsResponse.self, from: data)
                        self.articles.append(contentsOf: response.articles)
                        
                        DispatchQueue.main.async {
                            page += 1
                            UserUtil.saveInt(withValue: page, forKey: "searchPage")
                            self.tableView.reloadData()
                        }
                    } catch let err {
                        print(err.localizedDescription)
                    }
                }
            }
        } else {
            //print img and label
            print("Please start search")
        }
    }
    
    @objc func refreshFeed() {
        UserUtil.saveInt(withValue: 1, forKey: "searchPage")
        self.articles.removeAll()
        self.tableView.reloadData()
        
        fetchArticles()
        
        //ADDING DELAY
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
    //MARK: ACTIONS
    @objc func filterBtnPressed() {
        let alertController = UIAlertController()
        
        let latestAction = UIAlertAction(title: "Latest", style: .default) { (latestAction) in
            self.sortedBy = "publishedAt"
            
            UserUtil.saveInt(withValue: 1, forKey: "searchPage")
            self.articles.removeAll()
            self.tableView.reloadData()
            
            self.fetchArticles()
        }
        
        let populerAction = UIAlertAction(title: "Populer", style: .default) { (populerAction) in
            self.sortedBy = "popularity"
            
            UserUtil.saveInt(withValue: 1, forKey: "searchPage")
            self.articles.removeAll()
            self.tableView.reloadData()
            
            self.fetchArticles()
        }
        
        let releventAction = UIAlertAction(title: "Relevent", style: .default) { (releventAction) in
            self.sortedBy = "relevancy"
            
            UserUtil.saveInt(withValue: 1, forKey: "searchPage")
            self.articles.removeAll()
            self.tableView.reloadData()
            
            self.fetchArticles()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(latestAction)
        alertController.addAction(populerAction)
        alertController.addAction(releventAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as? ArticleCell {
            
            let article = articles[indexPath.row]
            cell.article = article
            cell.selectionStyle = .none
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 162
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ArticleCell {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "WebViewVC") as? WebViewVC
            controller?.article = cell.article
            navigationController?.pushViewController(controller!, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            if indexPath.row == (articles.count - 1) {
                self.fetchArticles()
            }
        }
    }
    
}

extension SpotlightVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        UserUtil.saveInt(withValue: 1, forKey: "searchPage")
        self.articles.removeAll()
        self.tableView.reloadData()
        
        q = searchText
        
        fetchArticles()
    }
}
