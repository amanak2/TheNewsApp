//
//  ViewController.swift
//  TheNewsApp
//
//  Created by Aman Chawla on 06/05/19.
//  Copyright © 2019 Aman Chawla. All rights reserved.
//

import UIKit

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CategoryMenuBtn, HeadlineSelection {
    
    //MARK: VARIABLES
    var headlines = [Article]()
    var latestArticles = [Article]()
    var category: String = "General"
    
    //MARK: ELEMENTS
    @IBOutlet weak var tableView: UITableView!
    
    var categoryMenuBar: CategoryMenuBar = {
        let view = CategoryMenuBar()
        return view
    }()
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        
        return refreshControl
    }()
    
    //MARK: VIEW CONTROLLER
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        
        tableView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "ArticleCell")
        tableView.register(UINib(nibName: "HeadlineCollectionCell", bundle: nil), forCellReuseIdentifier: "HeadlineCollectionCell")
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresher
        } else {
            tableView.addSubview(refresher)
        }
        
        categoryMenuBar.delegate = self
        
        fetchLatest()
        fetchHeadlines()
        setupCategoryMenuBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tabBarController?.tabBar.isHidden = false
        navigationController?.isNavigationBarHidden = true
    }
    
    private func setupCategoryMenuBar() {
        let blueView = UIView()
        blueView.backgroundColor = Theme.tintColor
        
        view.addSubview(blueView)
        view.addContraintWithFormat(format: "H:|[v0]|", views: blueView)
        view.addContraintWithFormat(format: "V:[v0(50)]", views: blueView)
        
        view.addSubview(categoryMenuBar)
        view.addContraintWithFormat(format: "H:|[v0]|", views: categoryMenuBar)
        view.addContraintWithFormat(format: "V:[v0(50)]", views: categoryMenuBar)
        
        categoryMenuBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    }
    

    //MARK: DATA FETCH
    private func fetchHeadlines() {
        let serverConnect = ServerConnect()
        
        let url = URL(string: "\(HEADLINE_BASE_URL)country=us&category=\(category)&pageSize=10&page=1\(API_KEY)")

        serverConnect.getArticles(fromUrl: url!) { (data, error) in
            
            if let error = error {
                print(error)
            }
            
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(NewsResponse.self, from: data)
                    self.headlines.append(contentsOf: response.articles)

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch let err {
                    print(err.localizedDescription)
                }
            }
        }
    }
    
    private func fetchLatest() {
        let serverConnect = ServerConnect()
        var page: Int = 2
        
        page = UserUtil.fetchInt(forKey: "latestPage")!

        
        let url = URL(string: "\(HEADLINE_BASE_URL)&country=us&category=\(category)&pageSize=10&page=\(page)\(API_KEY)")
        
        serverConnect.getArticles(fromUrl: url!) { (data, error) in
            
            if let error = error {
                print(error)
            }
            
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(NewsResponse.self, from: data)
                    self.latestArticles.append(contentsOf: response.articles)

                    DispatchQueue.main.async {
                        page += 1
                        UserUtil.saveInt(withValue: page, forKey: "latestPage")
                        self.tableView.reloadData()
                    }
                } catch let err {
                    print(err.localizedDescription)
                }
            }
        }
    }
    
    @objc func refreshFeed() {
        UserUtil.saveInt(withValue: 2, forKey: "latestPage")
        self.latestArticles.removeAll()
        self.headlines.removeAll()
        self.tableView.reloadData()
        
        fetchLatest()
        fetchHeadlines()
        
        //ADDING DELAY
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
    private func currentTime() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    //MARK: ACTIONs
    func categorySelected(category: String) {
        UserUtil.saveInt(withValue: 2, forKey: "latestPage")
        self.latestArticles.removeAll()
        self.headlines.removeAll()
        self.tableView.reloadData()
        
        self.category = category
        
        fetchLatest()
        fetchHeadlines()
    }
    
    func countrySelected(country: String) {
        //
    }
    
    func cellSelected(article: Article) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "WebViewVC") as? WebViewVC
        controller?.article = article
        navigationController?.pushViewController(controller!, animated: true)
    }
    
    @objc func handleAllHeadlines() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "HeadlinesVC")
        navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: TABLEVIEW
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            return latestArticles.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "HeadlineCollectionCell", for: indexPath) as? HeadlineCollectionCell {
                
                cell.articles = headlines
                cell.selectionStyle = .none
                cell.delegate = self
                cell.collectionView.reloadData()
                
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as? ArticleCell {
                
                let article = latestArticles[indexPath.row]
                cell.article = article
                cell.selectionStyle = .none
                
                return cell
            }
        default:
            return UITableViewCell()
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 136
        default:
            return 162
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case 0:
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 42))
            headerView.backgroundColor = UIColor.white
            
            let label = UILabel()
            label.text = "Headlines"
            label.font = UIFont.boldSystemFont(ofSize: 30)
            
            let btn = UIButton()
            btn.setTitle("All", for: .normal)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            btn.setTitleColor(Theme.tintColor, for: .normal)
            btn.addTarget(self, action: #selector(handleAllHeadlines), for: .touchUpInside)
            
            headerView.addSubview(btn)
            headerView.addSubview(label)
            headerView.addContraintWithFormat(format: "H:|-10-[v0]-8-[v1]-10-|", views: label, btn)
            headerView.addContraintWithFormat(format: "V:|[v0]|", views: label)
            headerView.addContraintWithFormat(format: "V:|[v0]|", views: btn)
            
            return headerView
        case 1:
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 42))
            headerView.backgroundColor = UIColor.white
            
            let label = UILabel()
            label.text = "Latest"
            label.font = UIFont.boldSystemFont(ofSize: 30)
            
            headerView.addSubview(label)
            headerView.addContraintWithFormat(format: "H:|-10-[v0]|", views: label)
            headerView.addContraintWithFormat(format: "V:|[v0]|", views: label)
            
            return headerView
        default:
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if let cell = tableView.cellForRow(at: indexPath) as? ArticleCell {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "WebViewVC") as? WebViewVC
                controller?.article = cell.article
                navigationController?.pushViewController(controller!, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            if indexPath.row == (latestArticles.count - 1) {
                self.fetchLatest()
            }
        }
    }
    
}

