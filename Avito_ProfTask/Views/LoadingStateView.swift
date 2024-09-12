//
//  LoadingStateView.swift
//  Avito_ProfTask
//
//  Created by Egor Anoshin on 11.09.2024.
//
//

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
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.minimumScaleFactor = 0.5 

        addSubview(messageLabel)

        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),  // Отступы слева и справа
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])

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
        messageLabel.text = ""
        self.isHidden = true
    }
}
