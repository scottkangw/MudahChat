//
//  Request.swift
//  MudahChat
//
//  Created by Scott.L on 08/06/2022.
//

import Foundation
import UIKit

struct RequestType {
    static let  POST = "POST"
    static let  GET = "GET"
}

class APIRequest: NSObject {
    
    func dataRequest(requestModel: MessageRequestModel, completion: @escaping(MessageResponseModel?)->()) {
        let urlToRequest = "https://reqres.in/api/users" // Your API url
        
        let url = URL(string: urlToRequest)!
        let session4 = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = RequestType.POST
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let paramString = "message=\(requestModel.message ?? "")"
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        let task = session4.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let _: Data = data, let _: URLResponse = response, error == nil else {
                print("*****error")
                return
            }
            guard let result = try? JSONDecoder().decode(MessageResponseModel.self, from: data!)
            else {
                completion(nil)
                return
            }
            completion(result)
            print("****Data: \(result)")
        }
        task.resume()
    }
}
