//
//  JSBridge.swift
//  JSBridgeDemo
//
//  Created by dengliwen on 2020/7/3.
//  Copyright © 2020 dsjk. All rights reserved.
//

import UIKit
import WebKit

class JSMessage: NSObject {
    var action: String
    var data: Dictionary<String, Any>?
    var callbackId: String
    
    init(action: String, data: Dictionary<String, Any>?, callbackId: String) {
        self.action = action
        self.data = data
        self.callbackId = callbackId
        super.init()
    }
    
    convenience init?(_ dict: Dictionary<String, Any>) {
        if let action = dict["action"] as? String,
            let data = dict["data"] as? Dictionary<String, Any>,
            let callbackId = dict["callbackId"] as? String {
            self.init(action:action, data: data, callbackId: callbackId)
        } else {
            return nil
        }
    }
    
    func formatJSONString() -> String {
        let msgDict: [String : Any] = [
            "action": action,
            "data": data ?? "",
            "callbackId": callbackId
        ]
        return msgDict.formatJSON() ?? ""
    }
}

class JSBridge: NSObject, WKScriptMessageHandler {
    
    private let messagehandlerName = "JSBridge"
    private let handleNativeResponseAction = "handleNativeResponse"
    private let handleNativeMsgFuncName = "handleNativeMsg"
    private let jsBrdigeObject = "bridge"
    
    private weak var webView: WKWebView?
    private weak var scriptDelegate: WKScriptMessageHandler?
    private var callbackMaps = Dictionary<String, (_ data: Dictionary<String, Any>?)->()>()
    
    var webVC: UIViewController? {
        if let vc = self.scriptDelegate as? UIViewController {
            return vc
        }
        return nil
    }
    
    deinit {
        print("JSBridge deinit")
    }
    
    init(webView: WKWebView, delegate: WKScriptMessageHandler) {
        self.webView = webView
        self.scriptDelegate = delegate
        super.init()
        webView.configuration.userContentController.add(self, name: messagehandlerName)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        scriptDelegate?.userContentController(userContentController, didReceive: message)
        print("收到JS消息: \(message.name), \(message.body)")
        handleJSMsg(message)
    }
    
    func dispose() {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: messagehandlerName)
    }
    
    private func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)? = nil) {
        print("调用js方法：\(javaScriptString)")
        DispatchQueue.main.async {[weak self] in
            self?.webView?.evaluateJavaScript(javaScriptString, completionHandler: completionHandler)
        }
    }
}

// MARK: SendMsg
extension JSBridge {
    /// 调用h5的方法
    func callH5Method(_ action: String, _ data: Dictionary<String, Any>? = nil, _ callback: ((Dictionary<String, Any>?)->())?) {
        var callbackId: String?
        if let callback = callback {
            callbackId = UUID().uuidString
            callbackMaps[callbackId!] = callback
        }
        let msg = JSMessage(action: action, data: data, callbackId: callbackId ?? "")
        sendMsg(msg)
    }
    
    /// 告诉h5处理响应数据
    func h5HandleResponse(_ data: Dictionary<String, Any>, _ callbackId: String) {
        let msg = JSMessage(action: handleNativeResponseAction, data: data, callbackId: callbackId)
        sendMsg(msg)
    }
    
    private func sendMsg(_ msg: JSMessage) {
        // brdige.foo(args)
        let js = """
        \(jsBrdigeObject).\(handleNativeMsgFuncName)(\(msg.formatJSONString()))
        """
        evaluateJavaScript(js)
    }
}

// MARK: HandleJSMsg
extension JSBridge {
    /// 处理H5发送过来的消息
    private func handleJSMsg(_ msg: WKScriptMessage) {
        if !isSupportMsg(msg) { return }
        if let body = msg.body as? Dictionary<String, Any>,
            let jsMsg = JSMessage(body) {
            dispatchMsg(jsMsg)
        }
    }
    
    /// 消息分发
    private func dispatchMsg(_ jsMsg: JSMessage) {
        let selector = Selector("\(jsMsg.action):")
        if self.responds(to: selector) {
            DispatchQueue.main.async {
               self.perform(selector, with: jsMsg)
            }
        }
    }
    
    /// native消息回调处理
    private func handleH5Response(_ jsMsg: JSMessage) {
        let callbackId = jsMsg.callbackId
        if let callbackFunction = callbackMaps[callbackId] {
            callbackFunction(jsMsg.data)
            callbackMaps.removeValue(forKey: callbackId)
        }
    }
    
    /// 是否是支持的消息类型
    private func isSupportMsg(_ msg: WKScriptMessage) -> Bool {
        if msg.name != messagehandlerName {
            return false
        }
        return true
    }
}


