# WKWebViewJSBridge

[![Language](https://img.shields.io/badge/Language-Swift-FFA08F.svg)](https://github.com/apple/swift)
[![License](https://img.shields.io/cocoapods/l/NNWKWebViewJSBridge.svg?style=flat)](https://raw.githubusercontent.com/YiHuaXie/NNWKWebViewJSBridge/master/LICENSE)
[![Version](https://img.shields.io/cocoapods/v/NNWKWebViewJSBridge.svg?style=flat)](https://cocoapods.org/pods/NNWKWebViewJSBridge)

## 简介

在看了[WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge)的项目，我希望可以用swift去实现一个JavaScript bridge，所以写了这个项目。该项目是基于`WebViewJavascriptBridge`实现，仅支持`WKWebView`。

关于`WebViewJavascriptBridge`的实现，有兴趣的可以看一下我的笔记[WebViewJavascriptBridge源码分析](https://www.neroxie.com/2021/01/26/WebViewJavascriptBridge%E6%BA%90%E7%A0%81%E5%88%86%E6%9E%90/)。

![WKWebViewJSBridge_demo](https://neroblog.oss-cn-hangzhou.aliyuncs.com/WKWebViewJSBridge_demo.jpg)

## 使用

### Native端

#### 1. 初始化

使用`WKWebView`初始化bridge对象

```swift
 let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
 bridge = WKWebViewJSBridge(webView: webView)
```

#### 2. JavaScript调用Native

Native注册函数给JavaScript调用

```swift
bridge.register(handlerName: "nameFromNative") { [weak self] (data, callback) in
    self?.data.append("[nameFormNative] called by JS, Data: \(data!)")
    self?.data.append("Native responding Data!")
    self?.tableView.reloadData()
    callback?("Nero Native")
}
```

#### 3. Native调用JavaScript

Native调用JavaScript

```swift
bridge.call(handlerName: "JSBridgeBegin")
```

### JavaScript端

#### 1. 初始化

复制以下代码到你的项目中

```js
function setupWKWebViewJSBridge(callback) {
	if (window.WKWebViewJSBridge) {
		return callback(WKWebViewJSBridge);
	}

	if (window.WKWebViewJSBridgeCallbacks) {
		return window.WKWebViewJSBridgeCallbacks.push(callback);
	}
	window.WKWebViewJSBridgeCallbacks = [callback];

	window.webkit.messageHandlers.iOS_InjectJavascript.postMessage(null);
}
```

#### 2. JavaScript注册函数或者调用Native函数

调用`setupWKWebViewJSBridge`函数后用bridge来注册Handlers以及调用Native Handlers。

```js
setupWKWebViewJSBridge(bridge => {
	bridge.registerHandler('JSBridgeBegin', (data, responseCallback) => {
		log('JSBridge Begin, Data', data, true);
	});

	bridge.registerHandler('nameFromJS', (data, responseCallback) => {
		log('[nameFromJS] called by Native, Data', data, true);
		log('JS responding Data!', 'Nero JS', true);
		responseCallback('Nero JS');
	});
});
```

## 要求

`iOS 9.0+`。

## 安装

```ruby
pod 'NNWKWebViewJSBridge'
```

## 作者

+ 邮箱：xyh30902@163.com

## 许可证

NNWKWebViewJSBridge 基于 MIT 许可证，查看 LICENSE 文件了解更多信息。
