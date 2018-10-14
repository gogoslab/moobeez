//
//  MoobeeViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 20/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

enum MoobeeSection:Int {
    case general = 0;
    case description = 1;
    case cast = 2;
    case trailers = 3;
    case photos = 4;
}

class MoobeeToolboxView : ToolboxView {
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var starsView: StarsView!
    @IBOutlet var seenDateLabel: UILabel!
    
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var datePickerView: UIView!
    
    @IBOutlet var watchlistButtonTileLabels: [UILabel]!
    @IBOutlet var watchlistButton: UIButton!
    
    @IBOutlet var castCollectionView: UICollectionView!
    @IBOutlet var castDetailsCollectionView: UICollectionView!
    
    @IBOutlet var descriptionButton: UIButton!
    @IBOutlet var castButton: UIButton!
    @IBOutlet var photosButton: UIButton!
    @IBOutlet var trailersButton: UIButton!
    @IBOutlet var generalButton: UIButton!

    @IBOutlet var sawMovieViews: [UIView]!
    @IBOutlet var didntSawMovieViews: [UIView]!
    
    @IBOutlet var descriptionViews: [UIView]!
    @IBOutlet var castViews: [UIView]!
    @IBOutlet var trailersViews: [UIView]!
    @IBOutlet var photosViews: [UIView]!

    @IBOutlet var descriptionTextView: UITextView!
    
    @IBOutlet var pickerViewConstraint: NSLayoutConstraint!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var moobee:Moobee? {
        
        didSet {
            
            nameTextField.text = moobee?.name
            
            starsView.rating = CGFloat(moobee?.rating ?? 0.0)
            starsView.updateHandler = {
                self.moobee?.rating = Float(self.starsView.rating)
                
                MoobeezManager.shared.save()
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            seenDateLabel.text = dateFormatter.string(from: (moobee?.date)!)
            reloadTypeCells()
        }
    }
    
    func reloadTypeCells() {
        
        guard section == .general else {
            return
        }
        
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
    
    var section:MoobeeSection = .general {
        willSet {
            self.tabButtons[section.rawValue].isSelected = false
        }
        didSet {
            self.tabButtons[section.rawValue].isSelected = true
            switch section {
            case .general:
                self.cells = self.generalViews
                reloadTypeCells()
            case .description:
                self.cells = self.descriptionViews
            case .cast:
                self.cells = self.castViews
            case .trailers:
                self.cells = self.trailersViews
            case .photos:
                self.cells = self.photosViews
            }
            if isVisible == false {
                showFullToolbox(animated: false)
            }
        }
    }    
    
    @IBAction func showHideDatePicker(_ sender: Any) {
        pickerViewConstraint.constant = (pickerViewConstraint.constant > 0 ? 0 : 150)
        if pickerViewConstraint.constant > 0 {
            datePicker.date = (moobee?.date)!
        }
    }
    
    @IBAction func datePickerValueChanged(_ sender: Any) {
        moobee?.date = datePicker.date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        seenDateLabel.text = dateFormatter.string(from: (moobee?.date)!)
        
        NotificationCenter.default.post(name: .MoobeezDidChangeNotification, object: moobee?.tmdbId)
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
    
    @IBOutlet var favoriteButton: UIButton!
    
    @IBOutlet var descriptionTextViewConstraint: NSLayoutConstraint!
    @IBOutlet var castCollectionViewConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        contentView.isHidden = true
        
        toolboxView.section = .general
    
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
        
        favoriteButton.isSelected = (moobee?.isFavorite)!
        
        loadPoster()
        
        if movie != nil {
            TmdbService.startMovieConnection(movie: movie!) { (error: Error?, movie: TmdbMovie?) in
                DispatchQueue.main.async {
                    self.moobee?.movie = movie
                    self.reloadMovie()
                }
            }
        }
        else {
            TmdbService.startMovieConnection(tmdbId: (moobee?.tmdbId)!) { (error: Error?, movie: TmdbMovie?) in
                DispatchQueue.main.async {
                    self.movie = movie
                    self.reloadMovie()
                }
            }
        }
        
        reloadMoobee()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMoobee), name: .BeeDidChangeNotification, object:moobee?.tmdbId)
    }
    
