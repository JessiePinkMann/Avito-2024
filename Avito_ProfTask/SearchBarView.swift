//
//  SearchBarView.swift
//  Avito_ProfTask
//
//  Created by Egor Anoshin on 11.09.2024.
//

import UIKit

// Кастомный класс для UISearchBar с анимацией и кнопкой Cancel
class SearchBarView: UIView {
    
    let searchBar = UISearchBar()
    private let cancelButton = UIButton(type: .system)  // Кнопка Cancel
    private var searchBarWidthConstraint: NSLayoutConstraint!  // Констрейнт для изменения ширины SearchBar
    
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
        
        // Настройка searchBar
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal  // Без лишних фонов
        searchBar.placeholder = "Search images..."
        addSubview(searchBar)

        // Настройка кнопки Cancel
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.alpha = 0  // Изначально скрыта
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        addSubview(cancelButton)
        
        // Констрейнты для searchBar и кнопки
        searchBarWidthConstraint = searchBar.widthAnchor.constraint(equalTo: widthAnchor)  // По умолчанию searchBar на всю ширину
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor, constant: 80),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBarWidthConstraint,
            searchBar.bottomAnchor.constraint(equalTo: bottomAnchor),

            cancelButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            cancelButton.widthAnchor.constraint(equalToConstant: 60),  // Ширина кнопки Cancel
            cancelButton.heightAnchor.constraint(equalToConstant: 30)  // Высота кнопки
        ])
    }
    
    // MARK: - Показ кнопки Cancel с анимацией

    func activateSearch() {
        // Анимация для изменения ширины searchBar и показа кнопки
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.searchBarWidthConstraint.constant = -80  // Уменьшаем ширину SearchBar для показа кнопки Cancel
            self.cancelButton.alpha = 1  // Показываем кнопку Cancel
            self.layoutIfNeeded()  // Применяем изменения
        }
    }
    
    // MARK: - Сброс поисковой строки и скрытие Cancel

    @objc func cancelButtonTapped() {
        // Вызов метода отмены в контроллере
        if let parentVC = parentViewController as? SearchViewController {
            parentVC.cancelSearch()
        }
    }


    func cancelSearch() {
        // Очистка текста и возврат к исходному состоянию
        searchBar.text = ""
        
        // Анимация для возврата SearchBar к полной ширине и скрытия кнопки Cancel
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.searchBarWidthConstraint.constant = 0  // Восстанавливаем полную ширину SearchBar
            self.cancelButton.alpha = 0  // Скрываем кнопку Cancel
            self.layoutIfNeeded()  // Применяем изменения
        }
        
        searchBar.resignFirstResponder()  // Закрываем клавиатуру
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
