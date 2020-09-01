//
//  H5URLRequest.swift
//  JSBridgeDemo
//
//  Created by dengliwen on 2020/8/20.
//  Copyright © 2020 dsjk. All rights reserved.
//

import Foundation

class H5URLRequest {
    enum RequestType {
        case remote
        case bundle(inDir: String)
        case sandbox(inDir: String)
    }
    
    static func requestFor(_ urlString: String, type: RequestType) -> URLRequest? {
        guard let encodingUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: encodingUrlString) else {
            return nil
        }
        var urlRequest: URLRequest?
        switch type {
        case .remote:
            urlRequest = URLRequest(url: url)
        case .bundle(let inDir):
            urlRequest = mapToBundleURL(url, inDir: inDir)
        case .sandbox(let inDir):
            urlRequest = mapToSandboxURL(url, inDir: inDir)
        }
        return urlRequest ?? URLRequest(url: url)
    }
    
    private static func mapToBundleURL(_ url: URL, inDir: String) -> URLRequest? {
        let relativePath = url.pathComponents.dropFirst().joined(separator: "/")
        if let filePath = Bundle.main.path(forResource: relativePath, ofType: nil, inDirectory: inDir) {
            let fileURL = URL(fileURLWithPath: filePath)
            let fileURLWithQuery = fileURL.appendingQueryParameters(url.queryParameters ?? [:])
            let request = URLRequest(url: fileURLWithQuery)
            return request
        }
        print("Bundle中未找到: \(url.absoluteString) 对应的资源文件")
        return nil
    }
    
    private static func mapToSandboxURL(_ url: URL, inDir: String) -> URLRequest? {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = documentPath + "/\(inDir)" + url.path
        if FileManager.default.fileExists(atPath: filePath) {
            let fileURL = URL(fileURLWithPath: filePath)
            let fileURLWithQuery = fileURL.appendingQueryParameters(url.queryParameters ?? [:])
            let request = URLRequest(url: fileURLWithQuery)
            return request
        }
        print("沙盒中未找到: \(url.absoluteString) 对应的本地文件")
        return nil
    }
}

extension URL {
    /// SwifterSwift: Dictionary of the URL's query parameters
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false), let queryItems = components.queryItems else { return nil }
        var items: [String: String] = [:]
        for queryItem in queryItems {
            items[queryItem.name] = queryItem.value
        }
        return items
    }

    /// SwifterSwift: URL with appending query parameters.
    ///
    ///        let url = URL(string: "https://google.com")!
    ///        let param = ["q": "Swifter Swift"]
    ///        url.appendingQueryParameters(params) -> "https://google.com?q=Swifter%20Swift"
    ///
    /// - Parameter parameters: parameters dictionary.
    /// - Returns: URL with appending given query parameters.
    func appendingQueryParameters(_ parameters: [String: String]) -> URL {
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        var items = urlComponents.queryItems ?? []
        items += parameters.map({ URLQueryItem(name: $0, value: $1) })
        urlComponents.queryItems = items
        return urlComponents.url!
    }

    /// SwifterSwift: Append query parameters to URL.
    ///
    ///        var url = URL(string: "https://google.com")!
    ///        let param = ["q": "Swifter Swift"]
    ///        url.appendQueryParameters(params)
    ///        print(url) // prints "https://google.com?q=Swifter%20Swift"
    ///
    /// - Parameter parameters: parameters dictionary.
    mutating func appendQueryParameters(_ parameters: [String: String]) {
        self = appendingQueryParameters(parameters)
    }
}