    @objc func reloadMoobee () {
        toolboxView.moobee = moobee
        addRemoveButton.isHidden = moobee?.moobeeType == MoobeeType.new
    }
    
    func reloadMovie() {
        self.toolboxView.castCollectionView.reloadData()
        self.toolboxView.castDetailsCollectionView.reloadData()
        self.castCollectionViewConstraint.constant = self.toolboxView.castDetailsCollectionView.contentSize.height
        self.loadPoster()
        self.toolboxView.descriptionTextView.text = movie?.overview
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
        if segue.destination is PersonDetailsViewController {
            
            let personViewController:PersonDetailsViewController = segue.destination as! PersonDetailsViewController
            
            let cell:CastThumbnailCell? = sender as? CastThumbnailCell
            
            personViewController.person = cell?.person
            
            personViewController.profileImage = cell?.imageView.image
        }
        
        if segue.destination is ImageGalleryViewController {
            
            let imageGalleryViewController:ImageGalleryViewController = segue.destination as! ImageGalleryViewController
            
            imageGalleryViewController.images = movie?.backdropImages?.allObjects as? [TmdbImage]
            
            (UIApplication.shared.delegate as! AppDelegate).isPortrait = false
            
        }
        
        if segue.destination is YoutubeVideoViewController {
            
            let youtubeVideoViewController:YoutubeVideoViewController = segue.destination as! YoutubeVideoViewController
            
            youtubeVideoViewController.trailerPath = movie?.trailerPath
            
            (UIApplication.shared.delegate as! AppDelegate).isLandscape = true
            
        }
        
        if segue.destination is VideoViewController {
            
            let videoViewController:VideoViewController = segue.destination as! VideoViewController
            
            videoViewController.trailerPath = movie?.trailerPath
            
            (UIApplication.shared.delegate as! AppDelegate).isLandscape = true
            
        }
    }
    
    override func summaryViewForViewController(_ viewController: UIViewController) -> UIView? {
        
        if viewController is PersonDetailsViewController {
            var collectionView = toolboxView.castCollectionView
            
            if toolboxView.section == .cast {
                collectionView = toolboxView.castDetailsCollectionView
            }
            
            for castCell:UICollectionViewCell in collectionView!.visibleCells {
                if (castCell as! CastThumbnailCell).person?.personId == (viewController as! PersonDetailsViewController).person?.personId {
                    return (castCell as! CastThumbnailCell).imageView
                }
            }
        }
        
        return nil
    }
    
    func loadPoster() {
        
        if posterImage != nil {
            reloadTheme()
        }
        
        posterImageView.loadTmdbPosterWithPath(path: moobee!.posterPath, placeholder:posterImage != nil ? posterImage : #imageLiteral(resourceName: "default_image")) { (didLoadImage) in
            if didLoadImage {
                self.reloadTheme()
            }
        }
    }
    
    func reloadTheme() {
        let topBarLuminosity: CGFloat = self.posterImageView.image?.topBarLuminosity() ?? 0.0
        statusBarStyle = topBarLuminosity <= 0.60 ? .lightContent : .default;
    }
    

    @IBAction func backButtonPressed(_ sender: UIButton) {
        MoobeezManager.shared.save()
        NotificationCenter.default.post(name: .BeeDidChangeNotification, object: moobee?.tmdbId)
        contentView.isHidden = true
        hideDetailsViewController()
    }
    
