//
//  ViewController.swift
//  FlickrImageSearch
//
//  Created by Devesh Bisen on 26/06/21.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: Constants

    private static let searchBarHeight: CGFloat = 50
    private static let imageViewHeight: CGFloat = 200
    private static let leftRightSpacing: CGFloat = 8.0
    private static let verticalViewSpacing: CGFloat = 8.0
    private static let titleLabelTopSpacing: CGFloat = 16.0
    private static let minimumInteritemSpacing: CGFloat = 4.0

    private static let cellReuseIdentifier = "imageCellID"
    private static let viewControllerTitleLabelText = "Flickr Image Search"
    private static let searchInstructionLabelText = "Enter search keyword and hit enter."

    private static let defaultBackroundColor = UIColor.init(displayP3Red: 120/256, green: 160/256, blue: 200/256, alpha: 1)

    // MARK: Private properties

    private var statusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }

    private let searchInstructionLabel = UILabel()
    private let viewControllerTitleLabel = UILabel()

    let searchBar = UISearchBar()
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
        searchBar.becomeFirstResponder()
    }

    // MARK: Private helper methods

    private func setupViewHierarchy() {
        view.addSubview(viewControllerTitleLabel)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(searchInstructionLabel)
    }

    private func setupSubviews() {
        searchBar.delegate = self

        viewControllerTitleLabel.text = ViewController.viewControllerTitleLabelText
        viewControllerTitleLabel.textColor = UIColor.white
        viewControllerTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        viewControllerTitleLabel.textAlignment = .center
        viewControllerTitleLabel.backgroundColor = UIColor.clear
        viewControllerTitleLabel.sizeToFit()

        searchInstructionLabel.textColor = UIColor.white
        searchInstructionLabel.font = UIFont.boldSystemFont(ofSize: 16)
        searchInstructionLabel.text = ViewController.searchInstructionLabelText
        searchInstructionLabel.sizeToFit()

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

        // Search instruction label constraints
        searchInstructionLabel.translatesAutoresizingMaskIntoConstraints = false
        constraintsArray.append(contentsOf: [
            searchInstructionLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            searchInstructionLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor)
        ])

        // Activate constraints
        if constraintsArray.count > 0 {
            NSLayoutConstraint.activate(constraintsArray)
        }
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let imageCount = DataManager.shared.fetchedImages?.count ?? 0
        searchInstructionLabel.isHidden = imageCount > 0
        return imageCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let imageCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ViewController.cellReuseIdentifier,
                for: indexPath) as? FlickrImageCell else {
            return FlickrImageCell(frame: .zero)
        }

        if indexPath.row < DataManager.shared.fetchedImages?.count ?? 0,
           let imageInfo = DataManager.shared.fetchedImages?[indexPath.row],
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

    // MARK: UISearchBarDelegate

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DataManager.shared.fetchImages(for: searchBar.text ?? "") { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
}
