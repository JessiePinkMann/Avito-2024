//
//  CollectionManager.swift
//  Avito_ProfTask
//
//  Created by Egor Anoshin on 11.09.2024.
//
import UIKit

protocol CollectionManagerDelegate: AnyObject {
    func didSelectImage(_ image: UnsplashImage)
    var currentPage: Int { get }
}

import UIKit

class CollectionManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    weak var delegate: CollectionManagerDelegate?

    var images: [UnsplashImage] = [] {
        didSet {
            images = images.filter { $0.description != nil }
        }
    }
    
    var isGridMode = true

    init(images: [UnsplashImage]) {
        super.init()
        self.images = images.filter { $0.description != nil }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }

        let image = images[indexPath.item]
        cell.configure(with: image, isSingleColumnMode: !isGridMode)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImage = images[indexPath.item]
        delegate?.didSelectImage(selectedImage)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10
        let availableWidth = collectionView.frame.width - padding * 3

        if isGridMode {
            let width = availableWidth / 2
            return CGSize(width: width, height: width * 1.5)
        } else {
            return CGSize(width: availableWidth, height: availableWidth * 0.75)
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PaginationFooterView.reuseIdentifier, for: indexPath) as! PaginationFooterView

            headerView.previousButton.addTarget(delegate, action: #selector(SearchViewController.previousPageTapped), for: .touchUpInside)
            headerView.nextButton.addTarget(delegate, action: #selector(SearchViewController.nextPageTapped), for: .touchUpInside)
            headerView.pageLabel.text = "Page \(delegate?.currentPage ?? 1)"
            return headerView
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PaginationFooterView.reuseIdentifier, for: indexPath) as! PaginationFooterView

            footerView.previousButton.addTarget(delegate, action: #selector(SearchViewController.previousPageTapped), for: .touchUpInside)
            footerView.nextButton.addTarget(delegate, action: #selector(SearchViewController.nextPageTapped), for: .touchUpInside)
            footerView.pageLabel.text = "Page \(delegate?.currentPage ?? 1)"
            return footerView
        default:
            fatalError("Unexpected element kind")
        }
    }

    func toggleLayout() {
        isGridMode.toggle()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return images.isEmpty ? CGSize.zero : CGSize(width: collectionView.frame.width, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return images.isEmpty ? CGSize.zero : CGSize(width: collectionView.frame.width, height: 50)
    }

}
