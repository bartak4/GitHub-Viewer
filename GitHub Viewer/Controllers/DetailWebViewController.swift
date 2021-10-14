//
//  DetailWebViewController.swift
//  GitHub Viewer
//
//  Created by Marek Bartak on 12.10.2021.
//

import UIKit
import WebKit

class DetailWebViewController: UIViewController, WKNavigationDelegate {
    
    var repository: RepositoryModel?
    
    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let safeRepository = repository {
            self.title = safeRepository.name
            let url = URL(string: safeRepository.url)!
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
        }
    }
}
