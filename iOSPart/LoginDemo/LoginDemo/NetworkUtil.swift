//
//  NetworkUtil.swift
//  LoginDemo
//
//  Created by Mon on 31/08/2017.
//  Copyright © 2017 monwingyeung. All rights reserved.
//

import UIKit

class NetworkUtil: NSObject {
    
    class func getData(from url: URL, headers: [String: String]?, params: [String: String]?, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        
        let body: String? = {
            guard let _ = params else { return nil }
            
            let pairs = params!.map({ (key, value) -> String in
                return "\(key)=\(value)"
            })
            return pairs.joined(separator: "&")
        }()
        let theURL = url.appendingPathComponent(body ?? "")
        
        let request: URLRequest = {
            var request = URLRequest(url: theURL)
            request.httpMethod = "GET"
            
            if let headers = headers {
                headers.forEach({ (key, value) in
                    request.setValue(value, forHTTPHeaderField: key)
                })
            }
            
            return request
        }()
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            completion(data, response, error)
        }
        task.resume()
    }
    
    class func postEncodedData(to url: URL, params: [String: String], completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        let bodyStrings = params.map { (key, value) -> String in
            return "\(key)=\(value)"
        }
        
        let bodyString = bodyStrings.joined(separator: "&")
        
        let request: URLRequest = {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = bodyString.data(using: .utf8)
            return request
        }()
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            completion(data, response, error)
        }
        task.resume()
    }
    
    class func postJSONData(to url: URL, headers: [String: String]?, params: [String: String]?, completion: @escaping (Data? ,URLResponse?, Error?) -> ()) {
        let request: URLRequest = {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            if let headers = headers {
                headers.forEach({ (key, value) in
                    request.setValue(value, forHTTPHeaderField: key)
                })
            }
            
            if let params = params {
                request.httpBody = try! JSONSerialization.data(withJSONObject: params)
            }
            return request
        }()
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            completion(data, response, error)
        }
        task.resume()
    }
}
