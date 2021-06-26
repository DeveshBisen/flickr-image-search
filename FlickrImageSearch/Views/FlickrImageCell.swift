//
//  FlickrImageCell.swift
//  FlickrImageSearch
//
//  Created by Devesh Bisen on 26/06/21.
//

import UIKit

class FlickrImageCell: UICollectionViewCell {

    // MARK: Constants

    private static let cornerRadius: CGFloat = 12.0
    private static let backroundColor = UIColor.init(displayP3Red: 160/256, green: 180/256, blue: 220/256, alpha: 1)

    // MARK: Properties

    let imageView = UIImageView()

    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    // MARK: Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAndStylizeSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Private helper method

    private func setupAndStylizeSubviews() {
        layer.cornerRadius = FlickrImageCell.cornerRadius
        imageView.layer.cornerRadius = FlickrImageCell.cornerRadius

        addSubview(imageView)
        imageView.backgroundColor = FlickrImageCell.backroundColor
        setupConstraints()
    }

    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
