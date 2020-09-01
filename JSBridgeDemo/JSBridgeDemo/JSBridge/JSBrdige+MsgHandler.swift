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
    @objc func showMsg(_ jsMsg: JSMessage) {
        if let msg = jsMsg.data?["msg"] as? String {
            let alertVC = UIAlertController(title: "ShowMsg", message: msg, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alertVC.addAction(cancel)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertVC, animated: true, completion: nil)
            h5HandleResponse(["msg": "显示成功"], jsMsg.callbackId)
        }
    }
    
    @objc func navigate(_ jsMsg: JSMessage) {
        if let url = jsMsg.data?["url"] as? String {
            let vc = WebViewController(url)
            self.webVC?.navigationController?.pushViewController(vc, animated: true)
            h5HandleResponse(["msg": "跳转成功"], jsMsg.callbackId)
        }
    }
    
    @objc func request(_ jsMsg: JSMessage) {
        if let urlString = jsMsg.data?["url"] as? String, let url = URL(string: urlString) {
            let session = URLSession.shared
            let task = session.dataTask(with: url) {[weak self] (data, _, error) in
                var res = [String: Any]()
                if let error = error {
                    res = ["data": error.localizedDescription]
                } else if let data = data,
                    let string = String(bytes: data, encoding: .utf8) {
                    res = ["data": string]
                }
                self?.h5HandleResponse(res, jsMsg.callbackId)
            }
            task.resume()
        }
    }
}
