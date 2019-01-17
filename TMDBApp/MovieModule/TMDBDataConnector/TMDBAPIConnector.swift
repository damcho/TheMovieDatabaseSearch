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

//let APIReadAccessToken:String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkZjJmZmZkNWEwMDg0YTU4YmRlOGJlOTllZmQ1NGVjMCIsInN1YiI6IjViZTJkYWRkMGUwYTI2MTRiNjAxMmNhZSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.dBKb9rKru20L3B5E5XM06xsWNMLED2fZynIZd_pH9-8"

class TMDBAPIConnector :DataConnector{
    
    static let shared = TMDBAPIConnector()
    private let host = "api.themoviedb.org"
    private let scheme = "https"

    private let APIKey:String = "df2fffd5a0084a58bde8be99efd54ec0"
    private let imageBaseURL:String = "https://image.tmdb.org/t/p/w300"
    private var isFetchingMovies = false

    
    func performRequest(url: URL, completion: @escaping (Data?, Error?) -> ()){
        AF.request(url, method: .get)
            .validate()
            .responseData{ response in
                guard response.result.isSuccess else {
                    
                    if let data = response.data , let jsonError = try? JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary  {
                        let error = NSError(domain: "", code:jsonError["status_code"] as! Int, userInfo: [NSLocalizedDescriptionKey:jsonError["status_message"]!])
                        completion(nil, error)
                    } else {
                        completion(nil, response.error)
                    }
                    return
                }
                completion(response.data, nil)
        }
    }
    
    func createURL(searchPath:String, queryItems:[URLQueryItem]?) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = searchPath
        urlComponents.queryItems = [URLQueryItem(name: "api_key", value: APIKey)]
        if queryItems != nil {
            urlComponents.queryItems!.append(contentsOf: queryItems!)
        }

        guard let url = urlComponents.url else { return nil }
        return url
    }
    
    func getMovies(searchParams: SearchObject, completion: @escaping (moviesContainerCompletionHandler)) -> () {
        guard let url = createURL(searchPath: searchParams.searchMoviesUrlPath() , queryItems:searchParams.searchMoviesQueryItems() ) else {
            return
        }
        
        print(url)
        
        let completionHandler = {[unowned self] (data:Data?, error:Error?) in
            self.isFetchingMovies = false
            if data != nil {
                let json = try? JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                guard let jsonDictionary = json, let moviesContainer = MoviesContainer(data:jsonDictionary) else {
                    completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:"Malformed data received from getMovies service"]))
                    return
                }
                completion(moviesContainer, nil)
                
            } else {
                completion(nil, error)
            }
        }
        
        if !isFetchingMovies {
            isFetchingMovies = true
            self.performRequest(url: url, completion: completionHandler)
        }
    }
    
    
    func getMovieDetail(searchParams: SearchObject, completion: @escaping movieDetailCompletionHandler) {
        guard let url = createURL(searchPath: searchParams.movieDetailUrlPath(), queryItems:searchParams.movieDetailQueryItems() ) else {
            return
        }
        
        let completionHandler = { (data:Data?, error:Error?) in
            if data != nil {
                let json = try? JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                guard let jsonDictionary = json ,let movie = Movie(data: jsonDictionary) else {
                    completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:"Malformed data received from getMovieDetail service"]))
                    return
                }
                completion(movie, nil)
                
            } else {
                completion(nil, error)
            }
        }
        
        self.performRequest(url: url, completion: completionHandler)
    }
    
    func createImageURL(urlString:String) -> URL? {
        if let urlComponents = URLComponents(string: imageBaseURL + urlString) {
            guard let url = urlComponents.url else { return nil }
            return url
        }
        return nil
    }
    
    func loadImage(from url: String, completion: @escaping (UIImage?) -> ()) {
        guard let url = createImageURL(urlString: url) else {
            return
        }
        let completionHandler = { (data:Data?, error:Error?) in
            if error == nil {
                let image = UIImage(data:data!)
                completion(image)
            }
        }
        self.performRequest(url: url, completion: completionHandler)
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

