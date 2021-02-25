//
//  JSBridge.swift
//  JSBridgeDemo
//
//  Created by dengliwen on 2020/7/3.
//  Copyright © 2020 dsjk. All rights reserved.
//

import UIKit
import WebKit

typealias MessageData = Dictionary<String, Any>
typealias MessageDataCallback = (_ data: MessageData?)->()
typealias MessageDataHandler = (_ data: MessageData?, _ response: MessageDataCallback)->()

class JSMessage: NSObject {
    enum MessageType: String {
        case requestMessage = "RequestMessage"
        case responseMessage = "ResponseMessage"
    }
    
    var action: String
    var data: MessageData?
    var messageId: String
    var messageType: MessageType?
    
    init(action: String, data: MessageData?, messageId: String, messageType: String) {
        self.action = action
        self.data = data
        self.messageId = messageId
        self.messageType = MessageType(rawValue: messageType)
        super.init()
    }
    
    convenience init?(_ dict: MessageData) {
        if let action = dict["action"] as? String,
            let data = dict["data"] as? Dictionary<String, Any>,
            let messageId = dict["messageId"] as? String,
            let messageType = dict["messageType"] as? String {
            self.init(action:action, data: data, messageId: messageId, messageType: messageType)
        } else {
            return nil
        }
    }
    
    func formatJSONString() -> String {
        let msgDict: [String : Any] = [
            "action": action,
            "data": data ?? "",
            "messageId": messageId,
            "messageType": messageType?.rawValue ?? "unknown",
        ]
        return msgDict.formatJSON() ?? ""
    }
}

class JSBridge: NSObject, WKScriptMessageHandler {
    
    private let messagehandlerName = "JSBridge"
    private let handleNativeMsgFuncName = "_receiveMsg"
    private let jsBrdigeObject = "bridge"
    private weak var webView: WKWebView?
    private weak var scriptDelegate: WKScriptMessageHandler?
    private var callbackMaps = Dictionary<String, MessageDataCallback>()
    private var registeredHandlerMap = Dictionary<String, MessageDataHandler>()
    
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
        receiveMsg(message)
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

// MARK: Core
extension JSBridge {
    /// 调用h5方法
    func invoke(_ action: String, _ data: MessageData? = nil, _ callback: MessageDataCallback? = nil) {
        var messageId = ""
        if let callback = callback {
            messageId = UUID().uuidString
            callbackMaps[messageId] = callback
        }
        let msg = JSMessage(action: action, data: data, messageId: messageId, messageType: JSMessage.MessageType.requestMessage.rawValue)
        sendMsg(msg)
    }
    
    /// 注册方法
    func register(_ action: String, handler: @escaping MessageDataHandler) {
        registeredHandlerMap[action] = handler
    }
    
    private func sendMsg(_ msg: JSMessage) {
        let js = """
        \(jsBrdigeObject).\(handleNativeMsgFuncName)(\(msg.formatJSONString()))
        """
        evaluateJavaScript(js)
    }
    
    /// 处理H5发送过来的消息
    private func receiveMsg(_ msg: WKScriptMessage) {
        if !isSupportMsg(msg) { return }
        if let body = msg.body as? Dictionary<String, Any>,
           let jsMsg = JSMessage(body) {
            if jsMsg.messageType == .responseMessage {
                handleResponseMsg(jsMsg)
            } else if jsMsg.messageType == .requestMessage {
                handleRequestMsg(jsMsg)
            } else {
                print("Error msssage")
            }
        } else {
            print("Error msssage")
        }
    }
    
    /// 响应类型消息处理
    private func handleResponseMsg(_ msg: JSMessage) {
        if let callback = callbackMaps[msg.messageId] {
            callback(msg.data)
        }
    }
    
    /// 请求类型消息处理
    private func handleRequestMsg(_ msg: JSMessage) {
        if let handler = registeredHandlerMap[msg.action] {
            //构造响应数据回调
            let responseCallback: MessageDataCallback =  { [weak self] (responseData)  in
                let responseMsg = JSMessage(action: msg.action, data: responseData, messageId: msg.messageId, messageType: JSMessage.MessageType.responseMessage.rawValue)
                self?.sendMsg(responseMsg)
            }
            handler(msg.data, responseCallback)
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


