import UIKit

class ImageCell: UICollectionViewCell {

    // Элементы UI
    private let imageView = UIImageView()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()

    // Проперти для отслеживания режима
    var isSingleColumnMode = false {
        didSet {
            updateLayoutForMode()
        }
    }

    // Констрейнт для высоты картинки
    private var imageViewHeightConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Настройка imageView
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        // Настройка descriptionLabel
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 1
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)

        // Настройка dateLabel
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .gray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)

        // Устанавливаем базовые констрейнты для всех элементов
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 2),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -5)
        ])

        // Создаем констрейнт для высоты imageView, который будет меняться
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        imageViewHeightConstraint.isActive = true
    }

    // Метод для обновления режима отображения
    private func updateLayoutForMode() {
        // Убираем активный constraint перед переключением
        imageViewHeightConstraint.isActive = false

        if isSingleColumnMode {
            // В режиме одной колонки высота фиксируется на 200
            imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 200)
        } else {
            // В режиме двух колонок высота = ширина (квадрат)
            imageViewHeightConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        }

        imageViewHeightConstraint.isActive = true
        layoutIfNeeded()  // Применяем изменения
    }

    func configure(with image: UnsplashImage, isSingleColumnMode: Bool) {
        descriptionLabel.text = image.description ?? "No description"
        dateLabel.text = formatDate(from: image.created_at)

        self.isSingleColumnMode = isSingleColumnMode

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

    private func formatDate(from createdAt: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        if let date = dateFormatter.date(from: createdAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return "Unknown date"
    }
}

