//
//  SearchViewController+UI.swift
//  Avito_ProfTask
//
//  Created by Egor Anoshin on 11.09.2024.
//

import Foundation
import UIKit

extension SearchViewController {
    
    func setupSearchBarView() {
        searchBarView = SearchBarView()
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        searchBarView.searchBar.delegate = self
        view.addSubview(searchBarView)
        
        NSLayoutConstraint.activate([
            searchBarView.topAnchor.constraint(equalTo: view.topAnchor),
            searchBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBarView.heightAnchor.constraint(equalToConstant: 160)
        ])
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5

        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 50)
        layout.footerReferenceSize = CGSize(width: view.frame.width, height: 50)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = collectionManager
        collectionView.delegate = collectionManager
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    
    func setupLoadingStateView() {
        loadingStateView = LoadingStateView()
        loadingStateView.translatesAutoresizingMaskIntoConstraints = false
        loadingStateView.isHidden = true
        view.addSubview(loadingStateView)
        
        NSLayoutConstraint.activate([
            loadingStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func setupSuggestionsTableView() {
        suggestionsTableView = UITableView()
        suggestionsTableView.translatesAutoresizingMaskIntoConstraints = false
        suggestionsTableView.isHidden = true
        suggestionsTableView.backgroundColor = UIColor(named: "primaryBackground")
        
        
        suggestionsTableView.layer.shadowColor = UIColor.black.cgColor
        suggestionsTableView.layer.shadowOpacity = 0.2
        suggestionsTableView.layer.shadowOffset = CGSize(width: 0, height: 3)
        suggestionsTableView.layer.shadowRadius = 5
        
        view.addSubview(suggestionsTableView)
        
        NSLayoutConstraint.activate([
            suggestionsTableView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor),
            suggestionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            suggestionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            suggestionsTableView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
}
