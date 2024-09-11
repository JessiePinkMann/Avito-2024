import UIKit

class ImageCell: UICollectionViewCell {

    // Элементы UI
    private let imageView = UIImageView()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()  // Настраиваем UI элементы
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Настройка UI компонентов
    private func setupViews() {
        // Настройка imageView
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10  // Скругляем углы у картинки
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        // Настройка descriptionLabel
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 1  // Описание в одну строку
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)

        // Настройка dateLabel
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .gray
        dateLabel.numberOfLines = 1  // Дата в одну строку
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)

        // Устанавливаем констрейнты для всех элементов
        NSLayoutConstraint.activate([
            // Картинка (с минимальными отступами)
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),  // Оставляем высоту равной ширине
            
            // Описание (минимальный отступ от картинки)
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 2),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            // Дата (минимальный отступ от описания)
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -5)
        ])
    }

    // Метод для настройки содержимого ячейки
    func configure(with image: UnsplashImage) {
        descriptionLabel.text = image.description ?? "No description"
        dateLabel.text = formatDate(from: image.created_at)  // Используем created_at

        // Асинхронная загрузка изображения
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

    // Пример форматирования даты
    private func formatDate(from createdAt: String) -> String {
        let dateFormatter = ISO8601DateFormatter()  // Декодируем ISO формат
        if let date = dateFormatter.date(from: createdAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return "Unknown date"
    }
}
