//
//  TeebeeDetailsViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 20/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

enum TeebeeSection:Int {
    case general = 0;
    case description = 1;
    case cast = 2;
    case photos = 3;
    case episodes = 4;
}

class TeebeeToolboxView : ToolboxView {
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var starsView: StarsView!
    @IBOutlet var nextEpisodeLabel: UILabel!
    
    @IBOutlet var seasonsCountLabel: UILabel!
    @IBOutlet var episodesCountLabel: UILabel!
    
    @IBOutlet var castCollectionView: UICollectionView!
    @IBOutlet var castDetailsCollectionView: UICollectionView!
    @IBOutlet var episodesCollectionView: UICollectionView!
    
    @IBOutlet var descriptionButton: UIButton!
    @IBOutlet var castButton: UIButton!
    @IBOutlet var photosButton: UIButton!
    @IBOutlet var episodesButton: UIButton!
    @IBOutlet var generalButton: UIButton!

    @IBOutlet var sawTvShowViews: [UIView]!
    @IBOutlet var didntTvShowViews: [UIView]!
    
    @IBOutlet var descriptionViews: [UIView]!
    @IBOutlet var castViews: [UIView]!
    @IBOutlet var episodesViews: [UIView]!
    @IBOutlet var photosViews: [UIView]!

    @IBOutlet var descriptionTextView: UITextView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var teebee:Teebee? {
        
        didSet {
            
            nameTextField.text = teebee?.name
            
            starsView.rating = CGFloat(teebee?.rating ?? 0.0)
            starsView.updateHandler = {
                self.teebee?.rating = Float(self.starsView.rating)
                
                MoobeezManager.shared.save()
            }
            
            let nextEpisode:TeebeeEpisode? = teebee?.nextEpisode
            
            if nextEpisode == nil {
                nextEpisodeLabel.text = "Next episode to watch: Unknown date"
            }
            else {
                let nextEpisodeDate = (nextEpisode?.releaseDate)!
                
                let nextEpisodeString = String(format:"Next episode to watch: E%02d/S%02d", (nextEpisode?.number)!, (nextEpisode?.season?.number)!)
                
                if nextEpisodeDate.compare(Date()) == ComparisonResult.orderedAscending {
                    nextEpisodeLabel.text = nextEpisodeString
                }
                else {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd MMM"

                    nextEpisodeLabel.text = nextEpisodeString.appending(" on \(dateFormatter.string(from: (nextEpisode?.releaseDate)!))")
                }
            }
            reloadTypeCells()
        }
    }
    
    func reloadTypeCells() {
        
        guard section == .general else {
            return
        }
        
        let watchedEpisodesCount:NSInteger = teebee?.watchedEpisodesCount ?? 0
        
        for cell:UIView in sawTvShowViews {
            cell.isHidden = (watchedEpisodesCount == 0)
        }
        
        for cell:UIView in didntTvShowViews {
            cell.isHidden = (watchedEpisodesCount > 0)
        }
    }
    
    var section:TeebeeSection = .general {
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
            case .photos:
                self.cells = self.photosViews
            case .episodes:
                self.cells = self.episodesViews
            }
            
            if isVisible == false {
                showFullToolbox(animated: false)
            }
        }
    }    
}

class TeebeeDetailsViewController: MBViewController {

    var tvShow:TmdbTvShow?
    var teebee:Teebee?
    
    var posterImage:UIImage?
    
    @IBOutlet var posterImageView:UIImageView!

    @IBOutlet var contentView:UIView!
    
    @IBOutlet var toolboxView: TeebeeToolboxView!
    
    @IBOutlet var addRemoveButton:UIButton!
    
    @IBOutlet var favoriteButton: UIButton!
    
    @IBOutlet var descriptionTextViewConstraint: NSLayoutConstraint!
    @IBOutlet var castCollectionViewConstraint: NSLayoutConstraint!
    @IBOutlet var episodesCollectionViewConstraint: NSLayoutConstraint!
    
    var episodesManager:EpisodesList?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        contentView.isHidden = true
        
