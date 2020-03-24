//
//  TESTViewController.swift
//  FunFreedom_Example
//
//  Created by 肖华 on 2020/2/10.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import WebKit

class TestViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var webView: WKWebView = {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController = WKUserContentController()
        configuration.userContentController.add(self, name: "AppModel")

        var webView = WKWebView(frame: self.view.frame, configuration: configuration)
        webView.scrollView.bounces = true
        webView.scrollView.alwaysBounceVertical = true
        webView.navigationDelegate = self
        return webView
    }()

    let HTML = try! String(contentsOfFile: Bundle.main.path(forResource: "index", ofType: "html")!, encoding: String.Encoding.utf8)

    override func viewDidLoad() {
        self.navigationController?.navigationBar.isTranslucent = false

        super.viewDidLoad()
        title = "WebViewJS交互Demo"
        view.backgroundColor = .white
        view.addSubview(webView)

        webView.loadHTMLString(HTML, baseURL: nil)
//        webView.loadFileURL(URL.init(fileURLWithPath: Bundle.main.path(forResource: "TestWeb", ofType: "html")!), allowingReadAccessTo: URL.init(fileURLWithPath: Bundle.main.bundlePath))
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("sayHello('WebView你好！')") { (result, err) in
//            print(result, err)
//            self.dismiss(animated: true, completion: nil)
        }
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
