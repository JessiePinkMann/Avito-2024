//
//  PaginationFooterView.swift
//  Avito_ProfTask
//
//  Created by Egor Anoshin on 12.09.2024.
//

import Foundation

import UIKit

class PaginationFooterView: UICollectionReusableView {

    static let reuseIdentifier = "PaginationFooterView"

    let previousButton = UIButton(type: .system)
    let nextButton = UIButton(type: .system)
    let pageLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        previousButton.setTitle("Previous", for: .normal)
        nextButton.setTitle("Next", for: .normal)
        pageLabel.text = "Page 1"
        pageLabel.textAlignment = .center

        let stackView = UIStackView(arrangedSubviews: [previousButton, pageLabel, nextButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
