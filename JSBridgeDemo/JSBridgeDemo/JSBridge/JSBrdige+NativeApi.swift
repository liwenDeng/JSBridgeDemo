//
//  JSBrdige+MsgHandler.swift
//  JSBridgeDemo
//
//  Created by dengliwen on 2020/8/19.
//  Copyright © 2020 dsjk. All rights reserved.
//

import UIKit

/// 处理H5发送到Native的业务功能消息
extension JSBridge {
    // 注册native接口
    func registerNativeApis() {
        register("nativeToast") {[weak self] (data, reponseCallback) in
            print("nativeToast show title: \(data?["title"] ?? "")")
            let alert = UIAlertController(title: "提示", message: data?["title"] as? String ?? "", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "确定", style: .default, handler: nil)
            alert.addAction(cancel)
            self?.webVC?.present(alert, animated: true, completion: nil)
            reponseCallback(["title": "nativeToast Finished"])
        }
    }
    
//    func onRequest(data: MessageData?, callback: MessageDataCallback) {
//
//    }
//
//    @objc func showMsg(_ jsMsg: JSMessage) {
//        if let msg = jsMsg.data?["msg"] as? String {
//            let alertVC = UIAlertController(title: "ShowMsg", message: msg, preferredStyle: .alert)
//            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
//            alertVC.addAction(cancel)
//            UIApplication.shared.keyWindow?.rootViewController?.present(alertVC, animated: true, completion: nil)
//
//        }
//    }
//
//    @objc func showMsg(_ jsMsg: JSMessage, callback: ()->()) {
//        callback();
//    }
//
//    @objc func navigate(_ jsMsg: JSMessage) {
//        if let url = jsMsg.data?["url"] as? String {
//            let vc = WebViewController(url)
//            self.webVC?.navigationController?.pushViewController(vc, animated: true)
//
//        }
//    }
//
//    @objc func request(_ jsMsg: JSMessage) {
//        if let urlString = jsMsg.data?["url"] as? String, let url = URL(string: urlString) {
//            let session = URLSession.shared
//            let task = session.dataTask(with: url) {[weak self] (data, _, error) in
//                var res = [String: Any]()
//                if let error = error {
//                    res = ["data": error.localizedDescription]
//                } else if let data = data,
//                    let string = String(bytes: data, encoding: .utf8) {
//                    res = ["data": string]
//                }
//            }
//            task.resume()
//        }
//    }
}
