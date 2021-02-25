//
//  JSBrdige+MsgSender.swift
//  JSBridgeDemo
//
//  Created by dengliwen on 2020/8/19.
//  Copyright © 2020 dsjk. All rights reserved.
//

import Foundation

/// 调用h5注册的接口
extension JSBridge {
    @objc func onAppShow() {
        invoke("onAppShow");
    }
    @objc func onAppHide() {
        invoke("onAppHide");
    }
    @objc func h5Toast() {
        invoke("h5Toast", ["title": "testTitle"]) { (data) in
            print(data)
        }
    }
}
