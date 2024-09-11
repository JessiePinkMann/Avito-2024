//
//  SuggestionsManager.swift
//  Avito_ProfTask
//
//  Created by Egor Anoshin on 11.09.2024.
//

import Foundation
import UIKit

class SuggestionsManager: NSObject, UITableViewDataSource, UITableViewDelegate {
    private var suggestions: [String] = []
    private var tableView: UITableView
    private var searchBar: UISearchBar
    private weak var parentVC: SearchViewController?  // Ссылка на контроллер

    init(tableView: UITableView, searchBar: UISearchBar, parentVC: SearchViewController) {
        self.tableView = tableView
        self.searchBar = searchBar
        self.parentVC = parentVC
        super.init()

        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    // Фильтрация истории поиска
    func filterSuggestions(for query: String) {
        suggestions = HistoryManager.shared.filteredHistory(for: query)
        tableView.reloadData()
        tableView.isHidden = suggestions.isEmpty
        updateSuggestionsTableViewHeight()
    }

    // Очистка таблицы
    func clearSuggestions() {
        suggestions.removeAll()
        tableView.reloadData()
        tableView.isHidden = true
    }

    // Обновляем высоту таблицы в зависимости от количества элементов
    private func updateSuggestionsTableViewHeight() {
        let maxVisibleRows = 5
        let rowHeight: CGFloat = 44
        let totalHeight = CGFloat(suggestions.count) * rowHeight
        let maxTableHeight = CGFloat(maxVisibleRows) * rowHeight
        let newHeight = min(totalHeight, maxTableHeight)

        tableView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.isActive = false
            }
        }

        tableView.heightAnchor.constraint(equalToConstant: newHeight).isActive = true

        UIView.animate(withDuration: 0.3) {
            self.parentVC?.view.layoutIfNeeded()
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = suggestions[indexPath.row]
        cell.backgroundColor = UIColor(named: "primaryBackground")
        cell.textLabel?.textColor = UIColor(named: "primaryText")
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedQuery = suggestions[indexPath.row]
        searchBar.text = selectedQuery
        parentVC?.searchBarSearchButtonClicked(searchBar)
        tableView.isHidden = true
    }
}
