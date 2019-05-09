//
//  HeadlineVC.swift
//  TheNewsApp
//
//  Created by Aman Chawla on 09/05/19.
//  Copyright © 2019 Aman Chawla. All rights reserved.
//

import UIKit

class HeadlineVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: VARIABLES
    var articles = [Article]()
    var category: String!
    
    //MARK: ELEMENTS
    @IBOutlet weak var tableView: UITableView!
    
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
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresher
        } else {
            tableView.addSubview(refresher)
        }
        
        tableView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "ArticleCell")
        
        setupNavbar()
        fetchHeadlines()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
        navigationController?.isNavigationBarHidden = false
    }
    
    private func setupNavbar() {
        navigationController?.navigationBar.barTintColor = Theme.tintColor
        navigationController?.navigationBar.isTranslucent = false
        
        let titleLbl = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height))
        titleLbl.textColor = UIColor.white
        titleLbl.text = category
        titleLbl.font = Theme.boldFont
        navigationItem.titleView = titleLbl
        
        let btn = UIButton()
        btn.setTitle("back", for: .normal)
        btn.tintColor = Theme.whiteColor
        btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn.addTarget(self, action: #selector(backBtnPressed), for: .touchUpInside)
        let btnItem = UIBarButtonItem()
        btnItem.customView = btn
        
        self.navigationItem.leftBarButtonItem = btnItem
    }
    
    //MARK: DATA FETCH
    private func fetchHeadlines() {
        let serverConnect = ServerConnect()
        var page: Int = 1
        
        page = UserUtil.fetchInt(forKey: "headlinePage")!
        
        let url = URL(string: "\(HEADLINE_BASE_URL)country=us&category=\(category ?? "General")&pageSize=10&page=\(page)\(API_KEY)")
        
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
                        UserUtil.saveInt(withValue: page, forKey: "headlinePage")
                        self.tableView.reloadData()
                    }
                } catch let err {
                    print(err.localizedDescription)
                }
            }
        }
    }
    
    //MARK: ACTION BUTTON
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func refreshFeed() {
        UserUtil.saveInt(withValue: 1, forKey: "headlinePage")
        self.articles.removeAll()
        self.tableView.reloadData()
        
        fetchHeadlines()
        
        //ADDING DELAY
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
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
                self.fetchHeadlines()
            }
        }
    }
    
}
