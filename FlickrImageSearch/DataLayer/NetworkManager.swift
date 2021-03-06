//
//  NetworkManager.swift
//  FlickrImageSearch
//
//  Created by Devesh Bisen on 26/06/21.
//

import Foundation
import UIKit

final class NetworkManager {

    // MARK: Singleton accessor

    static let shared = NetworkManager()

    // MARK: Constants

    /**
     Since this is public API keys, it's gets exprired maybe less then 12 hours.
     We need to use latest key for accessing Flickr API.
     */
    private static let publicAPIKey = "8c65eced899e097d79e6dc3f134dfe5d"

    public static let imagePagingSize = 30

    // MARK: Initalizer

    private init() {
        // NO-OP
    }

    // MARK: Public helper methods

    /**
     API doc for query format - https://www.flickr.com/services/api/explore/flickr.photos.search
     */
    public func fetchImagesMetadata(for searchKey: String,
                                    pageNumber: Int,
                                    completion: @escaping (FlickrImagesSearchResultModel?, Error?) -> (Void)) {
        guard let requestUrl = NetworkManager.url(for: searchKey, pageNumber: pageNumber) else {
            completion(nil, NSError())
            return
        }

        URLSession.shared.dataTask(with: URLRequest(url: requestUrl)) { data, urlResponse, error in
            guard error == nil,
                  let httpResponse = urlResponse as? HTTPURLResponse,
                  (httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299),
                  let data = data else {
                completion(nil, error)
                return
            }

            do {
                let response = try JSONDecoder().decode(FlickrImagesSearchResultModel.self, from: data)
                completion(response, nil)
            } catch let error {
                completion(nil, error)
            }
        }.resume()
    }

    /**
     URL format - https://live.staticflickr.com/{serverID}/{id}_{secret}.jpg
     API Doc - https://www.flickr.com/services/api/misc.urls.html
     */
    public func downloadImage(imageID: String,
                              serverID: String,
                              secretKey: String,
                              completion: @escaping (URL?, Error?) -> (Void)) {
        guard let imageURL = URL(string: "https://live.staticflickr.com/\(serverID)/\(imageID)_\(secretKey).jpg") else {
            completion(nil, NSError())
            return
        }

        URLSession.shared.downloadTask(with: imageURL) { localURL, response, error in
            guard error == nil,
                  let httpResponse = response as? HTTPURLResponse,
                  (httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299),
                  let localURL = localURL else {
                completion(nil, error)
                return
            }

            completion(localURL, nil)
        }.resume()
    }

    // MARK: Private helper method

    private static func url(for searchKey: String, pageNumber: Int) -> URL? {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "www.flickr.com"
        component.path = "/services/rest/"
        component.queryItems = [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1"),
            URLQueryItem(name: "method", value: "flickr.photos.search"),
            URLQueryItem(name: "sort", value: "relevance"),
            URLQueryItem(name: "api_key", value: NetworkManager.publicAPIKey),
            URLQueryItem(name: "text", value: searchKey),
            URLQueryItem(name: "per_page", value: "\(NetworkManager.imagePagingSize)"),
            URLQueryItem(name: "page", value: "\(pageNumber)")
        ]
        return component.url
    }
}
