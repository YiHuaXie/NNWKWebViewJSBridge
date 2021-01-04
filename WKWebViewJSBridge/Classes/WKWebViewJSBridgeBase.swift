//
//  WKWebViewJSBridgeBase.swift
//  WKWebViewJSBridge
//
//  Created by NeroXie on 2020/12/31.
//

import Foundation

public typealias Message = [String: Any]

public typealias ResponseCallback = (_ responseData: Any?) -> Void

public typealias MessageHandler = (_ data: Any?, _ callback: ResponseCallback?) -> Void

protocol WKWebViewJSBridgeBaseDelegate: class {
    
    func evaluateJavaScript(_ javaScriptString: String)
}

class WKWebViewJSBridgeBase {
    
    static var logging = true
    
    weak var delegate: WKWebViewJSBridgeBaseDelegate? = nil
    
    private var messageHandlers = [String: MessageHandler]()
    
    private var responseCallbacks = [String: ResponseCallback]()
    
    private var startupMessageQueue = [Message]()
    
    private var uniqueId = 0
    
    init() {}
    
    func reset() {
        startupMessageQueue = []
        responseCallbacks = [:]
        uniqueId = 0
    }
    
    func register(handlerName: String, hanler: @escaping MessageHandler) {
        messageHandlers[handlerName] = hanler
    }
    
    public func remove(handlerName: String) {
        _ = messageHandlers.removeValue(forKey: handlerName)
    }
    
    func send(data: Any?, responseCallback: ResponseCallback?, for handlerName: String) {
        var message = Message()
        message["handlerName"] = handlerName
        
        if let data = data {
            message["data"] = data
        }
        
        if let responseCallback = responseCallback {
            uniqueId += 1
            let callbackId = "ios_cb_\(uniqueId)"
            responseCallbacks[callbackId] = responseCallback
            message["callbackId"] = callbackId
        }
        
        queue(message: message)
    }
    
    func flushMessageQueue(with messageQueueString: String) {
        guard let messages = deserialize(messageJSON: messageQueueString) else {
            log(messageQueueString)
            return
        }
        
        for message in messages {
            log(message)
            if let responseId = message["responseId"] as? String {
                guard let responseCallback = responseCallbacks[responseId] else {
                    continue
                }
                
                responseCallback(message["responseData"])
                responseCallbacks.removeValue(forKey: responseId)
            } else {
                var responseCallback: ResponseCallback? = nil
                if let callbackId = message["callbackId"] as? String {
                    responseCallback = { responseData in
                        let msg: Message = ["responseId": callbackId, "responseData": responseData ?? NSNull()]
                        self.queue(message: msg)
                    }
                } else {
                    responseCallback = { _ in
                        // Do nothing
                    }
                }
                
                guard let handlerName = message["handlerName"] as? String else {
                    continue
                }
                
                guard let handler = messageHandlers[handlerName] else {
                    log("NoHandlerException, No handler for message from JS: \(message)")
                    continue
                }
                
                handler(message["data"], responseCallback)
            }
        }
    }
    
    func injectJavaScriptFile() {
        delegate?.evaluateJavaScript(WKWebViewJSBridge_JavaScriptString)
    }
    
    // MARK: -
    private func queue(message: Message) {
        guard startupMessageQueue.isEmpty else {
            startupMessageQueue.append(message)
            return
        }
        
        dispatch(message: message)
    }
    
    private func dispatch(message: Message) {
        guard var messageJSON = serialize(message: message, pretty: false) else {
            return
        }
        
        messageJSON = messageJSON.replacingOccurrences(of: "\\", with: "\\\\")
        messageJSON = messageJSON.replacingOccurrences(of: "\"", with: "\\\"")
        messageJSON = messageJSON.replacingOccurrences(of: "\'", with: "\\\'")
        messageJSON = messageJSON.replacingOccurrences(of: "\n", with: "\\n")
        messageJSON = messageJSON.replacingOccurrences(of: "\r", with: "\\r")
        messageJSON = messageJSON.replacingOccurrences(of: "\u{000C}", with: "\\f")
        messageJSON = messageJSON.replacingOccurrences(of: "\u{2028}", with: "\\u2028")
        messageJSON = messageJSON.replacingOccurrences(of: "\u{2029}", with: "\\u2029")
        
        let js = "WKWebViewJSBridge.handleMessageFromiOS('\(messageJSON)');"
        if Thread.current.isMainThread {
            delegate?.evaluateJavaScript(js)
        } else {
            DispatchQueue.main.async {
                self.delegate?.evaluateJavaScript(js)
            }
        }
    }
    
    // MARK: - JSON
    private func serialize(message: Message, pretty: Bool) -> String? {
        var string: String?
        do {
            let options: JSONSerialization.WritingOptions = pretty ? .prettyPrinted : .init(rawValue: 0)
            let data = try JSONSerialization.data(withJSONObject: message, options: options)
            string = String(data: data, encoding: .utf8)
        } catch let error {
            log(error)
        }
        
        return string
    }
    
    private func deserialize(messageJSON: String) -> [Message]? {
        guard let data = messageJSON.data(using: .utf8) else { return nil }
        
        var messages: [Message]?
        do {
            messages = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Message]
        } catch let error {
            log(error)
        }
        
        return messages
    }
    
    // MARK: - Log
    private func log<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        guard type(of: self).logging else { return }
        
        let fileName = (file as NSString).lastPathComponent
        print("\(fileName):\(line) \(function) | \(message)")
        #endif
    }
}
