//
//  CollectionManager.swift
//  Avito_ProfTask
//
//  Created by Egor Anoshin on 11.09.2024.
//

import UIKit

class CollectionManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var images: [UnsplashImage] = []
    var isGridMode = true  // По умолчанию режим сетки (два столбца)
    
    init(images: [UnsplashImage]) {
        self.images = images
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }
        let image = images[indexPath.item]
        cell.configure(with: image)
        return cell
    }
    
    // Переключение между режимами сетки и одного столбца
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10
        let availableWidth = collectionView.frame.width - padding * 3
        
        if isGridMode {
            // Режим сетки: два столбца
            let width = availableWidth / 2
            return CGSize(width: width, height: width * 1.5)
        } else {
            // Режим одного столбца
            return CGSize(width: availableWidth, height: availableWidth * 0.75)
        }
    }
    
    func toggleLayout() {
        isGridMode.toggle()
    }
}
