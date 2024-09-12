//
//  SearchViewController.swift
//  Avito_ProfTask
//
//  Created by Egor Anoshin on 11.09.2024.
//


import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {

    var collectionView: UICollectionView!
    var searchBarView: SearchBarView!
    var loadingStateView: LoadingStateView!
    var suggestionsTableView: UITableView!
    var paginationStackView: UIStackView!
    var previousPageButton: UIButton!
    var nextPageButton: UIButton!
    var pageLabel: UILabel!

    var images: [UnsplashImage] = []
    var currentPage = 1
    var isFetchingMore = false
    var searchQuery: String? = nil

    var collectionManager: CollectionManager!
    var suggestionsManager: SuggestionsManager!

    private let sortManager = SortManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "primaryBackground")

        setupSearchBarView()
        setupCollectionView()
        setupLoadingStateView()
        setupSuggestionsTableView()

        collectionView.register(PaginationFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PaginationFooterView.reuseIdentifier)
        collectionView.register(PaginationFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: PaginationFooterView.reuseIdentifier)

        suggestionsManager = SuggestionsManager(tableView: suggestionsTableView, searchBar: searchBarView.searchBar, parentVC: self)
        collectionManager = CollectionManager(images: images)
        collectionManager.delegate = self
        collectionView.dataSource = collectionManager
        collectionView.delegate = collectionManager

        let sortButton = sortManager.createSortButton(target: self)
        navigationItem.rightBarButtonItem = sortButton

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        loadingStateView.hide()

        let switchButton = UIBarButtonItem(title: "Switch Mode", style: .plain, target: self, action: #selector(toggleLayoutMode))
        navigationItem.leftBarButtonItem = switchButton
    }

    @objc func previousPageTapped() {
        guard currentPage > 1 else { return }
        currentPage -= 1
        performSearch(query: searchQuery ?? "", sortBy: "relevant")
    }

    @objc func nextPageTapped() {
        currentPage += 1
        performSearch(query: searchQuery ?? "", sortBy: "relevant")
    }

    func updatePaginationUI() {
        let footerView = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: 0)) as? PaginationFooterView
        footerView?.previousButton.isEnabled = currentPage > 1
    }
    
    @objc private func toggleLayoutMode() {
        collectionManager.toggleLayout()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }

    // MARK: - Выполнение поиска

    func performSearch(query: String, sortBy: String = "relevant") {
        guard !isFetchingMore else { return }
        isFetchingMore = true
        loadingStateView.showLoading()

        collectionView.isHidden = true

        NetworkManager.shared.searchImages(query: query, page: currentPage, sortBy: sortBy) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loadingStateView.hide()
                self.isFetchingMore = false

                switch result {
                case .success(let fetchedImages):
                    if fetchedImages.isEmpty {
                        self.loadingStateView.showNoContent()
                        self.collectionView.isHidden = true
                    } else {
                        self.images = fetchedImages.filter { $0.description != nil }
                        self.collectionManager.images = self.images
                        self.collectionView.reloadData()
                        self.collectionView.isHidden = false
                        self.collectionView.setContentOffset(.zero, animated: true)
                        self.updatePaginationUI()
                    }
                case .failure(let error):
                    switch error {
                    case .requestFailed:
                        self.loadingStateView.showError("Network error: Please check your internet connection.")
                    case .invalidURL:
                        self.loadingStateView.showError("Invalid URL error: Unable to reach server.")
                    case .decodingFailed:
                        self.loadingStateView.showError("Decoding error: Unable to process server response.")
                    }

                    self.collectionView.isHidden = true
                    print("Error: \(error)")
                }
            }
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBarView.activateSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            suggestionsManager.filterSuggestions(for: searchText)
        } else {
            suggestionsManager.clearSuggestions()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !query.isEmpty else {
            return
        }
        
        HistoryManager.shared.saveQuery(query)
        
        images.removeAll()
        collectionView.reloadData()
        currentPage = 1
        searchQuery = query

        performSearch(query: query, sortBy: "relevant")
        searchBar.resignFirstResponder()
        
        suggestionsManager.clearSuggestions()
    }
    
    func cancelSearch() {
        searchBarView.searchBar.text = ""
        suggestionsManager.clearSuggestions()
        searchBarView.searchBar.resignFirstResponder()
        searchBarView.cancelSearch()
    }
    
    @objc private func dismissKeyboard() {
        searchBarView.searchBar.resignFirstResponder()
        searchBarView.cancelSearch()
    }
    
    // MARK: - Networking
    
    private func searchImages(query: String, page: Int) {
        print("Executing searchImages with query: \(query), page: \(page)")
        
        guard !query.isEmpty else {
            print("Query is empty, aborting request.")
            return
        }
        
        loadingStateView.isHidden = false
        loadingStateView.showLoading()
        
        NetworkManager.shared.searchImages(query: query, page: page) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingStateView.hide()
            }
            
            switch result {
            case .success(let images):
                if images.isEmpty {
                    DispatchQueue.main.async {
                        self.loadingStateView.isHidden = false
                        self.loadingStateView.showNoContent()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.images.append(contentsOf: images)
                        self.collectionManager.images = self.images
                        self.collectionView.reloadData()
                        self.loadingStateView.isHidden = true
                    }
                }
            case .failure(let error):
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.loadingStateView.showError(error.localizedDescription)
                    self.loadingStateView.isHidden = false
                }
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }

        let image = images[indexPath.item]
        cell.configure(with: image, isSingleColumnMode: !collectionManager.isGridMode)
        return cell
    }


    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10

        if collectionManager.isGridMode {
            let width = (view.frame.width - padding * 3) / 2
            return CGSize(width: width, height: width)
        } else {
            let width = view.frame.width - padding * 2
            let height = width * 0.75
            return CGSize(width: width, height: height)
        }
    }
}

extension SearchViewController: CollectionManagerDelegate {
    func didSelectImage(_ image: UnsplashImage) {
        let detailVC = DetailViewController(image: image)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
