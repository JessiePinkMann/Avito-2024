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
    private var searchBarView: SearchBarView!  // Используем кастомный SearchBarView
    private var loadingStateView: LoadingStateView!
    
    // Data
    private var images: [UnsplashImage] = []
    private var currentPage = 1
    private var isFetchingMore = false
    private var searchQuery: String? = nil  // По умолчанию пустой запрос
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "primaryBackground")  // Устанавливаем задний фон
        
        setupSearchBarView()  // Настройка кастомного SearchBarView
        setupCollectionView()
        setupLoadingStateView()
        
        // Добавляем возможность скрытия клавиатуры и возврата к исходному состоянию при нажатии на экран
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false  // Это позволит обрабатывать касания и в collectionView
        view.addGestureRecognizer(tapGesture)
        
        loadingStateView.hide()  // Скрываем состояние загрузки и ошибки при старте
    }

    // MARK: - UI Setup

    private func setupSearchBarView() {
        searchBarView = SearchBarView()
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        searchBarView.searchBar.delegate = self  // Привязываем делегат к searchBar
        view.addSubview(searchBarView)

        // Констрейнты для растягивания searchBar на весь верхний экран
        NSLayoutConstraint.activate([
            searchBarView.topAnchor.constraint(equalTo: view.topAnchor),
            searchBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBarView.heightAnchor.constraint(equalToConstant: 150)
        ])
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
        collectionView.backgroundColor = .clear  // Делаем фон collectionView прозрачным
        view.addSubview(collectionView)
        
        // Constraints
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor),  // Привязываем к низу searchBarView
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

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Активируем анимацию при начале редактирования
        searchBarView.activateSearch()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !query.isEmpty else {
            print("Search query is empty, no request sent.")
            return  // Если запрос пустой, ничего не делаем.
        }
        
        images.removeAll()
        collectionView.reloadData()
        currentPage = 1
        searchQuery = query
        
        searchImages(query: query, page: currentPage)
        searchBar.resignFirstResponder()  // Скрываем клавиатуру.
    }

    // MARK: - Скрытие клавиатуры и возврат к нормальному состоянию
    @objc private func dismissKeyboard() {
        // Закрываем клавиатуру
        searchBarView.searchBar.resignFirstResponder()
        
        // Возвращаем SearchBar к исходному состоянию (как при нажатии на Cancel)
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
