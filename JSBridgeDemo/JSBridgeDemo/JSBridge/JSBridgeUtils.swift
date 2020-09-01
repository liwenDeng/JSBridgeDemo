//
//  JSBridgeUtils.swift
//  JSBridgeDemo
//
//  Created by dengliwen on 2020/8/18.
//  Copyright © 2020 dsjk. All rights reserved.
//

import Foundation

extension Dictionary {
    public func formatJSON() -> String? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions()) {
            let jsonStr = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            return String(jsonStr ?? "")
        }
        return nil
    }
}

extension String {
    /// 特殊字符处理
    func jsonJavaScriptCoding() -> String {
        var res = self
        let map = ["\\": "\\\\",
                   "\"": "\\\"",
                   "\'": "\\\'",
                   "\n": "\\n",
                   "\r": "\\r",
                   "\u{f}": "\\f",
                   "\u{2028}": "\\u2028",
                   "\u{2029}": "\\u2029",
        ]
        for item in map {
            res = res.replacingOccurrences(of: item.value, with: item.key)
        }
        return res
    }
}
