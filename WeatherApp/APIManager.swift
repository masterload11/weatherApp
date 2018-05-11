//
//  APIManager.swift
//  WeatherApp
//
//  Created by Владислав Варфоломеев on 19.04.2018.
//  Copyright © 2018 Владислав Варфоломеев. All rights reserved.
//

import Foundation
//Здесь интерфейс и его дефолтная реализация

typealias JSONTask = URLSessionDataTask
typealias JSONCompletionHandler =  ([String: AnyObject]?, HTTPURLResponse?, Error?) -> Void

protocol JSONDecodable {
    init?(JSON: [String: AnyObject])
}


protocol FinalURLPoint {
    var baseURL: URL { get }
    var path: String { get }
    var request: URLRequest { get }
}

enum APIResult<T> {
    case Success(T)
    case Failure(Error)
}

protocol APIManager
{
    var sessionConfiguration: URLSessionConfiguration { get }
    var session: URLSession { get }
    
    func JSONTaskWith(request: URLRequest, completionHandler: @escaping JSONCompletionHandler) -> JSONTask
    func fetch<T: JSONDecodable>(request: URLRequest, parse: @escaping ([String:AnyObject]) -> T?, completionHandler: @escaping (APIResult<T>) -> Void)
}


extension APIManager {
    //1 метод
    func JSONTaskWith(request: URLRequest, completionHandler: @escaping JSONCompletionHandler) -> JSONTask
    {
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard let HTTPResponse = response as? HTTPURLResponse else {
                //Пользовательский словарь ошибки
                let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Missing HTTP Responce", comment: "")]
                let error = NSError(domain: VVVNetworkingErrorDomain, code: 100, userInfo: userInfo)
                
                completionHandler(nil, nil, error)
                return
            }
            if data == nil {
                if let error = error { completionHandler(nil, HTTPResponse, error) }
            } else {
              //всё получилось
                switch HTTPResponse.statusCode {
                case 200:
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                        completionHandler(json, HTTPResponse, nil)
                    } catch let error as NSError {
                        completionHandler(nil, HTTPResponse, error)
                    }
                default:
                    print("We have got responce status: \(HTTPResponse.statusCode)")
                }
            }
        }
        return dataTask
    }
    
    //2 метод
   
    func fetch<T>(request: URLRequest, parse: @escaping ([String:AnyObject]) -> T?, completionHandler: @escaping (APIResult<T>) -> Void)
    {
        let dataTask = JSONTaskWith(request: request) { (json, response, error) in
            DispatchQueue.main.async(execute: {
                guard let json = json else {
                    if let error = error {
                        completionHandler(.Failure(error))
                    }
                    return
                }
                
                //если получается запарсить, то Success, нет - ошибка и Failure
                if let value = parse(json) {
                    completionHandler(.Success(value))
                } else {
                    let error = NSError(domain: VVVNetworkingErrorDomain, code: 200, userInfo: nil)
                    completionHandler(.Failure(error))
                }
                
            })
        }
        dataTask.resume() 
    }
}
