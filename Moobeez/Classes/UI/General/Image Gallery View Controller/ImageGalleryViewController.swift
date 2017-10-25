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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        (UIApplication.shared.delegate as! AppDelegate).isPortrait = true
        dismiss(animated: true, completion: nil)
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
