//
//  HistoryManager.swift
//  Avito_ProfTask
//
//  Created by Egor Anoshin on 11.09.2024.
//

import Foundation

class HistoryManager {
    static let shared = HistoryManager()
    private let historyKey = "searchHistory"
    
    private init() {}
    
    func saveQuery(_ query: String) {
        var history = fetchHistory()
        history.insert(query, at: 0)
        history = Array(history.prefix(5))  // Ограничиваем историю 5 элементами
        UserDefaults.standard.setValue(history, forKey: historyKey)
    }
    
    func fetchHistory() -> [String] {
        return UserDefaults.standard.stringArray(forKey: historyKey) ?? []
    }
}
