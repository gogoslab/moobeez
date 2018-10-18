//
//  ImageGalleryViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 25/10/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
}

class ImageGalleryViewController: MBViewController {

    @IBOutlet var collectionView: UICollectionView!
    public var images:[TmdbImage]?
    
    @IBOutlet weak var transitionImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        (UIApplication.shared.delegate as! AppDelegate).isPortrait = true
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let currentPage = Int(collectionView.contentOffset.x / collectionView.frame.width)

        if let image = images?[currentPage] {
            transitionImageView.isHidden = false
            transitionImageView.loadTmdbImage(image: image)
            collectionView.isHidden = true
        }
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
        
        coordinator.animate(alongsideTransition: { (_) in
        }) { (_) in
            self.collectionView.contentOffset.x = CGFloat(currentPage) * self.collectionView.frame.width
            self.transitionImageView.isHidden = true
            self.collectionView.isHidden = false
        }
    }
}

extension ImageGalleryViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (images != nil) ? images!.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        
        cell.imageView.sd_setShowActivityIndicatorView(true)
        cell.imageView.loadTmdbImage(image: images![indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}
