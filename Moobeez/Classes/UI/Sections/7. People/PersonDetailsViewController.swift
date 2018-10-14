//
//  PersonDetailsViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 05/10/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

enum PersonSection:Int {
    case general = 0;
    case description = 1;
    case cast = 2;
    case photos = 4;
}

class PersonToolboxView : ToolboxView {
    
    @IBOutlet var nameTextField: UITextField!
    
    @IBOutlet var moviesCollectionView: UICollectionView!
    @IBOutlet var moviesDetailsCollectionView: UICollectionView!
    
    @IBOutlet var descriptionButton: UIButton!
    @IBOutlet var moviesButton: UIButton!
    @IBOutlet var photosButton: UIButton!
    
    @IBOutlet var descriptionViews: [UIView]!
    @IBOutlet var castViews: [UIView]!
    @IBOutlet var photosViews: [UIView]!
    
    @IBOutlet var descriptionTextView: UITextView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var person:TmdbPerson? {
        
        didSet {
            nameTextField.text = person?.name
            descriptionTextView.text = person?.overview
        }
    }
    
    var section:PersonSection = .general {
        willSet {
            self.tabButtons[section.rawValue].isSelected = false
        }
        didSet {
            self.tabButtons[section.rawValue].isSelected = true
            switch section {
            case .general:
                self.cells = self.generalViews
            case .description:
                self.cells = self.descriptionViews
            case .cast:
                self.cells = self.castViews
            case .photos:
                self.cells = self.photosViews
            }
            
            if isVisible == false {
                showFullToolbox(animated: false)
            }
        }
    }
    
}

class PersonDetailsViewController: MBViewController {

    var person:TmdbPerson?
    
    @IBOutlet var profileImageView:UIImageView!
    @IBOutlet var contentView:UIView!
    
    var profileImage:UIImage?
    
    @IBOutlet var toolboxView: PersonToolboxView!

    @IBOutlet var descriptionLabelViewConstraint: NSLayoutConstraint!
    @IBOutlet var moviesCollectionViewConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        contentView.isHidden = true
        
        toolboxView.section = .general
        
        loadProfilePicture()
        
        toolboxView.person = person
        
        TmdbService.startPersonConnection(person: person!) { (error: Error?, person: TmdbPerson?) in
            DispatchQueue.main.async {
                self.reloadCharacters()
                self.toolboxView.person = person
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTheme()
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
            
            moobeeViewController.posterImage = cell?.imageView.image
        }
        
        if segue.destination is TeebeeDetailsViewController {
            
            let teebeeViewController:TeebeeDetailsViewController = segue.destination as! TeebeeDetailsViewController
            
            let cell:CastThumbnailCell? = sender as? CastThumbnailCell
            
            teebeeViewController.tvShow = cell?.movie as? TmdbTvShow
            
            teebeeViewController.posterImage = cell?.imageView.image
        }
        
        if segue.destination is ImageGalleryViewController {
            
            let imageGalleryViewController:ImageGalleryViewController = segue.destination as! ImageGalleryViewController
            
            imageGalleryViewController.images = person?.profileImages?.allObjects as? [TmdbImage]
            
            (UIApplication.shared.delegate as! AppDelegate).isPortrait = false
            
        }
    }
    
    override func summaryViewForViewController(_ viewController: UIViewController) -> UIView? {
        
        if viewController is MoobeeDetailsViewController {
            
            var collectionView = toolboxView.moviesCollectionView
            
            if toolboxView.section == .cast {
                collectionView = toolboxView.moviesDetailsCollectionView
            }
            
            for castCell:UICollectionViewCell in collectionView!.visibleCells {
                if (castCell as! CastThumbnailCell).movie?.tmdbId == (viewController as! MoobeeDetailsViewController).movie?.tmdbId {
                    return (castCell as! CastThumbnailCell).imageView
                }
            }
        }
        
        if viewController is TeebeeDetailsViewController {
            
            var collectionView = toolboxView.moviesCollectionView
            
            if toolboxView.section == .cast {
                collectionView = toolboxView.moviesDetailsCollectionView
            }
            
            for castCell:UICollectionViewCell in collectionView!.visibleCells {
                if (castCell as! CastThumbnailCell).movie?.tmdbId == (viewController as! TeebeeDetailsViewController).tvShow?.tmdbId {
                    return (castCell as! CastThumbnailCell).imageView
                }
            }
        }
        
        return nil
    }
    


    func loadProfilePicture() {
        
        profileImageView.loadTmdbProfileWithPath(path: person!.profilePath!, placeholder:profileImage != nil ? profileImage : #imageLiteral(resourceName: "default_image")) { (didLoadImage) in
            if didLoadImage {
                self.reloadTheme()
            }
        }
        
        if profileImage != nil {
            reloadTheme()
        }
        
    }
    
    func reloadTheme() {
        let topBarLuminosity: CGFloat = self.profileImageView.image?.topBarLuminosity() ?? 0.0
        statusBarStyle = topBarLuminosity <= 0.60 ? .lightContent : .default;
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
        self.toolboxView.moviesDetailsCollectionView.reloadData()
        self.moviesCollectionViewConstraint.constant = self.toolboxView.moviesDetailsCollectionView.contentSize.height
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        contentView.isHidden = true
        hideDetailsViewController()
    }
    
    @IBAction func descriptionButtonPressed(_ sender: UIButton) {
        toolboxView.section = .description
        self.descriptionLabelViewConstraint.constant = self.toolboxView.descriptionTextView.contentSize.height
    }
    
    @IBAction func moviesButtonPressed(_ sender: UIButton) {
        toolboxView.section = .cast
        self.moviesCollectionViewConstraint.constant = self.toolboxView.moviesDetailsCollectionView.contentSize.height
    }
    
    @IBAction func photosButtonPressed(_ sender: UIButton) {
        toolboxView.section = .photos
    }
    
    @IBAction func generalButtonPressed(_ sender: UIButton) {
        toolboxView.section = .general
    }

    
    @IBAction func closeToolboxButtonPressed(_ sender: Any) {
        if toolboxView.isVisible {
            toolboxView.hideFullToolbox()
        }
        else {
            toolboxView.showFullToolbox()
        }
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
        
        let character:TmdbCharacter = (characters?[indexPath.row])!
        cell.movie = character.movie
        cell.character = character
        cell.applyTheme(lightTheme: toolboxView.lightTheme)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let character:TmdbCharacter = (characters?[indexPath.row])!
        
        if character.movie is TmdbMovie {
            performSegue(withIdentifier: "MovieDetailsSegue", sender: collectionView.cellForItem(at: indexPath))
        }
        
        if character.movie is TmdbTvShow {
            performSegue(withIdentifier: "TvShowDetailsSegue", sender: collectionView.cellForItem(at: indexPath))
        }
        
    }
    
}
