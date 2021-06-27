//
//  SearchBarView.swift
//  FlickrImageSearch
//
//  Created by Devesh Bisen on 26/06/21.
//

import UIKit

protocol SearchBarViewDelegate {

    func didTapSearchButton(searchText: String) -> Void

}

final class SearchBarView: UIView {

    // MARK: Constants

    private static let borderWidth: CGFloat = 1.0
    private static let cornerRadius: CGFloat = 8.0
    private static let searchButtonWidth: CGFloat = 50.0
    private static let searchTextVericalInsets: CGFloat = 4.0
    private static let searchTextHorizontalInsets: CGFloat = 8.0
    private static let backroundColor = UIColor.init(displayP3Red: 200/256, green: 220/256, blue: 220/256, alpha: 1)

    // MARK: Properties

    private let searchTextField = UITextField()
    private let searchButton = UIButton()
    public var searchDelegate: SearchBarViewDelegate?

    // MARK: Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupContraints()
        stylizeSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Overriden method

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return searchTextField.becomeFirstResponder()
    }

    // MARK: Private helper methods

    private func setupSubviews() {
        addSubview(searchTextField)
        addSubview(searchButton)

        searchButton.isUserInteractionEnabled = true
        searchButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchImageTapped)))
    }

    private func setupContraints() {
        var constraintsArray: [NSLayoutConstraint] = []

        // Search icon constraints
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        constraintsArray.append(contentsOf: [
            searchButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: SearchBarView.searchButtonWidth),
            searchButton.topAnchor.constraint(equalTo: topAnchor),
            searchButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Search text field constraints
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        constraintsArray.append(contentsOf: [
            searchTextField.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -SearchBarView.searchTextHorizontalInsets),
            searchTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: SearchBarView.searchTextHorizontalInsets),
            searchTextField.topAnchor.constraint(equalTo: topAnchor, constant: SearchBarView.searchTextVericalInsets),
            searchTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -SearchBarView.searchTextVericalInsets),
        ])

        // Activate constraints
        if constraintsArray.count > 0 {
            NSLayoutConstraint.activate(constraintsArray)
        }
    }

    private func stylizeSubviews() {
        backgroundColor = SearchBarView.backroundColor
        layer.cornerRadius = SearchBarView.cornerRadius
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = SearchBarView.borderWidth
        clipsToBounds = true

        searchButton.imageView?.contentMode = .scaleAspectFit
        searchButton.setImage(UIImage(named: "searchIcon"), for: .normal)
    }

    @objc
    private func searchImageTapped() {
        searchDelegate?.didTapSearchButton(searchText: searchTextField.text ?? "")
    }
}
