//
//  ViewController.swift
//  FlickrImageSearch
//
//  Created by Devesh Bisen on 26/06/21.
//

import UIKit

class ViewController: UIViewController, SearchBarViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: Constants

    private static let imageViewHeight: CGFloat = 200
    private static let searchBarViewHeight: CGFloat = 40

    private static let leftRightSpacing: CGFloat = 8.0
    private static let verticalViewSpacing: CGFloat = 8.0
    private static let titleLabelTopSpacing: CGFloat = 16.0
    private static let minimumInteritemSpacing: CGFloat = 4.0

    private static let cellReuseIdentifier = "imageCellReuseID"
    private static let viewControllerTitleLabelText = "Flickr Image Search"
    private static let searchImageNotFoundText = "Photos for entered search keyword not found"

    private static let defaultBackroundColor = UIColor.init(displayP3Red: 120/256, green: 160/256, blue: 200/256, alpha: 1)

    // MARK: Private properties

    private var statusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }

    private let imageNotFoundLabel = UILabel()
    private let viewControllerTitleLabel = UILabel()

    let searchBarView = SearchBarView()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    // MARK: Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ViewController.defaultBackroundColor

        setupViewHierarchy()
        setupSubviews()
        setupViewConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBarView.becomeFirstResponder()
    }

    // MARK: Private helper methods

    private func setupViewHierarchy() {
        view.addSubview(viewControllerTitleLabel)
        view.addSubview(searchBarView)
        view.addSubview(collectionView)
        view.addSubview(imageNotFoundLabel)
    }

    private func setupSubviews() {
        searchBarView.searchDelegate = self

        viewControllerTitleLabel.text = ViewController.viewControllerTitleLabelText
        viewControllerTitleLabel.textColor = UIColor.white
        viewControllerTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        viewControllerTitleLabel.textAlignment = .center
        viewControllerTitleLabel.backgroundColor = UIColor.clear
        viewControllerTitleLabel.sizeToFit()

        imageNotFoundLabel.textColor = UIColor.white
        imageNotFoundLabel.font = UIFont.boldSystemFont(ofSize: 16)
        imageNotFoundLabel.text = ViewController.searchImageNotFoundText
        imageNotFoundLabel.sizeToFit()
        imageNotFoundLabel.isHidden = true

        collectionView.backgroundColor = ViewController.defaultBackroundColor
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16.0, right: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
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
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        constraintsArray.append(contentsOf: [
            searchBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ViewController.leftRightSpacing),
            searchBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ViewController.leftRightSpacing),
            searchBarView.topAnchor.constraint(equalTo: viewControllerTitleLabel.bottomAnchor, constant: ViewController.verticalViewSpacing),
            searchBarView.heightAnchor.constraint(equalToConstant: ViewController.searchBarViewHeight),
        ])

        // Collection view constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        constraintsArray.append(contentsOf: [
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ViewController.leftRightSpacing),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ViewController.leftRightSpacing),
            collectionView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor, constant: ViewController.verticalViewSpacing),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Search instruction label constraints
        imageNotFoundLabel.translatesAutoresizingMaskIntoConstraints = false
        constraintsArray.append(contentsOf: [
            imageNotFoundLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            imageNotFoundLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor)
        ])

        // Activate constraints
        if constraintsArray.count > 0 {
            NSLayoutConstraint.activate(constraintsArray)
        }
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataManager.shared.fetchedImages?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reusableCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ViewController.cellReuseIdentifier,
            for: indexPath) as? FlickrImageCell
        let imageCell = reusableCell ?? FlickrImageCell(frame: .zero)

        if indexPath.row < DataManager.shared.fetchedImages?.count ?? 0,
           let imageInfo = DataManager.shared.fetchedImages?[indexPath.row],
           let imageID = imageInfo.id,
           let serverID = imageInfo.server,
           let secretKey = imageInfo.secret {
            DataManager.shared.getImage(for: imageID, serverID: serverID, secretKey: secretKey) { image in
                DispatchQueue.main.async {
                    imageCell.image = image
                }
            }
        } else {
            imageCell.image = UIImage(named: "placeholderImage")
        }
        return imageCell
    }

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ViewController.minimumInteritemSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: collectionView.frame.size.width - (2 * ViewController.leftRightSpacing),
            height: ViewController.imageViewHeight)
    }

    // MARK: SearchBarViewDelegate

    func didTapSearchIcon(searchText: String) {
        if !searchText.isEmpty {
            DataManager.shared.fetchImagesMetadata(for: searchText) { [weak self] in
                let weakSelf = self
                DispatchQueue.main.async { [weakSelf] in
                    weakSelf?.collectionView.reloadData()

                    // Scroll to top after collection view reload
                    if (weakSelf?.collectionView.numberOfItems(inSection: 0) ?? 0) > 0 {
                        weakSelf?.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                        weakSelf?.imageNotFoundLabel.isHidden = true
                    } else {
                        weakSelf?.imageNotFoundLabel.isHidden = false
                    }
                }
            }
        }
    }
}
