//
//  HistoryManager.swift
//  Avito_ProfTask
//
//  Created by Egor Anoshin on 11.09.2024.
//

import Foundation

class HistoryManager {
    static let shared = HistoryManager()  // Singleton
    
    private let historyKey = "searchHistory"
    private let maxHistoryCount = 5  // Максимум 5 запросов

    private init() {}

    // Загрузить историю запросов
    func loadHistory() -> [String] {
        return UserDefaults.standard.stringArray(forKey: historyKey) ?? []
    }

    // Сохранить новый запрос
    func saveQuery(_ query: String) {
        var history = loadHistory()

        // Удалить запрос, если он уже есть, чтобы избежать дублирования
        if let index = history.firstIndex(of: query) {
            history.remove(at: index)
        }

        // Добавляем новый запрос в начало
        history.insert(query, at: 0)

        // Ограничиваем до 5 запросов
        if history.count > maxHistoryCount {
            history.removeLast()
        }

        // Сохраняем обновленную историю в UserDefaults
        UserDefaults.standard.set(history, forKey: historyKey)
    }

    // Фильтрация подсказок по введенному тексту
    func filteredHistory(for query: String) -> [String] {
        // Загружаем историю и фильтруем её, игнорируя регистр
        let history = loadHistory()
        
        // Простой поиск с учётом регистра
        return history.filter { $0.lowercased().contains(query.lowercased()) }
    }



}
