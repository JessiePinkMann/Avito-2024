//
//  SortManager.swift
//  Avito_ProfTask
//
//  Created by Egor Anoshin on 12.09.2024.
//

import UIKit

// Добавляем новый case для сортировки по старым изображениям
enum SortOption: String {
    case relevant = "Popular"  // Сортировка по релевантности
    case latest = "Latest"     // Сортировка по новизне
}


class SortManager {
    var selectedSortOption: SortOption = .relevant  // Дефолт: Relevant (по умолчанию API)

    func createSortButton(target: SearchViewController) -> UIBarButtonItem {
        // Действия для сортировки
        let relevantAction = UIAction(title: "Sort by Relevant", image: UIImage(systemName: "star.fill")) { _ in
            self.selectedSortOption = .relevant
            target.performSearch(query: target.searchQuery ?? "", sortBy: "relevant")
        }
        
        let latestAction = UIAction(title: "Sort by Latest", image: UIImage(systemName: "clock.fill")) { _ in
            self.selectedSortOption = .latest
            target.performSearch(query: target.searchQuery ?? "", sortBy: "latest")
        }

        // Создаем меню с опциями сортировки
        let sortMenu = UIMenu(title: "Sort by", options: .displayInline, children: [relevantAction, latestAction])
        
        // Создаем кнопку для меню сортировки
        let sortButton = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), menu: sortMenu)
        
        return sortButton
    }
}
