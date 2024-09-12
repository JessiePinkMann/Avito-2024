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
    private let maxHistoryCount = 5
    
    private init() {}
    
    func loadHistory() -> [String] {
        return UserDefaults.standard.stringArray(forKey: historyKey) ?? []
    }
    
    func saveQuery(_ query: String) {
        var history = loadHistory()
        
        if let index = history.firstIndex(of: query) {
            history.remove(at: index)
        }
        
        history.insert(query, at: 0)
        
        if history.count > maxHistoryCount {
            history.removeLast()
        }
        
        UserDefaults.standard.set(history, forKey: historyKey)
    }
    
    func filteredHistory(for query: String) -> [String] {
        let history = loadHistory()
        
        return history.filter { $0.lowercased().contains(query.lowercased()) }
    }
    
}
