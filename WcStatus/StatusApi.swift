//
//  StatusApi.swift
//  WcStatus
//
//  Created by Michel Georgy on 04/04/16.
//  Copyright © 2016 Michel Georgy. All rights reserved.
//

import Foundation

struct Status {
    var occupied: Int
    var time: Int
}

var running = false

class StatusApi {
    let BASE_URL = "http://192.168.4.253"
    
    func fetchStatus(success: @escaping (Status) -> Void, failure: ((Error) -> Void)?){
        if(!running){
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 5
            configuration.timeoutIntervalForResource = 10
        
            let session = URLSession(configuration: configuration)
            let url = URL(string: BASE_URL)
            let task = session.dataTask(with: url!) { data, response, error in
                running = false
                if error != nil {
                    if error?._code ==  NSURLErrorTimedOut {
                        NSLog("Timeout")
                        failure?(error!)
                    } else {
                        NSLog("Error")
                        failure?(error!)
                    }
                } else {
                    // then check the response code
                    if let httpResponse = response as? HTTPURLResponse {
                        switch httpResponse.statusCode {
                            case 200: // all good!
                            if let status = self.statusFromJSONData(data: data!){
                                    success(status)
                                }
                            case 401: // unauthorized
                                NSLog("status api returned an 'unauthorized' response.")
                            default:
                            NSLog("status api returned response: %d %@", httpResponse.statusCode, HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
                        }
                    }
                }
            }
            running = true
            task.resume()
        }
    }
    
    func statusFromJSONData(data: Data) -> Status? {
        typealias JSONDict = [String:AnyObject]
        let json : JSONDict
        
        do {
            json = try JSONSerialization.jsonObject(with: data, options: []) as! JSONDict
        } catch {
            NSLog("JSON parsing failed: \(error)")
            return nil
        }
        
        let status = Status(
            occupied: json["occupied"] as! Int,
            time: json["time"] as! Int
        )
        
        return status
    }
}
