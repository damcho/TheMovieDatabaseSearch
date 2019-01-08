//
//  TMDBAPIConnector.swift
//  TMDBApp
//
//  Created by Damian Modernell on 07/11/2018.
//  Copyright © 2018 Damian Modernell. All rights reserved.
//

import Foundation
import SystemConfiguration
import Alamofire

let APIKey:String = "df2fffd5a0084a58bde8be99efd54ec0"

let imageBaseURL:String = "https://image.tmdb.org/t/p/w500"

//let APIReadAccessToken:String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkZjJmZmZkNWEwMDg0YTU4YmRlOGJlOTllZmQ1NGVjMCIsInN1YiI6IjViZTJkYWRkMGUwYTI2MTRiNjAxMmNhZSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.dBKb9rKru20L3B5E5XM06xsWNMLED2fZynIZd_pH9-8"

enum StatusCode :Int{
    case SUCCESS = 200
}

class TMDBAPIConnector :DataConnector{
    
    
    static let shared = TMDBAPIConnector()
    
    let baseURL = "https://api.themoviedb.org/3"
    let movie = "/movie"
    var searchParams: SearchObject?
    
    
    func getMovies(searchParams: SearchObject, completion: @escaping (completionHandler)) -> () {
        self.searchParams = searchParams
        if var urlComponents = URLComponents(string: baseURL + movie + searchParams.urlString()) {
            urlComponents.query = "api_key=\(APIKey)&page=\(searchParams.page)"
            guard let url = urlComponents.url else { return }
            self.requestMedia(url: url, completion: completion)
        }
    }
    
    func requestMedia(url: URL, completion: @escaping (completionHandler)) -> (){
    
        AF.request(url, method: .get)
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:"Resource not found"]))
                    return
                }
                guard let dataDictionary = response.result.value as? NSDictionary else {
                    completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:"Malformed data received from fetchAllRooms service"]))
                    return
                }
                
                guard let moviesPage = MoviesContainer(data:dataDictionary) else {
                      completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:"Malformed data received from fetchAllRooms service"]))
                    return
                }
               
                completion(moviesPage, nil)
        }
    }

    func loadImage(from url: String, completion: @escaping (UIImage?) -> ()) {
        
        if let urlComponents = URLComponents(string: imageBaseURL + url) {
            guard let url = urlComponents.url else { return }
            
            AF.request(url, method: .get)
                .validate()
                .responseData(completionHandler: { (responseData) in
                    if responseData.result.isSuccess {
                        
                        guard responseData.data != nil, let image = UIImage(data:responseData.data!) else {
                            completion(nil)
                            return
                        }
                        completion(image)
                        
                    } else {
                        completion(nil)
                    }
                })
        }
    }
}



public class Reachability {
    
    static let reachabilityManager = Alamofire.NetworkReachabilityManager (host: "www.apple.com")
    static func listenForReachability() {
        reachabilityManager!.startListening()
    }
    
    static func isConnectedToNetwork() -> Bool{
        return reachabilityManager!.isReachable
    }
}

