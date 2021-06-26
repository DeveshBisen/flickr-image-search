//
//  DataManager.swift
//  FlickrImageSearch
//
//  Created by Devesh Bisen on 26/06/21.
//

import Foundation
import UIKit

final class DataManager {

    // MARK: Singleton accessor

    static let shared = DataManager()

    // MARK: Properties

    public private(set) var fetchedImages: [FlickrImagesModel]?
    private let imageCache = NSCache<NSString, UIImage>()

    // MARK: Initalizer

    private init() {
        // Approx 30 MB image cache
        imageCache.totalCostLimit = 30_000_000
    }

    // MARK: Public helper methods

    func fetchImagesMetadata(for searchKey: String, completion: @escaping () -> ()) {
        NetworkManager.shared.fetchImagesMetadata(for: searchKey) { [weak self] reponse, error in
            guard error == nil, let photos = reponse?.photos?.photo else {
                return
            }

            self?.fetchedImages = photos
            completion()
        }
    }

    public func getImage(for imageID: String,
                         serverID: String,
                         secretKey: String,
                         completion: @escaping (UIImage?) -> (Void)) {
        if let image = imageCache.object(forKey: imageID as NSString) {
            completion(image)
            print("Image fetched from cache")
            return
        }

        NetworkManager.shared.downloadImage(
            imageID: imageID,
            serverID: serverID,
            secretKey: secretKey) { [weak self] data, error in
            guard let data = data,
                  let downloadedImage = UIImage(data: data),
                  error == nil else {
                completion(UIImage(named: "placeholderImage"))
                return
            }

            print("Image successfully fetched from network")
            self?.imageCache.setObject(downloadedImage, forKey: imageID as NSString)
            completion(downloadedImage)
        }
    }
}
