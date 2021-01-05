#
# Be sure to run `pod lib lint WKWebViewJSBridge.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WKWebViewJSBridge'
  s.version          = '0.0.1'
  s.summary          = 'A bridge for sending messages between iOS and Javascript in WKWebView.'
  s.homepage         = 'https://github.com/YiHuaXie/WKWebViewJSBridge'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'YiHuaXie' => 'xyh30902@163.com' }
  s.source           = { :git => 'https://github.com/YiHuaXie/WKWebViewJSBridge.git', :tag => s.version.to_s }
  s.source_files     = 'WKWebViewJSBridge/Classes/**/*'
  s.platform         = :ios, '9.0'
  s.requires_arc     = true
end
