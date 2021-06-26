//
//  ViewController.swift
//  FlickrImageSearch
//
//  Created by Devesh Bisen on 26/06/21.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: Constants

    private static let leftRightSpacing: CGFloat = 8.0
    private static let titleLabelTopSpacing: CGFloat = 16.0
    private static let verticalViewSpacing: CGFloat = 8.0
    private static let searchBarHeight: CGFloat = 50
    private static let imageViewHeight: CGFloat = 200
    private static let cellReuseIdentifier = "imageCellID"
    private static let defaultBackroundColor = UIColor.init(displayP3Red: 120/256, green: 160/256, blue: 200/256, alpha: 1)
    private static let instructionLabelText = "Enter search keyword and hit enter."
    private static let viewControllerTitleLabelText = "Flickr Image Search"

    // MARK: Private properties

    private var statusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }

    private let instructionLabel = UILabel()
    private let viewControllerTitleLabel = UILabel()

    let searchBar = UISearchBar()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    var fetchedImages: [FlickrImages]?

    // MARK: Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ViewController.defaultBackroundColor

        setupViewHierarchy()
        setupSubviews()
        setupViewConstraints()
    }

    // MARK: Private helper methods

    private func setupViewHierarchy() {
        view.addSubview(viewControllerTitleLabel)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(instructionLabel)
    }

    private func setupSubviews() {
        searchBar.delegate = self

        viewControllerTitleLabel.text = ViewController.viewControllerTitleLabelText
        viewControllerTitleLabel.textColor = UIColor.white
        viewControllerTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        viewControllerTitleLabel.textAlignment = .center
        viewControllerTitleLabel.backgroundColor = UIColor.clear
        viewControllerTitleLabel.sizeToFit()

        instructionLabel.textColor = UIColor.white
        instructionLabel.font = UIFont.boldSystemFont(ofSize: 16)
        instructionLabel.text = ViewController.instructionLabelText
        instructionLabel.sizeToFit()

        collectionView.backgroundColor = ViewController.defaultBackroundColor
        collectionView.delegate   = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16.0, right: 0)
        collectionView.register(FlickrImageCell.self, forCellWithReuseIdentifier: ViewController.cellReuseIdentifier)
    }

    private func setupViewConstraints() {
        var constraintsArray: [NSLayoutConstraint] = []

        // Title label constraints
        viewControllerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        constraintsArray.append(contentsOf: [
            viewControllerTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ViewController.leftRightSpacing),
            viewControllerTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ViewController.leftRightSpacing),
            viewControllerTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: statusBarHeight + ViewController.titleLabelTopSpacing)
        ])

        // Search bar constraints
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        constraintsArray.append(contentsOf: [
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ViewController.leftRightSpacing),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ViewController.leftRightSpacing),
            searchBar.topAnchor.constraint(equalTo: viewControllerTitleLabel.bottomAnchor, constant: ViewController.verticalViewSpacing),
            searchBar.heightAnchor.constraint(equalToConstant: ViewController.searchBarHeight),
        ])

        // Collection view constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        constraintsArray.append(contentsOf: [
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ViewController.leftRightSpacing),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ViewController.leftRightSpacing),
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: ViewController.verticalViewSpacing),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Collection view constraints
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        constraintsArray.append(contentsOf: [
            instructionLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            instructionLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor)
        ])

        // Activate constraints
        if constraintsArray.count > 0 {
            NSLayoutConstraint.activate(constraintsArray)
        }
    }

    private func fetchImages(for searchKey: String) {
        NetworkManager.shared.fetchImagesMetadata(for: searchKey) { [weak self] reponse, error in
            if error != nil {
                return
            }

            guard let strongInstance = self else {
                return
            }

            strongInstance.fetchedImages = reponse?.photos?.photo
            DispatchQueue.main.async {
                strongInstance.collectionView.reloadData()
            }
        }
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let imageCount = fetchedImages?.count ?? 0
        instructionLabel.isHidden = imageCount > 0
        return imageCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: ViewController.cellReuseIdentifier, for: indexPath) as? FlickrImageCell else {
            return FlickrImageCell(frame: .zero)
        }

        if indexPath.row < fetchedImages?.count ?? 0,
           let imageInfo = fetchedImages?[indexPath.row],
           let imageID = imageInfo.id,
           let serverID = imageInfo.server,
           let secretKey = imageInfo.secret {
            NetworkManager.shared.downloadImage(imageID: imageID, serverID: serverID, secretKey: secretKey) { data, error in
                DispatchQueue.main.async {
                    if let data = data {
                        imageCell.image = UIImage(data: data)
                    }
                }
            }
        } else {
            imageCell.image = UIImage(named: "placeholderImage")
        }
        return imageCell
    }

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width - (2 * 8.0), height: ViewController.imageViewHeight)
    }

    // MARK: UISearchBarDelegate

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchImages(for: searchBar.text ?? "")
    }
}
