//
//  SearchBarView.swift
//  Avito_ProfTask
//
//  Created by Egor Anoshin on 11.09.2024.
//

import UIKit

class SearchBarView: UIView {
    
    let searchBar = UISearchBar()
    private let cancelButton = UIButton(type: .system)
    private var searchBarWidthConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear
        

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search images..."
        addSubview(searchBar)

        // Настройка кнопки Cancel
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.alpha = 0
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        addSubview(cancelButton)

        
        searchBarWidthConstraint = searchBar.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor, constant: 80),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            searchBarWidthConstraint,
            searchBar.bottomAnchor.constraint(equalTo: bottomAnchor),

            cancelButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            cancelButton.widthAnchor.constraint(equalToConstant: 60),
            cancelButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    // MARK: - Показ кнопки Cancel с анимацией

    func activateSearch() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.searchBarWidthConstraint.constant = -80
            self.cancelButton.alpha = 1
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Сброс поисковой строки и скрытие Cancel

    @objc func cancelButtonTapped() {
        if let parentVC = parentViewController as? SearchViewController {
            parentVC.cancelSearch()
        }
    }


    func cancelSearch() {
        searchBar.text = ""
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.searchBarWidthConstraint.constant = 0
            self.cancelButton.alpha = 0
            self.layoutIfNeeded()
        }
        
        searchBar.resignFirstResponder()
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while let nextResponder = parentResponder?.next {
            parentResponder = nextResponder
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
