//
//  MoobeeViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 20/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

class MoobeeToolboxView : ToolboxView {
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var starsView: StarsView!
    @IBOutlet var seenDateLabel: UILabel!

    @IBOutlet var watchlistButtonTileLabels: [UILabel]!
    @IBOutlet var watchlistButton: UIButton!
    
    @IBOutlet var castCollectionView: UICollectionView!
    
    @IBOutlet var descriptionButton: UIButton!
    @IBOutlet var castButton: UIButton!
    @IBOutlet var photosButton: UIButton!
    @IBOutlet var trailersButton: UIButton!
    @IBOutlet var favoriteButton: UIButton!

    @IBOutlet var sawMovieViews: [UIView]!
    @IBOutlet var didntSawMovieViews: [UIView]!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var moobee:Moobee? {
        
        didSet {
            
            nameTextField.text = moobee?.name
            
            starsView.rating = CGFloat(moobee?.rating ?? 0.0)
            starsView.updateHandler = {
                self.moobee?.rating = Float(self.starsView.rating)
                
                do {
                    try self.moobee?.managedObjectContext?.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            seenDateLabel.text = dateFormatter.string(from: (moobee?.date)!)
            reloadTypeCells()
        }
    }
    
    func reloadTypeCells() {
        for cell:UIView in sawMovieViews {
            cell.isHidden = (moobee?.moobeeType != MoobeeType.seen)
        }
        
        for cell:UIView in didntSawMovieViews {
            cell.isHidden = (moobee?.moobeeType == MoobeeType.seen)
        }
        
        watchlistButton.isSelected = moobee?.moobeeType == MoobeeType.watchlist
        
        let title:String = (watchlistButton.isSelected ? "remove from watchlist" : "add to watchlist")
        
        let titles = title.components(separatedBy: " ")
        
        for watchlistButtonTileLabel in watchlistButtonTileLabels {
            watchlistButtonTileLabel.text = titles[watchlistButtonTileLabels.index(of: watchlistButtonTileLabel)!]
        }
    }
}

class MoobeeDetailsViewController: MBViewController {

    var movie:TmdbMovie?
    var moobee:Moobee?
    
    var posterImage:UIImage?
    
    @IBOutlet var posterImageView:UIImageView!
    @IBOutlet var contentView:UIView!
    
    @IBOutlet var toolboxView: MoobeeToolboxView!
    
    @IBOutlet var addRemoveButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        contentView.isHidden = true
    
        assert(moobee != nil || movie != nil, "Moobee and movie can't both be nil")
        
        if moobee != nil {
            movie = moobee?.movie
        }
        else if movie != nil {
            moobee = Moobee.fetchMoobeeWithTmdbId((movie?.tmdbId)!)
            
            if moobee == nil {
                moobee = Moobee(tmdbMovie: movie!)
            }
        }
        else {
            return
        }
        
        loadPoster()
        
        if movie != nil {
            TmdbService.startMovieConnection(movie: movie!) { (error: Error?, movie: TmdbMovie?) in
                DispatchQueue.main.async {
                    self.moobee?.movie = movie
                    self.toolboxView.castCollectionView.reloadData()
                    self.loadPoster()
                }
            }
        }
        else {
            TmdbService.startMovieConnection(tmdbId: (moobee?.tmdbId)!) { (error: Error?, movie: TmdbMovie?) in
                DispatchQueue.main.async {
                    self.movie = movie
                    self.moobee?.movie = movie
                    self.toolboxView.castCollectionView.reloadData()
                    self.loadPoster()
                }
            }
        }
        
        reloadMoobee()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMoobee), name: .BeeDidChangeNotification, object:moobee?.tmdbId)
    }
    
    @objc func reloadMoobee () {
        toolboxView.moobee = moobee
        addRemoveButton.setImage(moobee?.managedObjectContext != nil ? #imageLiteral(resourceName: "delete_button") : #imageLiteral(resourceName: "add_button") , for: UIControlState.normal)
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
        if segue.destination is PersonDetailsViewController {
            
            let personViewController:PersonDetailsViewController = segue.destination as! PersonDetailsViewController
            
            let cell:CastThumbnailCell? = sender as? CastThumbnailCell
            
            personViewController.person = cell?.person
        }
    }
    
    override func summaryViewForViewController(_ viewController: UIViewController) -> UIView? {
        
        if viewController is PersonDetailsViewController {
            for castCell:UICollectionViewCell in toolboxView.castCollectionView.visibleCells {
                if (castCell as! CastThumbnailCell).person?.personId == (viewController as! PersonDetailsViewController).person?.personId {
                    return castCell
                }
            }
        }
        
        return nil
    }
    
    func loadPoster() {
        
        posterImageView.loadTmdbPosterWithPath(path: moobee!.posterPath!, placeholder:posterImage) { (didLoadImage) in
            if didLoadImage {
                let bottomHalfLuminosity: CGFloat = self.posterImageView.image?.bottomHalfLuminosity() ?? 0.0
                self.toolboxView.applyTheme(lightTheme: bottomHalfLuminosity <= 0.60);
            }
        }
    }
    

    @IBAction func backButtonPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: .BeeDidChangeNotification, object: moobee?.tmdbId)
        contentView.isHidden = true
        hideDetailsViewController()
    }
    
    @IBAction func watchlistButtonPressed(_ sender: UIButton) {
        if moobee?.moobeeType != MoobeeType.watchlist {
            moobee?.moobeeType = MoobeeType.watchlist
        }
        else {
            moobee?.moobeeType = MoobeeType.none
        }
        toolboxView.reloadTypeCells()
        
        MoobeezManager.shared.addMoobee(moobee!)
        addRemoveButton.setImage(moobee?.managedObjectContext != nil ? #imageLiteral(resourceName: "delete_button") : #imageLiteral(resourceName: "add_button") , for: UIControlState.normal)
        MoobeezManager.shared.save()
    }
    
    @IBAction func sawMovieButtonPressed(_ sender: UIButton) {
        moobee?.moobeeType = MoobeeType.seen
        toolboxView.reloadTypeCells()
        
        MoobeezManager.shared.addMoobee(moobee!)
        addRemoveButton.setImage(moobee?.managedObjectContext != nil ? #imageLiteral(resourceName: "delete_button") : #imageLiteral(resourceName: "add_button") , for: UIControlState.normal)
        MoobeezManager.shared.save()
    }
    
    @IBAction func descriptionButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func castButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func photosButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func trailersButtonPressed(_ sender: UIButton) {
    }

    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func addRemoveButtonPressed(_ sender: UIButton) {
        
        if moobee?.managedObjectContext == nil {
            MoobeezManager.shared.addMoobee(moobee!)
        }
        else {
           MoobeezManager.shared.removeMoobee(moobee!)
        }
        
        addRemoveButton.setImage(moobee?.managedObjectContext != nil ? #imageLiteral(resourceName: "delete_button") : #imageLiteral(resourceName: "add_button") , for: UIControlState.normal)
    }

    @IBAction func posterTapped(_ sender: UITapGestureRecognizer) {
        toolboxView.hideFullToolbox()
    }
    
}

extension MoobeeDetailsViewController {
    
    
    
}

extension MoobeeDetailsViewController : UITextFieldDelegate {
    
}


extension MoobeeDetailsViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return movie?.characters?.count ?? 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:CastThumbnailCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as! CastThumbnailCell
        
        let character:TmdbCharacter = movie?.characters?[indexPath.row] as! TmdbCharacter
        cell.person = character.person
        
        return cell
    }
    
}
