//
//  ViewController.swift
//  WKWebViewJSBridge
//
//  Created by xyh30902@163.com on 12/31/2020.
//  Copyright (c) 2020 xyh30902@163.com. All rights reserved.
//

import UIKit
import WebKit
import NNWKWebViewJSBridge

class ViewController: UIViewController {
    
    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    
    var bridge: WKWebViewJSBridge!
    
    let tableView = UITableView(frame: .zero, style: .plain)
    
    var data: [String] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
                
        webView.frame = CGRect(x: view.bounds.origin.x, y: view.bounds.origin.y, width: view.bounds.size.width, height: view.bounds.size.height * 0.5)
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        tableView.backgroundColor = .gray
        tableView.frame = CGRect(x: view.bounds.origin.x, y: view.bounds.size.height * 0.5, width: view.bounds.size.width, height: view.bounds.size.height * 0.5)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        tableView.rowHeight = 30;
        view.addSubview(tableView)
        
        let width: CGFloat = (UIScreen.main.bounds.size.width - 40) * 0.5
        let y: CGFloat = UIScreen.main.bounds.size.height - 100
        let callJSButton = UIButton(type: .custom)
        callJSButton.backgroundColor = .red
        callJSButton.frame = CGRect(x: 10, y: y, width: width, height: 35)
        callJSButton.setTitle("Call JS", for: .normal)
        callJSButton.addTarget(self, action: #selector(didCallJSButtonPressed), for: .touchUpInside)
        view.addSubview(callJSButton)
        
        let clearButton = UIButton(type: .custom)
        clearButton.frame = CGRect(x: 30 + width, y: y, width: width, height: 35)
        clearButton.backgroundColor = .black
        clearButton.setTitle("Clear", for: .normal)
        clearButton.addTarget(self, action: #selector(didClearButtonPressed), for: .touchUpInside)
        view.addSubview(clearButton)
        
        
        bridge = WKWebViewJSBridge(webView: webView)
        bridge.register(handlerName: "nameFromNative") { [weak self] (data, callback) in
            self?.data.append("[nameFormNative] called by JS, Data: \(data!)")
            self?.data.append("Native responding Data!")
            self?.tableView.reloadData()
            callback?("Nero Native")
        }
        
        bridge.call(handlerName: "JSBridgeBegin")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let path = Bundle.main.path(forResource: "demo", ofType: "html") else {
            return
        }
        
        do {
            let html = try String(contentsOfFile: path, encoding: .utf8)
            let url = URL(fileURLWithPath: path)
            webView.loadHTMLString(html, baseURL: url)
        } catch let error {
            print(error)
        }
    }
    
    @objc
    private func didCallJSButtonPressed() {
        bridge.call(handlerName: "nameFromJS", data: "Hi, JS!") { [weak self] response in
            self?.data.append("Native got response: \(response!)")
            self?.tableView.reloadData()
        }
    }
    
    @objc
    private func didClearButtonPressed() {
        webView.reload()
        data.removeAll()
        tableView.reloadData()
    }
}

extension ViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        data.append("webViewDidStartLoad")
        tableView.reloadData()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        data.append("webViewDidFinishLoad")
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { data.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)")!
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 10)
        return cell
    }
}

