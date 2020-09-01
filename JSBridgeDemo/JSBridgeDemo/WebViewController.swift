//
//  WebViewController.swift
//  JSBridgeDemo
//
//  Created by dengliwen on 2020/7/3.
//  Copyright © 2020 dsjk. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    var webView: WKWebView!
    var jsBridge: JSBridge!
    var urlString: String
    
    deinit {
        jsBridge.dispose()
        print("WebController deinited")
    }
    
    init(_ urlString: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        // Do any additional setup after loading the view.
        setupWebView()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "callH5", style: .plain, target: self, action: #selector(callH5))
    }
    
    @objc func callH5() {
        jsBridge.h5Toast()
    }
    
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.dataDetectorTypes = .all
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = preferences
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.scrollView.bounces = false
        webView.scrollView.isScrollEnabled = true
        webView.navigationDelegate = self
        webView.allowsLinkPreview = false
        
        jsBridge = JSBridge(webView: webView, delegate: self)
        
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        view.addSubview(webView)
        loadRequest()
    }
    
    func loadRequest() {
        if let request = H5URLRequest.requestFor(urlString, type: .bundle(inDir: "app1")) {
            webView.load(request)
        }
    }
}

extension WebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(#function)
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        print(#function)
    }
}
