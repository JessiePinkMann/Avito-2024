//
//  SearchViewController.swift
//  Avito_ProfTask
//
//  Created by Egor Anoshin on 11.09.2024.
//


import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    // UI Components
    var collectionView: UICollectionView!
    var searchBarView: SearchBarView!  // Используем кастомный SearchBarView
    var loadingStateView: LoadingStateView!
    var suggestionsTableView: UITableView!  // Таблица для подсказок
    
    // Data
    var images: [UnsplashImage] = []
    var currentPage = 1
    var isFetchingMore = false
    var searchQuery: String? = nil  // По умолчанию пустой запрос
    
    // Manager
    var collectionManager: CollectionManager!
    var suggestionsManager: SuggestionsManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "primaryBackground")  // Устанавливаем задний фон
        
        setupSearchBarView()  // Настройка кастомного SearchBarView
        setupCollectionView()
        setupLoadingStateView()
        setupSuggestionsTableView()  // Добавляем таблицу для подсказок
        
        // Инициализация SuggestionsManager
        suggestionsManager = SuggestionsManager(tableView: suggestionsTableView, searchBar: searchBarView.searchBar, parentVC: self)
        
        // Инициализация CollectionViewManager
        collectionManager = CollectionManager(images: images)
        collectionView.dataSource = collectionManager
        collectionView.delegate = collectionManager
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        loadingStateView.hide()  // Скрываем состояние загрузки и ошибки при старте
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
        
        searchImages(query: query, page: currentPage)
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
        let image = images[indexPath.item]  // Получаем изображение по индексу
        cell.configure(with: image)  // Конфигурируем ячейку с данными
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10
        let width = (view.frame.width - padding * 3) / 2
        return CGSize(width: width, height: width)
    }
        
}
