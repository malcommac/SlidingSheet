//
//  DetailCell.swift
//  Example
//
//  Created by daniele on 13/03/23.
//

import UIKit

public class DetailCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
    @IBOutlet public var collectionView: UICollectionView!
    
    static let allImages: [UIImage] = [
        .init(named: "property0")!,
        .init(named: "property1")!,
        .init(named: "property2")!,
        .init(named: "property3")!
    ]
 
    public var imagesToLoad: [UIImage] = DetailCell.allImages.shuffled()
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
    
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        
        collectionView.register(ImageCellClass.self, forCellWithReuseIdentifier: "ImageCellClass")
        collectionView.clipsToBounds = true
    }
    
    public var flowLayout: UICollectionViewFlowLayout {
        collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        imagesToLoad.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .zero
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, layout
                               collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: self.frame.width, height: collectionView.frame.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCellClass", for: indexPath) as! ImageCellClass
        cell.backgroundColor = .gray
        cell.imageView.image = imagesToLoad[indexPath.row]
        return cell
    }
    
}

public class ImageCellClass: UICollectionViewCell {
    
    public lazy var imageView: UIImageView = {
        let i = UIImageView(frame: .zero)
        i.backgroundColor = .red
        return i
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: self.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
