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

    // MARK: Private properties

    private var statusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }

    private lazy var viewControllerTitleLabel: UILabel? = {
        let label = UILabel()
        label.text = "Flickr Image Search"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        label.sizeToFit()
        return label
    }()

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

    // MARK: Private helper methods

    private func setupViewHierarchy() {
        if let viewControllerTitleLabel = viewControllerTitleLabel {
            view.addSubview(viewControllerTitleLabel)
        }
        view.addSubview(searchBar)
        view.addSubview(collectionView)
    }

    private func setupSubviews() {
        searchBar.delegate = self

        collectionView.backgroundColor = ViewController.defaultBackroundColor
        collectionView.delegate   = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16.0, right: 0)
        collectionView.register(FlickrImageCell.self, forCellWithReuseIdentifier: ViewController.cellReuseIdentifier)
    }

    private func setupViewConstraints() {
        var constraintsArray: [NSLayoutConstraint] = []

        // Title label constraints
        if let viewControllerTitleLabel = viewControllerTitleLabel {
            viewControllerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            constraintsArray.append(contentsOf: [
                viewControllerTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ViewController.leftRightSpacing),
                viewControllerTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ViewController.leftRightSpacing),
                viewControllerTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: statusBarHeight + ViewController.titleLabelTopSpacing)
            ])
        }

        // Search bar constraints
        if let searchBarTopView = viewControllerTitleLabel ?? view {
            searchBar.translatesAutoresizingMaskIntoConstraints = false
            constraintsArray.append(contentsOf: [
                searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ViewController.leftRightSpacing),
                searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ViewController.leftRightSpacing),
                searchBar.topAnchor.constraint(equalTo: searchBarTopView.bottomAnchor, constant: ViewController.verticalViewSpacing),
                searchBar.heightAnchor.constraint(equalToConstant: ViewController.searchBarHeight),
            ])
        }

        // Collection view constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        constraintsArray.append(contentsOf: [
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ViewController.leftRightSpacing),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ViewController.leftRightSpacing),
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: ViewController.verticalViewSpacing),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Activate constraints
        if constraintsArray.count > 0 {
            NSLayoutConstraint.activate(constraintsArray)
        }
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: ViewController.cellReuseIdentifier, for: indexPath) as? FlickrImageCell else {
            return FlickrImageCell(frame: .zero)
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
        let searchedText: String = searchBar.text ?? ""
        print(searchedText)
    }
}
