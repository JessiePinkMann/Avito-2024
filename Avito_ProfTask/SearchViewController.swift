//
//  SearchViewController.swift
//  Avito_ProfTask
//
//  Created by Egor Anoshin on 11.09.2024.
//
import UIKit

class SearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    // UI Components
    private var collectionView: UICollectionView!
    private let searchBar = UISearchBar()
    private var loadingStateView: LoadingStateView!
    
    // Data
    private var images: [UnsplashImage] = []
    private var currentPage = 1
    private var isFetchingMore = false
    private var searchQuery: String? = nil  // По умолчанию пустой запрос
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupSearchBar()
        setupCollectionView()
        setupLoadingStateView()
        
        // Не выполняем никаких сетевых запросов при старте
        loadingStateView.hide()  // Скрываем состояние загрузки и ошибки при старте
    }
    
    // MARK: - UI Setup
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search images..."
        navigationItem.titleView = searchBar
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        
        // Constraints
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupLoadingStateView() {
        loadingStateView = LoadingStateView()
        loadingStateView.translatesAutoresizingMaskIntoConstraints = false
        loadingStateView.isHidden = true  // Скрываем вид загрузки или ошибки при старте
        view.addSubview(loadingStateView)
        
        NSLayoutConstraint.activate([
            loadingStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !query.isEmpty else {
            print("Search query is empty, no request sent.")
            return  // Если запрос пустой, ничего не делаем.
        }
        
        // Только если запрос не пустой, отправляем его.
        images.removeAll()
        collectionView.reloadData()
        currentPage = 1
        searchQuery = query
        
        // Запускаем запрос только после ввода пользователем
        searchImages(query: query, page: currentPage)
        searchBar.resignFirstResponder()  // Скрываем клавиатуру.
    }
    
    // MARK: - Networking
    
    // Полностью блокируем выполнение запроса, если query пустое
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
    
    // MARK: - Infinite Scroll
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if position > contentHeight - scrollViewHeight - 100, !isFetchingMore {
            fetchMoreImages()
        }
    }
    
    private func fetchMoreImages() {
        isFetchingMore = true
        currentPage += 1
        
        // Используем сохранённый запрос для подгрузки изображений
        guard let query = searchQuery, !query.isEmpty else {
            print("Query is empty during fetchMoreImages, aborting.")
            return  // Если query пустое, не выполняем запрос.
        }
        
        NetworkManager.shared.searchImages(query: query, page: currentPage) { [weak self] result in guard let self = self else { return }
            switch result {
            case .success(let newImages):
                let startIndex = self.images.count
                let endIndex = startIndex + newImages.count
                let indexPaths = (startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
                
                self.images.append(contentsOf: newImages)
                
                DispatchQueue.main.async {
                    self.collectionView.insertItems(at: indexPaths)
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.loadingStateView.showError(error.localizedDescription)
                    self.loadingStateView.isHidden = false  // Показываем ошибку
                }
            }
            
            self.isFetchingMore = false
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
        cell.configure(with: image)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10
        let width = (view.frame.width - padding * 3) / 2
        return CGSize(width: width, height: width)
    }
}
