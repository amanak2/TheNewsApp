//
//  WebViewVC.swift
//  TheNewsApp
//
//  Created by Aman Chawla on 07/05/19.
//  Copyright © 2019 Aman Chawla. All rights reserved.
//

import UIKit
import WebKit

class WebViewVC: UIViewController, WKNavigationDelegate {

    //MARK: ELEMENTS
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    //MARK: VARIABLES
    var article: Article?
    var webView = WKWebView()
    
    //MARK: VIEW CONTROLLER
    override func loadView() {
        webView.navigationDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: article!.url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        setupNavbar()
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
        titleLbl.text = article?.source.name
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
    
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}
