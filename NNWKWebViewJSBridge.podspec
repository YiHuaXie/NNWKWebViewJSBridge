#
# Be sure to run `pod lib lint WKWebViewJSBridge.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NNWKWebViewJSBridge'
  s.version          = '0.0.3'
  s.summary          = 'A lightweight JavaScript bridge in WKWebView.'
  s.homepage         = 'https://github.com/YiHuaXie/NNWKWebViewJSBridge'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'YiHuaXie' => 'xyh30902@163.com' }
  s.source           = { :git => 'https://github.com/YiHuaXie/NNWKWebViewJSBridge.git', :tag => s.version.to_s }
  s.source_files     = 'NNWKWebViewJSBridge/Classes/**/*'
  s.platform         = :ios, '9.0'
  s.requires_arc     = true
  # s.swift_version    = '5.0'
end
