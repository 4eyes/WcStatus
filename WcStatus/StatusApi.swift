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
    let BASE_URL = "http://192.168.1.252"
    
    func fetchStatus(success: (Status) -> Void, _ failure: (NSError -> Void)?){
        if(!running){
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            configuration.timeoutIntervalForRequest = 5
            configuration.timeoutIntervalForResource = 10
        
            let session = NSURLSession(configuration: configuration)
            let url = NSURL(string: BASE_URL)
            let task = session.dataTaskWithURL(url!) { data, response, error in
                running = false
                if error != nil {
                    if error?.code ==  NSURLErrorTimedOut {
                        NSLog("Timeout")
                        failure?(error!)
                    } else {
                        NSLog("Error")
                        failure?(error!)
                    }
                } else {
                    // then check the response code
                    if let httpResponse = response as? NSHTTPURLResponse {
                        switch httpResponse.statusCode {
                            case 200: // all good!
                                if let status = self.statusFromJSONData(data!){
                                    success(status)
                                }
                            case 401: // unauthorized
                                NSLog("status api returned an 'unauthorized' response.")
                            default:
                                NSLog("status api returned response: %d %@", httpResponse.statusCode, NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode))
                        }
                    }
                }
            }
            running = true
            task.resume()
        }
    }
    
    func statusFromJSONData(data: NSData) -> Status? {
        typealias JSONDict = [String:AnyObject]
        let json : JSONDict
        
        do {
            json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! JSONDict
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