        toolboxView.section = .general
    
        assert(teebee != nil || tvShow != nil, "Teebee and tvShow can't both be nil")
        
        if teebee != nil {
            tvShow = teebee?.tvShow
        }
        else if tvShow != nil {
            teebee = Teebee.fetchTeebeeWithTmdbId((tvShow?.tmdbId)!)
            
            if teebee == nil {
                teebee = Teebee(tmdbTvShow: tvShow!)
            }
        }
        else {
            return
        }
        
        loadPoster()
        
        if tvShow != nil {
            TmdbService.startTvShowConnection(tvShow: tvShow!) { (error: Error?, tvShow: TmdbTvShow?) in
                DispatchQueue.main.async {
                    self.teebee?.tvShow = tvShow
                    self.reloadTvShow()
                }
            }
        }
        else {
            TmdbService.startTvShowConnection(tmdbId: (teebee?.tmdbId)!) { (error: Error?, tvShow: TmdbTvShow?) in
                DispatchQueue.main.async {
                    self.tvShow = tvShow
                    self.teebee?.tvShow = tvShow
                    self.reloadTvShow()
                }
            }
        }
        
        reloadTeebee()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTeebee), name: .BeeDidChangeNotification, object:teebee?.tmdbId)
        
        episodesManager = EpisodesList()
        episodesManager?.parent = self
        toolboxView.episodesCollectionView.dataSource = episodesManager
        toolboxView.episodesCollectionView.delegate = episodesManager
    }
    
    @objc func reloadTeebee () {
        toolboxView.teebee = teebee
        addRemoveButton.setImage(teebee?.managedObjectContext != nil ? #imageLiteral(resourceName: "delete_button") : #imageLiteral(resourceName: "add_button") , for: UIControlState.normal)
    }
    
    func reloadTvShow() {
        self.toolboxView.castCollectionView.reloadData()
        self.toolboxView.castDetailsCollectionView.reloadData()
        self.castCollectionViewConstraint.constant = self.toolboxView.castDetailsCollectionView.contentSize.height
        self.episodesCollectionViewConstraint.constant = self.toolboxView.episodesCollectionView.contentSize.height
        self.loadPoster()
        self.toolboxView.descriptionTextView.text = tvShow?.overview
        
        episodesManager?.parent = self
        self.toolboxView.episodesCollectionView.reloadData()
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
            
            imageGalleryViewController.images = tvShow?.backdropImages?.allObjects as? [TmdbImage]
            
            (UIApplication.shared.delegate as! AppDelegate).isPortrait = false
            
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
        
        posterImageView.loadTmdbPosterWithPath(path: teebee!.posterPath!, placeholder:posterImage != nil ? posterImage : #imageLiteral(resourceName: "default_image")) { (didLoadImage) in
            if didLoadImage {
                self.reloadTheme()
            }
        }
        
        if posterImage != nil {
            reloadTheme()
        }
    }
    
    func reloadTheme() {
        let bottomHalfLuminosity: CGFloat = self.posterImageView.image?.bottomHalfLuminosity() ?? 0.0
        self.toolboxView.applyTheme(lightTheme: bottomHalfLuminosity <= 0.60);
        
        let topBarLuminosity: CGFloat = self.posterImageView.image?.topBarLuminosity() ?? 0.0
        UIApplication.shared.statusBarStyle = topBarLuminosity <= 0.60 ? .lightContent : .default;
    }
    

    @IBAction func backButtonPressed(_ sender: UIButton) {
        MoobeezManager.shared.save()
        NotificationCenter.default.post(name: .BeeDidChangeNotification, object: teebee?.tmdbId)
        contentView.isHidden = true
        hideDetailsViewController()
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
    
    @IBAction func episodesButtonPressed(_ sender: UIButton) {
        toolboxView.section = .episodes
        self.toolboxView.episodesCollectionView.reloadData()
        self.episodesCollectionViewConstraint.constant = self.toolboxView.episodesCollectionView.contentSize.height
    }
    
    @IBAction func generalButtonPressed(_ sender: UIButton) {
        toolboxView.section = .general
    }
    
    @IBAction func addRemoveButtonPressed(_ sender: UIButton) {
        
        if teebee?.managedObjectContext == nil {
            MoobeezManager.shared.addTeebee(teebee!)
        }
        else {
           MoobeezManager.shared.removeTeebee(teebee!)
        }
        
        addRemoveButton.setImage(teebee?.managedObjectContext != nil ? #imageLiteral(resourceName: "delete_button") : #imageLiteral(resourceName: "add_button") , for: UIControlState.normal)
    }
    
    @IBAction func sawTvShowButtonPressed(_ sender: UIButton) {
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
        
        guard tvShow != nil && tvShow?.imdbUrl != nil else {
            return
        }
        
        let controller:UIActivityViewController = UIActivityViewController(activityItems: [(tvShow?.imdbUrl)!], applicationActivities: nil)
        controller.modalPresentationStyle = .popover
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func imdbButtonPressed(_ sender: UIButton) {
        
        guard tvShow != nil && tvShow?.imdbUrl != nil else {
            return
        }
        
        UIApplication.shared.open((tvShow?.imdbUrl)!, options: [:], completionHandler: nil)
    }
    
}

extension TeebeeDetailsViewController {
    
    
    
}

extension TeebeeDetailsViewController : UITextFieldDelegate {
    
}


extension TeebeeDetailsViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return tvShow?.characters?.count ?? 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:CastThumbnailCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as! CastThumbnailCell
        
        let character:TmdbCharacter = tvShow?.characters?[indexPath.row] as! TmdbCharacter
        cell.person = character.person
        cell.character = character
        cell.applyTheme(lightTheme: toolboxView.lightTheme)
        
        return cell
    }
    
}

class EpisodesList : NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var parent:TeebeeDetailsViewController?
    {
        didSet
        {
            seasons = parent?.teebee?.seasons?.filtered(using: NSPredicate(block: { (season, key) -> Bool in
                return ((season as! TeebeeSeason).episodes?.count)! > 0
            })).array as? [TeebeeSeason]
        }
    }
    
    var selectedSeason:TeebeeSeason?
    {
        didSet
        {
            if selectedSeason == nil {
                episodes = nil
                return
            }
            
            episodes = selectedSeason?.episodes?.sortedArray(using: [NSSortDescriptor(key: "releaseDate", ascending: true)]) as? [TeebeeEpisode]
        }
    }
    
    var seasons:[TeebeeSeason]?
    var episodes:[TeebeeEpisode]?
    
    var teebee:Teebee? {
        get {
            return parent?.teebee
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard teebee != nil else {
            return 0
        }
        
        guard seasons != nil else {
            return 0
        }
        
        switch section {
        case 0:
            return selectedSeason != nil ? 1 : (seasons?.count ?? 0)
        case 1:
            return selectedSeason != nil ? (episodes?.count)! : 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            let cell:SeasonCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeasonCell", for: indexPath) as! SeasonCell
            
            let season:TeebeeSeason = selectedSeason != nil ? selectedSeason! : (seasons?[indexPath.row])!
            cell.applyTheme(lightTheme: (parent?.toolboxView.lightTheme)!)
            
            cell.season = season
            
            return cell
        case 1:
            let cell:EpisodeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "EpisodeCell", for: indexPath) as! EpisodeCell
            
            let episode:TeebeeEpisode = (episodes)![indexPath.row]
            cell.applyTheme(lightTheme: (parent?.toolboxView.lightTheme)!)
            
            cell.episode = episode
            
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            if selectedSeason == nil {
                selectedSeason = seasons?[indexPath.row]
            }
            else {
                selectedSeason = nil
            }
            
            collectionView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                self.parent?.episodesCollectionViewConstraint.constant = (self.parent?.toolboxView.episodesCollectionView.contentSize.height)!
                UIView.animate(withDuration: 0.1, animations: {
                    self.parent?.toolboxView.maskContentView.layoutIfNeeded()
                })
            })
        }
        
    }
}

