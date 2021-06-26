//
//  NetworkManager.swift
//  FlickrImageSearch
//
//  Created by Devesh Bisen on 26/06/21.
//

import Foundation

final class NetworkManager {

    // MARK: Singleton accessor

    static let shared = NetworkManager()

    // MARK: Constants

    private static let publicAPIKey = "3737be8cb5f107dcfe786aaa389fc889"

    // MARK: Initalizer

    private init() {
        // NO-OP
    }

    // MARK: Public helper methods

    /**
     API doc for query format - https://www.flickr.com/services/api/explore/flickr.photos.search
     */
    public func fetchImagesMetadata(for searchKey: String, completion: @escaping (FlickrImagesSearchResultModel?, Error?) -> (Void)) {
        guard let requestUrl = NetworkManager.url(for: searchKey) else {
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
                              completion: @escaping (Data?, Error?) -> (Void)) {
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

            do {
                let data = try Data(contentsOf: localURL)
                completion(data, nil)
            } catch let error {
                completion(nil, error)
            }
        }.resume()
    }

    // MARK: Private helper method

    private static func url(for searchKey: String) -> URL? {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "www.flickr.com"
        component.path = "/services/rest/"
        component.queryItems = [
            URLQueryItem(name: "method", value: "flickr.photos.search"),
            URLQueryItem(name: "api_key", value: NetworkManager.publicAPIKey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1"),
            URLQueryItem(name: "text", value: searchKey)
        ]
        return component.url
    }
}
