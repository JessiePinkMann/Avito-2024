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
        
        suggestionsManager = SuggestionsManager(tableView: suggestionsTableView, searchBar: searchBarView.searchBar, parentVC: self)
        collectionManager = CollectionManager(images: images)
        collectionManager.delegate = self  // Устанавливаем делегат
        collectionView.dataSource = collectionManager
        collectionView.delegate = collectionManager
        
        // Добавляем кнопку для сортировки через SortManager
        let sortButton = sortManager.createSortButton(target: self)  // Передаем SearchViewController
        navigationItem.rightBarButtonItem = sortButton
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        loadingStateView.hide()

        let switchButton = UIBarButtonItem(title: "Switch Mode", style: .plain, target: self, action: #selector(toggleLayoutMode))
        navigationItem.leftBarButtonItem = switchButton

        setupPaginationView()  // Устанавливаем кнопки пагинации
    }
    
    private func setupPaginationView() {
        previousPageButton = UIButton(type: .system)
        previousPageButton.setTitle("Previous", for: .normal)
        previousPageButton.addTarget(self, action: #selector(previousPageTapped), for: .touchUpInside)

        nextPageButton = UIButton(type: .system)
        nextPageButton.setTitle("Next", for: .normal)
        nextPageButton.addTarget(self, action: #selector(nextPageTapped), for: .touchUpInside)

        pageLabel = UILabel()
        pageLabel.text = "Page 1"
        pageLabel.textAlignment = .center

        paginationStackView = UIStackView(arrangedSubviews: [previousPageButton, pageLabel, nextPageButton])
        paginationStackView.axis = .horizontal
        paginationStackView.spacing = 10
        paginationStackView.distribution = .fillEqually
        paginationStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(paginationStackView)

        NSLayoutConstraint.activate([
            paginationStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            paginationStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paginationStackView.heightAnchor.constraint(equalToConstant: 50),
            paginationStackView.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    @objc private func toggleLayoutMode() {
        collectionManager.toggleLayout()
        collectionView.collectionViewLayout.invalidateLayout()  // Обновляем макет
        collectionView.reloadData()
    }
    

    
    @objc private func previousPageTapped() {
        guard currentPage > 1 else { return }
        currentPage -= 1
        pageLabel.text = "Page \(currentPage)"
        performSearch(query: searchQuery ?? "", sortBy: "relevant")
    }

    @objc private func nextPageTapped() {
        currentPage += 1
        pageLabel.text = "Page \(currentPage)"
        performSearch(query: searchQuery ?? "", sortBy: "relevant")
    }

    func updatePaginationUI() {
        previousPageButton.isEnabled = currentPage > 1
    }

    // MARK: - Выполнение поиска

    func performSearch(query: String, sortBy: String = "relevant") {
        guard !isFetchingMore else { return }
        isFetchingMore = true
        loadingStateView.showLoading()

        NetworkManager.shared.searchImages(query: query, page: currentPage, sortBy: sortBy) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loadingStateView.hide()
                self.isFetchingMore = false

                switch result {
                case .success(let fetchedImages):
                    let filteredImages = fetchedImages.filter { $0.description != nil }
                    if self.currentPage == 1 {
                        self.images = filteredImages  // Если первая страница, заменяем изображения
                    } else {
                        self.images.append(contentsOf: filteredImages)  // Если следующая страница, добавляем
                    }
                    self.collectionManager.images = self.images
                    self.collectionView.reloadData()
                    self.updatePaginationUI()
                case .failure(let error):
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
        print("Executing searchImages with query: \(query), page: \(page)")  // Логируем запрос.
        
        guard !query.isEmpty else {
            print("Query is empty, aborting request.")
            return  // Если query пустое, не выполняем запрос.
        }
        
        loadingStateView.isHidden = false
        loadingStateView.showLoading()  // Показываем состояние загрузки.
        
        NetworkManager.shared.searchImages(query: query, page: page) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingStateView.hide()  // Скрываем состояние загрузки.
            }
            
            switch result {
            case .success(let images):
                if images.isEmpty {
                    DispatchQueue.main.async {
                        self.loadingStateView.isHidden = false  // Показываем, если ничего не найдено.
                        self.loadingStateView.showNoContent()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.images.append(contentsOf: images)
                        self.collectionManager.images = self.images  // Обновляем данные в CollectionViewManager
                        self.collectionView.reloadData()
                        self.loadingStateView.isHidden = true  // Скрываем все состояния, когда есть данные.
                    }
                }
            case .failure(let error):
                print("Network error: \(error.localizedDescription)")  // Логируем ошибку.
                DispatchQueue.main.async {
                    self.loadingStateView.showError(error.localizedDescription)  // Показываем ошибку.
                    self.loadingStateView.isHidden = false  // Показываем ошибку.
                }
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count  // Количество элементов
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }

        let image = images[indexPath.item]
        // Передаем режим отображения в ячейку через isGridMode
        cell.configure(with: image, isSingleColumnMode: !collectionManager.isGridMode)
        return cell
    }


    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10

        if collectionManager.isGridMode {  // Проверяем, включен ли режим сетки
            // Режим двух плиток
            let width = (view.frame.width - padding * 3) / 2
            return CGSize(width: width, height: width)
        } else {
            // Устанавливаем одну плитку во всю ширину экрана с учётом отступов
            let width = view.frame.width - padding * 2
            let height = width * 0.75  // Примерное соотношение сторон
            return CGSize(width: width, height: height)
        }
    }
}

// Реализуем делегат для перехода на детальный экран
extension SearchViewController: CollectionManagerDelegate {
    func didSelectImage(_ image: UnsplashImage) {
        let detailVC = DetailViewController(image: image)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
