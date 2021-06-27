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

    private(set) var fetchedImages: [FlickrImagesModel]?
    private(set) var fetchedPages: Int = 0
    private let imageCache = NSCache<NSString, UIImage>()

    private static let enableDownsampling = true

    // MARK: Initalizer

    private init() {
        // Approx 50 MB image cache
        imageCache.totalCostLimit = 50_00_0000
        imageCache.countLimit = 100
    }

    // MARK: Public helper methods

    func fetchImagesMetadata(for searchKey: String, pageNumber: Int = 1, completion: @escaping () -> ()) {
        NetworkManager.shared.fetchImagesMetadata(for: searchKey, pageNumber: pageNumber) { [weak self] reponse, error in
            guard error == nil, let photos = reponse?.photos?.photo else {
                return
            }

            if pageNumber == 1 {
                self?.fetchedImages = photos
            } else if self?.fetchedPages == pageNumber - 1 {
                // Append images metadata obtained of subsequent fetched pages.
                self?.fetchedImages?.append(contentsOf: photos)
            }
            self?.fetchedPages = reponse?.photos?.page ?? 0
            completion()
        }
    }

    public func getImage(for imageID: String,
                         serverID: String,
                         secretKey: String,
                         imageSize: CGSize,
                         completion: @escaping (UIImage?) -> (Void)) {
        if let image = imageCache.object(forKey: imageID as NSString) {
            completion(image)
            print("Image fetched from cache")
            return
        }

        NetworkManager.shared.downloadImage(
            imageID: imageID,
            serverID: serverID,
            secretKey: secretKey) { [weak self] localURL, error in
            guard error == nil,
                  let localURL = localURL,
                  let downloadedImage = DataManager.imageModel(for: localURL, imageSize: imageSize) else {
                completion(UIImage(named: "placeholderImage"))
                return
            }

            print("Image successfully fetched from network")
            self?.imageCache.setObject(downloadedImage, forKey: imageID as NSString)
            completion(downloadedImage)
        }
    }

    // MARK: Private helper methods

    private static func imageModel(for localURL: URL, imageSize: CGSize) -> UIImage? {
        guard !DataManager.enableDownsampling else {
            return ImageRenderUtils.downsample(imageAt: localURL, to: imageSize)
        }

        do {
            return UIImage(data: try Data(contentsOf: localURL))
        } catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
}
