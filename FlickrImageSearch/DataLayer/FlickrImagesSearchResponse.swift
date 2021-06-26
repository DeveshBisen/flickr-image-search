//
//  ImageSearchResponse.swift
//  FlickrImageSearch
//
//  Created by Devesh Bisen on 26/06/21.
//

import Foundation

struct FlickrImagesSearchResponse: Codable {

    var photos: FlickrImagesData?
    var stat: String?
}

struct FlickrImagesData: Codable {

    var page: Int?
    var pages: Int?
    var perpage: Int?
    var total: Int?
    var photo: [FlickrImages]?
}

struct FlickrImages: Codable {

    var id: String?
    var owner: String?
    var secret: String?
    var server: String?
    var farm: Int?
    var title: String?
    var ispublic: Int?
    var isfriend: Int?
    var isfamily: Int?
}
