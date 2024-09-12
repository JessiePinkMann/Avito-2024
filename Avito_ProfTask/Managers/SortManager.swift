//
//  SortManager.swift
//  Avito_ProfTask
//
//  Created by Egor Anoshin on 12.09.2024.
//

import UIKit

enum SortOption: String {
    case relevant = "Popular"
    case latest = "Latest"
}


class SortManager {
    var selectedSortOption: SortOption = .relevant

    func createSortButton(target: SearchViewController) -> UIBarButtonItem {
        let relevantAction = UIAction(title: "Sort by Relevant", image: UIImage(systemName: "star.fill")) { _ in
            self.selectedSortOption = .relevant
            target.performSearch(query: target.searchQuery ?? "", sortBy: "relevant")
        }
        
        let latestAction = UIAction(title: "Sort by Latest", image: UIImage(systemName: "clock.fill")) { _ in
            self.selectedSortOption = .latest
            target.performSearch(query: target.searchQuery ?? "", sortBy: "latest")
        }

        let sortMenu = UIMenu(title: "Sort by", options: .displayInline, children: [relevantAction, latestAction])
        
        let sortButton = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), menu: sortMenu)
        
        return sortButton
    }
}
