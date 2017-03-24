//
//  IEHWebView.swift
//  IEHWKWebView
//
//  Created by Ismail el Habbash on 24/03/2017.
//  Copyright © 2017 ismail el habbash. All rights reserved.
//
import Foundation

import UIKit
import WebKit

protocol WebRequestable {
    func load(html text: String) throws
    func load(webUrl url: URL) throws
}

enum WebRequestableErrors: Error {
    case urlUnreachable(NSError), noMethodFound(NSError)
}

enum Result<T> {
    case success(T), error(NSError)
}

extension WKWebView: WebRequestable {}
extension UIWebView: WebRequestable {}

extension WebRequestable {

    func load(html text: String) throws {
        if let webView = self as? WKWebView {
            webView.loadHTMLString(text, baseURL: nil)
        } else if let webView = self as? UIWebView {
            webView.loadHTMLString(text, baseURL: nil)
        } else {
            let error = NSError(domain: "IEHWebView.noMethodFound", code: 0, userInfo: nil)
            throw WebRequestableErrors.noMethodFound(error)
        }
    }

    func load(webUrl url: URL) throws {
        guard UIApplication.shared.canOpenURL(url) else {
            let error = NSError(domain: "unreachableUrl", code: 0, userInfo: nil)
            throw WebRequestableErrors.urlUnreachable(error)
        }
        if let webView = self as? WKWebView {
            webView.load(URLRequest(url: url))
        } else if let webView = self as? UIWebView {
            webView.loadRequest(URLRequest(url: url))
        } else {
            let error = NSError(domain: "IEHWebView.noMethodFound", code: 0, userInfo: nil)
            throw WebRequestableErrors.noMethodFound(error)
        }
    }
}

class IEHWebViewViewController: UIViewController {

    lazy fileprivate var wkWebView = WKWebView()
    lazy fileprivate var uiWebView = UIWebView()

    var webView: WebRequestable {
        if #available(iOS 9.0, *) {
            return wkWebView
        } else {
            return uiWebView
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let webView = webView as? UIView else { return }
        setupWebView(webView)
    }

    func load(fromLocalFile fullHtmlFilePath: String, completion: ((Result<Bool>) -> Void)?) {
        do {
            let text = try String(contentsOfFile: fullHtmlFilePath)
            try webView.load(html: text)
            completion?(.success(true))
        } catch let error as NSError {
            completion?(.error(error))
            dismiss(animated: true, completion: nil)
        }
    }

    func load(fromWebUrl url: URL, completion: ((Result<Bool>) -> Void)?) {
        do {
            try webView.load(webUrl: url)
            completion?(.success(true))
        } catch let error as NSError {
            completion?(.error(error))
            dismiss(animated: true, completion: nil)
        }
    }

    fileprivate func setupWebView(_ webView: UIView) {
        let views = ["webView": webView]
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        let verticalContraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[webView]-0-|", options: [], metrics: nil, views: views)
        let horizontalContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[webView]-0-|", options: [], metrics: nil, views: views)
        view.addConstraints(verticalContraints + horizontalContraints)
    }
}
