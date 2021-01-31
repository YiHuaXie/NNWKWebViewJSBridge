//
//  WKWebViewJSBridge.swift
//  WKWebViewJSBridge
//
//  Created by NeroXie on 2020/12/31.
//

import WebKit

private let iOS_InjectJavascript = "iOS_InjectJavascript"

private let iOS_FlushMessageQueue = "iOS_FlushMessageQueue"

public class WKWebViewJSBridge: NSObject {
    
    public static var logging = true {
        didSet {
            WKWebViewJSBridgeBase.logging = logging
        }
    }
    
    public private(set) weak var webView: WKWebView?
    
    private var base = WKWebViewJSBridgeBase()
    
    private var userContentController = WKUserContentController()
    
    /// Initializes a `WKWebViewJSBridge`
    public required init(webView: WKWebView) {
        super.init()
        
        self.webView = webView
        
        base.delegate = self
        base.reset()
        
        addScriptMessageHandlers()
    }
    
    deinit {
        removeScriptMessageHandlers()
    }
    
    // MARK: - Public Method
    
    /// Registers a handler in native
    public func register(handlerName: String, hanler: @escaping MessageHandler) {
        base.register(handlerName: handlerName, hanler: hanler)
    }
    
    /// Removes a handler in native
    public func remove(handlerName: String) {
        base.remove(handlerName: handlerName)
    }
    
    /// Calls a JavaScript handler
    public func call(handlerName: String, data: Any? = nil, callback: ResponseCallback? = nil) {
        base.send(data: data, responseCallback: callback, for: handlerName)
    }
    
    public func reset() {
        base.reset()
    }
    
    // MARK: - Private Method
    
    private func addScriptMessageHandlers() {
        let wrapper = ScriptMessageHandlerWrapper(target: self)
        webView?.configuration.userContentController.add(wrapper, name: iOS_InjectJavascript)
        webView?.configuration.userContentController.add(wrapper, name: iOS_FlushMessageQueue)
    }
    
    private func removeScriptMessageHandlers() {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: iOS_InjectJavascript)
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: iOS_FlushMessageQueue)
    }
    
    private func flushMessageQueue() {
        // native call javascript
        webView?.evaluateJavaScript("WKWebViewJSBridge.fetchQueue();") { (result, error) in
            if let error = error {
                print("WKWebViewJSBridge: WARNING: Error when trying to fetch data from WKWebView: \(String(describing: error))")
            }
            
            guard let resultString = result as? String else {
                return
            }
            
            self.base.flushMessageQueue(with: resultString)
        }
    }
}

extension WKWebViewJSBridge: WKWebViewJSBridgeBaseDelegate {
    
    func evaluateJavaScript(_ javaScriptString: String) {
        webView?.evaluateJavaScript(javaScriptString, completionHandler: nil)
    }
}

extension WKWebViewJSBridge: WKScriptMessageHandler {
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case iOS_InjectJavascript:
            base.injectJavaScriptFile()
        case iOS_FlushMessageQueue:
            flushMessageQueue()
        default:
            break
        }
    }
}

/// `ScriptMessageHandlerWrapper` used to warp `WKWebViewJSBridge`. It will solve the memory leak.
fileprivate class ScriptMessageHandlerWrapper: NSObject {
    
    weak var target: WKScriptMessageHandler?
    
    init(target: WKScriptMessageHandler) {
        super.init()
        self.target = target
    }
}

extension ScriptMessageHandlerWrapper: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        target?.userContentController(userContentController, didReceive: message)
    }
}

