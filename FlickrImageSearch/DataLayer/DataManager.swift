//
//  DataManager.swift
//  FlickrImageSearch
//
//  Created by Devesh Bisen on 26/06/21.
//

import Foundation

final class DataManager {

    // MARK: Singleton accessor

    static let shared = DataManager()

    // MARK: Readonly property

    public private(set) var fetchedImages: [FlickrImagesModel]?

    // MARK: Initalizer

    private init() {
        // NO-OP
    }

    // MARK: Public helper methods

    func fetchImages(for searchKey: String, completion: @escaping () -> ()) {
        NetworkManager.shared.fetchImagesMetadata(for: searchKey) { [weak self] reponse, error in
            guard error == nil, let photos = reponse?.photos?.photo else {
                return
            }

            self?.fetchedImages = photos
            completion()
        }
    }
}
