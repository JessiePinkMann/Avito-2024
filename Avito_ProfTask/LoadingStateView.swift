//
//  LoadingStateView.swift
//  Avito_ProfTask
//
//  Created by Egor Anoshin on 11.09.2024.
//
//
//import Foundation
//import UIKit
//
//class LoadingStateView: UIView {
//    
//    private let label = UILabel()
//    private let activityIndicator = UIActivityIndicatorView(style: .large)
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupView() {
//        label.translatesAutoresizingMaskIntoConstraints = false
//        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(label)
//        addSubview(activityIndicator)
//        
//        NSLayoutConstraint.activate([
//            label.centerXAnchor.constraint(equalTo: centerXAnchor),
//            label.centerYAnchor.constraint(equalTo: centerYAnchor),
//            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
//            activityIndicator.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10)
//        ])
//        
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textColor = .gray
//    }
//    
//    func showLoading() {
//        label.text = "Loading..."
//        activityIndicator.startAnimating()
//        isHidden = false
//    }
//    
//    func showError(_ message: String) {
//        label.text = message
//        activityIndicator.stopAnimating()
//        isHidden = false
//    }
//    
//    func showNoContent() {
//        label.text = "No content found."
//        activityIndicator.stopAnimating()
//        isHidden = false
//    }
//    
//    func hide() {
//        isHidden = true
//        activityIndicator.stopAnimating()
//    }
//}

import UIKit

class LoadingStateView: UIView {

    private let messageLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textAlignment = .center
        messageLabel.textColor = .gray
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        // Изначально скрываем сообщение
        hide()
    }
    
    func showLoading() {
        messageLabel.text = "Loading..."
        self.isHidden = false
    }
    
    func showError(_ message: String) {
        messageLabel.text = message
        self.isHidden = false
    }
    
    func showNoContent() {
        messageLabel.text = "No content available."
        self.isHidden = false
    }
    
    func hide() {
        messageLabel.text = ""  // Очищаем текст
        self.isHidden = true
    }
}
