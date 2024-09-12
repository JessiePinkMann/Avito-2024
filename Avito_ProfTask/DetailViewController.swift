//
//  DetailViewController.swift
//  Avito_ProfTask
//
//  Created by Egor Anoshin on 12.09.2024.
//

import UIKit

class DetailViewController: UIViewController {

    private let image: UnsplashImage

    private let imageView = UIImageView()
    private let descriptionLabel = UILabel()
    private let authorLabel = UILabel()
    
    // View для кнопок
    private let bottomButtonsView = UIView()
    private let shareButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)

    // Инициализация с изображением
    init(image: UnsplashImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "primaryBackground")

        setupViews()
        configure(with: image)
        setupButtons()
    }

    private func setupViews() {
        // Используем UIScrollView для основного контента
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)

        authorLabel.font = UIFont.systemFont(ofSize: 14)
        authorLabel.textColor = .gray
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(authorLabel)

        // Настройка констрейнтов для скроллируемого контента
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),  // Оставляем место для кнопок
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 300),

            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            authorLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            authorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        // View для кнопок внизу экрана
        bottomButtonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomButtonsView)

        NSLayoutConstraint.activate([
            bottomButtonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButtonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomButtonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomButtonsView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func setupButtons() {
        bottomButtonsView.addSubview(shareButton)
        bottomButtonsView.addSubview(saveButton)

        // Настройка стиля кнопок
        shareButton.setTitle("Share", for: .normal)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.tintColor = .systemBlue
        shareButton.addTarget(self, action: #selector(shareImage), for: .touchUpInside)

        saveButton.setTitle("Save", for: .normal)
        saveButton.setImage(UIImage(systemName: "tray.and.arrow.down.fill"), for: .normal)
        saveButton.tintColor = .systemBlue
        saveButton.addTarget(self, action: #selector(saveImage), for: .touchUpInside)

        // Настройка констрейнтов для кнопок
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            shareButton.leadingAnchor.constraint(equalTo: bottomButtonsView.leadingAnchor, constant: 40),
            shareButton.centerYAnchor.constraint(equalTo: bottomButtonsView.centerYAnchor),

            saveButton.trailingAnchor.constraint(equalTo: bottomButtonsView.trailingAnchor, constant: -40),
            saveButton.centerYAnchor.constraint(equalTo: bottomButtonsView.centerYAnchor)
        ])
    }

    // Функция для кнопки Share
    @objc private func shareImage() {
        guard let imageUrl = URL(string: image.urls.small) else { return }
        
        URLSession.shared.dataTask(with: imageUrl) { data, _, error in
            if let data = data, let imageToShare = UIImage(data: data) {
                DispatchQueue.main.async {
                    let activityVC = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
                    self.present(activityVC, animated: true, completion: nil)
                }
            }
        }.resume()
    }

    // Функция для кнопки Save
    @objc private func saveImage() {
        guard let imageUrl = URL(string: image.urls.small) else { return }
        
        URLSession.shared.dataTask(with: imageUrl) { data, _, error in
            if let data = data, let imageToSave = UIImage(data: data) {
                DispatchQueue.main.async {
                    UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
        }.resume()
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlert(title: "Error", message: "Failed to save image: \(error.localizedDescription)")
        } else {
            showAlert(title: "Saved", message: "Image has been successfully saved to your gallery.")
        }
    }

    // Функция для отображения алерта
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true, completion: nil)
    }
    
    private func configure(with image: UnsplashImage) {
        descriptionLabel.text = image.description ?? "No description available"
        authorLabel.text = "Author: \(image.user.name)"

        if let url = URL(string: image.urls.small) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
    }
}
