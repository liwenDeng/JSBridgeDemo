//
//  JSBrdige+MsgSender.swift
//  JSBridgeDemo
//
//  Created by dengliwen on 2020/8/19.
//  Copyright © 2020 dsjk. All rights reserved.
//

import Foundation

/// 发送native调用h5功能的消息
extension JSBridge {
    @objc func onShow() {
        self.callH5Method("onShow") { (data) in
            
        }
    }
    @objc func onHide() {
        self.callH5Method("onHide") { (data) in
            
        }
    }
    
    @objc func h5Toast() {
        self.callH5Method("h5Toast", ["title": "test"]) { (data) in
            
        }
    }
}