    @IBAction func watchlistButtonPressed(_ sender: UIButton) {
        if moobee?.moobeeType != MoobeeType.watchlist {
            moobee?.moobeeType = MoobeeType.watchlist
        }
        else {
            moobee?.moobeeType = MoobeeType.new
        }
        toolboxView.reloadTypeCells()
        
        MoobeezManager.shared.addMoobee(moobee!)
        MoobeezManager.shared.save()
        addRemoveButton.isHidden = moobee?.moobeeType == MoobeeType.new

        if let searchViewController = presenting as? SearchMoviesViewController {
            presenting = searchViewController.presenting
            searchViewController.hideDetailsViewController()
            
            if let moobeezViewController = presenting as? MoobeezViewController {
                moobeezViewController.segmentedControl.selectedSegmentIndex = 1
                moobeezViewController.reloadItems()
            }
        }
    }
    
    @IBAction func sawMovieButtonPressed(_ sender: UIButton) {
        moobee?.moobeeType = MoobeeType.seen
        moobee?.rating = 2.5
        moobee?.date = Date()
        toolboxView.moobee = moobee
        
        MoobeezManager.shared.addMoobee(moobee!)
        MoobeezManager.shared.save()
        addRemoveButton.isHidden = moobee?.moobeeType == MoobeeType.new

        if let searchViewController = presenting as? SearchMoviesViewController {
            presenting = searchViewController.presenting
            searchViewController.hideDetailsViewController()
            
            if let moobeezViewController = presenting as? MoobeezViewController {
                moobeezViewController.segmentedControl.selectedSegmentIndex = 0
                moobeezViewController.reloadItems()
            }
        }

    }
    
    @IBAction func descriptionButtonPressed(_ sender: UIButton) {
        toolboxView.section = .description
        self.descriptionTextViewConstraint.constant = self.toolboxView.descriptionTextView.contentSize.height
    }
    
    @IBAction func castButtonPressed(_ sender: UIButton) {
        toolboxView.section = .cast
        self.castCollectionViewConstraint.constant = self.toolboxView.castDetailsCollectionView.contentSize.height
    }
    
    @IBAction func photosButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func trailersButtonPressed(_ sender: UIButton) {
        if movie?.trailerType == TrailerType.youtube.rawValue {
            performSegue(withIdentifier: "YoutubeViewSegue", sender: nil)
        }
        
        if movie?.trailerType == TrailerType.quicktime.rawValue {
            performSegue(withIdentifier: "VideoViewSegue", sender: nil)
        }
    }

    @IBAction func generalButtonPressed(_ sender: UIButton) {
        toolboxView.section = .general
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        moobee?.isFavorite = !(moobee?.isFavorite)!

        sender.isSelected = (moobee?.isFavorite)!

        NotificationCenter.default.post(name: .MoobeezDidChangeNotification, object: moobee?.tmdbId)
    }
    
    @IBAction func addRemoveButtonPressed(_ sender: UIButton) {
        moobee?.moobeeType = MoobeeType.new
        NotificationCenter.default.post(name: .MoobeezDidChangeNotification, object: moobee?.tmdbId)
        reloadMoobee()
    }

    @IBAction func closeToolboxButtonPressed(_ sender: Any) {
        if toolboxView.isVisible {
            toolboxView.hideFullToolbox()
        }
        else {
            toolboxView.showFullToolbox()
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        
        guard movie != nil && movie?.imdbUrl != nil else {
            return
        }
        
        let controller:UIActivityViewController = UIActivityViewController(activityItems: [(movie?.imdbUrl)!], applicationActivities: nil)
        controller.modalPresentationStyle = .popover
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func imdbButtonPressed(_ sender: UIButton) {
        
        guard movie != nil && movie?.imdbUrl != nil else {
            return
        }
        
        UIApplication.shared.open((movie?.imdbUrl)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
}

extension MoobeeDetailsViewController {
    
    
    
}

extension MoobeeDetailsViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}


extension MoobeeDetailsViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return movie?.characters?.count ?? 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:CastThumbnailCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as! CastThumbnailCell
        
        let character:TmdbCharacter = movie?.characters?[indexPath.row] as! TmdbCharacter
        cell.person = character.person
        cell.character = character
        cell.applyTheme(lightTheme: toolboxView.lightTheme)
        
        return cell
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
