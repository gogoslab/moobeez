//
//  PersonDetailsViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 05/10/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

class PersonToolboxView : ToolboxView {
    
    @IBOutlet var nameTextField: UITextField!
    
    @IBOutlet var moviesCollectionView: UICollectionView!
    
    @IBOutlet var descriptionButton: UIButton!
    @IBOutlet var moviesButton: UIButton!
    @IBOutlet var photosButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var person:TmdbPerson? {
        
        didSet {
            nameTextField.text = person?.name
        }
    }    
}

class PersonDetailsViewController: MBViewController {

    var person:TmdbPerson?
    
    @IBOutlet var profileImageView:UIImageView!
    @IBOutlet var contentView:UIView!
    
    @IBOutlet var toolboxView: PersonToolboxView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        contentView.isHidden = true
        
        loadProfilePicture()
        
        toolboxView.person = person
        
        TmdbService.startPersonConnection(person: person!) { (error: Error?, person: TmdbPerson?) in
            DispatchQueue.main.async {
                self.reloadCharacters()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) {
            
            if self.contentView.isHidden {
                self.contentView.isHidden = false
                self.toolboxView.showFullToolbox()
            }
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.destination is MoobeeDetailsViewController {
            
            let moobeeViewController:MoobeeDetailsViewController = segue.destination as! MoobeeDetailsViewController
            
            let cell:CastThumbnailCell? = sender as? CastThumbnailCell
            
            moobeeViewController.movie = cell?.movie as? TmdbMovie
        }
    }
    
    override func summaryViewForViewController(_ viewController: UIViewController) -> UIView? {
        
        if viewController is MoobeeDetailsViewController {
            for castCell:UICollectionViewCell in toolboxView.moviesCollectionView.visibleCells {
                if (castCell as! CastThumbnailCell).movie?.tmdbId == (viewController as! MoobeeDetailsViewController).movie?.tmdbId {
                    return castCell
                }
            }
        }
        
        return nil
    }
    


    func loadProfilePicture() {
        
        profileImageView.loadTmdbProfileWithPath(path: person!.profilePath!) { (didLoadImage) in
            if didLoadImage {
                let bottomHalfLuminosity: CGFloat = self.profileImageView.image?.bottomHalfLuminosity() ?? 0.0
                self.toolboxView.applyTheme(lightTheme: bottomHalfLuminosity <= 0.60);
            }
        }
    }
    
    var characters:[TmdbCharacter]?
    func reloadCharacters() {
        
        characters = person?.characters?.filtered(using: NSPredicate(format: "movie != nil")).sortedArray(comparator: { (c1, c2) -> ComparisonResult in
            
            guard (c1 as! TmdbCharacter).date == nil else {
                return ComparisonResult.orderedAscending
            }
            
            guard (c2 as! TmdbCharacter).date == nil else {
                return ComparisonResult.orderedDescending
            }
            
            return (c2 as! TmdbCharacter).date?.compare(((c1 as! TmdbCharacter).date)!) ?? ComparisonResult.orderedAscending
        }) as? [TmdbCharacter]
        self.toolboxView.moviesCollectionView.reloadData()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        contentView.isHidden = true
        hideDetailsViewController()
    }
    
    @IBAction func watchlistButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func sawMovieButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func descriptionButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func moviesButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func photosButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func posterTapped(_ sender: UITapGestureRecognizer) {
        toolboxView.hideFullToolbox()
    }
    
}

extension PersonDetailsViewController {
    
    
    
}

extension PersonDetailsViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return characters?.count ?? 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:CastThumbnailCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as! CastThumbnailCell
        
        let character:TmdbCharacter = characters?[indexPath.row] as! TmdbCharacter
        cell.movie = character.movie
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let character:TmdbCharacter = characters?[indexPath.row] as! TmdbCharacter
        
        if character.movie is TmdbMovie {
            performSegue(withIdentifier: "MovieDetailsSegue", sender: collectionView.cellForItem(at: indexPath))
        }
        
    }
    
}
