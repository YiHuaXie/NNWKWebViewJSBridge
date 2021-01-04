//
//  ViewController.swift
//  WKWebViewJSBridge
//
//  Created by xyh30902@163.com on 12/31/2020.
//  Copyright (c) 2020 xyh30902@163.com. All rights reserved.
//

import UIKit
import WebKit
import WKWebViewJSBridge

class ViewController: UIViewController {
    
    let webView = WKWebView(frame: CGRect(), configuration: WKWebViewConfiguration())
    
    var bridge: WKWebViewJSBridge!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        webView.frame = view.bounds
        webView.navigationDelegate = self
        view.addSubview(webView)
        
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
        bridge.register(handlerName: "nameFromNative") { (data, callback) in
            print("[nameFormNative] called by JS, Data: \(data!)")
            print("Native responding Data!")
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
        bridge.call(handlerName: "nameFromJS", data: "Hi, JS!") { response in
            print("Native got response: \(response!)")
        }
    }
    
    @objc
    private func didClearButtonPressed() {
        webView.reload()
    }
}

extension ViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("webViewDidStartLoad")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webViewDidFinishLoad")
    }
}
