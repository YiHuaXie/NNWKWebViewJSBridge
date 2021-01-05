//
//  WKWebViewJSBridge_JS.swift
//  WKWebViewJSBridge
//
//  Created by NeroXie on 2021/1/1.
//

let WKWebViewJSBridge_JavaScriptString = """
; (function () {
    if (window.WKWebViewJSBridge) {
        return;
    }

    if (!window.onerror) {
        window.onerror = function (msg, url, line) {
            log("WKWebViewJSBridge: ERROR:" + msg + "@" + url + ":" + line);
        }
    }

    let sendMessageQueue = [];
    let messageHandlers = {};
    let responseCallbacks = {};
    let uniqueId = 1;

    const registerHandler = (handlerName, handler) => {
        messageHandlers[handlerName] = handler;
    };

    const callHandler = (handlerName, data, responseCallback) => {
        if (arguments.length == 2 && typeof data == 'function') {
            responseCallback = data;
            data = null;
        }
        doSend({ handlerName: handlerName, data: data }, responseCallback);
    }

    const fetchQueue = () => {
        var messageQueueString = JSON.stringify(sendMessageQueue);
        sendMessageQueue = [];
        return messageQueueString;
    }

    const handleMessageFromiOS = messageJSON => {
        dispatchMessageFromiOS(messageJSON);
    }

    window.WKWebViewJSBridge = {
        registerHandler: registerHandler,
        callHandler: callHandler,
        fetchQueue: fetchQueue,
        handleMessageFromiOS: handleMessageFromiOS
    };

    function doSend(message, responseCallback) {
        if (responseCallback) {
            var callbackId = 'cb_' + (uniqueId++) + '_' + new Date().getTime();
            responseCallbacks[callbackId] = responseCallback;
            message['callbackId'] = callbackId;
        }
        sendMessageQueue.push(message);

        window.webkit.messageHandlers.iOS_FlushMessageQueue.postMessage(null)
    }

    function dispatchMessageFromiOS(messageJSON) {
        var message = JSON.parse(messageJSON);
        var responseCallback;

        if (message.responseId) {
            responseCallback = responseCallbacks[message.responseId];
            if (!responseCallback) {
                return;
            }
            responseCallback(message.responseData);
            delete responseCallbacks[message.responseId];
        } else {
            if (message.callbackId) {
                var callbackResponseId = message.callbackId;
                responseCallback = function (responseData) {
                    doSend({ handlerName: message.handlerName, responseId: callbackResponseId, responseData: responseData });
                };
            }

            var handler = messageHandlers[message.handlerName];
            if (!handler) {
                console.log("WKWebViewJSBridge: WARNING: no handler for message from iOS:", message);
            } else {
                handler(message.data, responseCallback);
            }
        }
    }

    const callWKWebViewJSBridgeCallbacks = () => {
        var callbacks = window.WKWebViewJSBridgeCallbacks;
        delete window.WKWebViewJSBridgeCallbacks;
        for (let i = 0; i < callbacks.length; i++) {
            callbacks[i](WKWebViewJSBridge);
        }
    };

    setTimeout(callWKWebViewJSBridgeCallbacks, 0);
})();
"""
