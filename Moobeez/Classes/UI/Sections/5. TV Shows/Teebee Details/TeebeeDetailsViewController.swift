//
//  TeebeeDetailsViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 20/09/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
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
    @IBOutlet var episodesTableView: UITableView!
    
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
            
            starsView.rating = CGFloat(teebee?.rating ?? 2.5)
            starsView.updateHandler = {
                self.teebee?.rating = Float(self.starsView.rating)
                
                MoobeezManager.shared.save()
            }
            
            let nextEpisode:Teebee.Episode? = teebee?.nextEpisode
            
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
        
        guard let teebee = teebee else {
            return
        }
        
        let watchedEpisodesCount:NSInteger = teebee.watchedEpisodesCount
        
        for cell:UIView in sawTvShowViews {
            cell.isHidden = (watchedEpisodesCount == 0)
        }
        
        for cell:UIView in didntTvShowViews {
            cell.isHidden = (watchedEpisodesCount > 0)
        }
        
        if watchedEpisodesCount > 0 && teebee.rating < 0 {
            teebee.rating = 2.5
            starsView.rating = CGFloat(teebee.rating)
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

    var tvShow:Tmdb.TvShow?
    var teebee:Teebee?
    
    var posterImage:UIImage?
    
    @IBOutlet var posterImageView:UIImageView!

    @IBOutlet var contentView:UIView!
    
    @IBOutlet var toolboxView: TeebeeToolboxView!
    
    @IBOutlet var addRemoveButton:UIButton!
    
    @IBOutlet var favoriteButton: UIButton!
    
    @IBOutlet var descriptionTextViewConstraint: NSLayoutConstraint!
    @IBOutlet var castCollectionViewConstraint: NSLayoutConstraint!
    @IBOutlet var episodesTableViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var episodesSegmentedControl: UISegmentedControl!
    
    var episodesManager:EpisodesList?
    
    var characters:[Tmdb.Character] = []
    
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
            teebee = Teebee.fetchTeebeeWithTmdbId((tvShow?.id)!)
            
            if teebee == nil {
                teebee = Teebee(tmdbTvShow: tvShow!)
            }
        }
        else {
            return
        }
        
        loadPoster()
        
        if tvShow != nil {
            TmdbService.startTvShowConnection(tvShow: tvShow!) { (error: Error?, tvShow: Tmdb.TvShow?) in
                DispatchQueue.main.async {
                    self.teebee?.tvShow = tvShow
                    self.reloadTvShow()
                }
            }
        }
        else {
            TmdbService.startTvShowConnection(tmdbId: (teebee?.tmdbId)!) { (error: Error?, tvShow: Tmdb.TvShow?) in
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
        toolboxView.episodesTableView.dataSource = episodesManager
        toolboxView.episodesTableView.delegate = episodesManager
        
        
    }
    
    @objc func reloadTeebee () {
        toolboxView.teebee = teebee
        addRemoveButton.setImage(teebee?.temporary ?? true == false ? #imageLiteral(resourceName: "delete_button") : #imageLiteral(resourceName: "add_button") , for: UIControl.State.normal)
        favoriteButton.isSelected = (teebee?.isFavorite)!
        
        characters = (teebee?.tvShow?.characters ?? tvShow?.characters ?? []).sorted(by: { c1, c2 in
            c1.castId < c2.castId
        })
        toolboxView.castCollectionView.reloadData()
    }
    
    func reloadTvShow() {
        self.toolboxView.castCollectionView.reloadData()
        self.toolboxView.castDetailsCollectionView.reloadData()
        self.castCollectionViewConstraint.constant = self.toolboxView.castDetailsCollectionView.contentSize.height
        self.loadPoster()
        self.toolboxView.descriptionTextView.text = tvShow?.overview
        
        episodesManager?.parent = self
        self.toolboxView.episodesTableView.reloadData()
        
        characters = (teebee?.tvShow?.characters ?? tvShow?.characters ?? []).sorted(by: { c1, c2 in
            c1.castId < c2.castId
        })
        toolboxView.castCollectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
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
            
//            imageGalleryViewController.images = tvShow?.backdropImages?.allObjects as? [Tmdb.Image]
            
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
                if (castCell as! CastThumbnailCell).person?.id == (viewController as! PersonDetailsViewController).person?.id {
                    return (castCell as! CastThumbnailCell).imageView
                }
            }
        }
        
        return nil
    }
    
    func loadPoster() {
        
        posterImageView.loadTmdbPosterWithPath(path: teebee!.posterPath, placeholder:posterImage != nil ? posterImage : #imageLiteral(resourceName: "default_image")) { (didLoadImage) in
            if didLoadImage {
                self.reloadTheme()
            }
        }
        
        if posterImage != nil {
            reloadTheme()
        }
    }
    
    func reloadTheme() {
        let topBarLuminosity: CGFloat = self.posterImageView.image?.topBarLuminosity() ?? 0.0
        statusBarStyle = topBarLuminosity <= 0.60 ? .lightContent : .default;
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
        self.toolboxView.episodesTableView.reloadData()
    }
    
    @IBAction func generalButtonPressed(_ sender: UIButton) {
        toolboxView.section = .general
    }
    
    @IBAction func addRemoveButtonPressed(_ sender: UIButton) {
        
        if teebee?.temporary ?? true {
            MoobeezManager.shared.addTeebee(teebee!)
        }
        else {
           MoobeezManager.shared.removeTeebee(teebee!)
        }
        
        addRemoveButton.setImage(teebee?.temporary ?? true == false ? #imageLiteral(resourceName: "delete_button") : #imageLiteral(resourceName: "add_button") , for: UIControl.State.normal)
        
        if let searchViewController = presenting as? SearchTVsViewController {
            presenting = searchViewController.presenting
            searchViewController.hideDetailsViewController()
        }
    }
    
    @IBAction func sawTvShowButtonPressed(_ sender: UIButton) {
        teebee?.markAsWatched()
        MoobeezManager.shared.addTeebee(teebee!)
        toolboxView.reloadTypeCells()
        
        if let searchViewController = presenting as? SearchTVsViewController {
            presenting = searchViewController.presenting
            searchViewController.hideDetailsViewController()
        }
    }

    @IBAction func closeToolboxButtonPressed(_ sender: Any) {
        if toolboxView.isVisible {
            toolboxView.hideFullToolbox()
        }
        else {
            toolboxView.showFullToolbox()
        }
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        teebee?.isFavorite = !(teebee?.isFavorite)!
        
        sender.isSelected = (teebee?.isFavorite)!
        
        MoobeezManager.shared.save()
        
        NotificationCenter.default.post(name: .TeebeezDidChangeNotification, object: teebee?.tmdbId)
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
        
        UIApplication.shared.open((tvShow?.imdbUrl)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
    @IBAction func episodesSegmentedControlValueChanged(_ sender: Any) {
        if episodesSegmentedControl.selectedSegmentIndex == 0 && episodesManager?.selectedSeason != nil && episodesManager!.selectedSeason!.watched {
            episodesManager?.selectedSeason = nil
        }
        
        toolboxView.episodesTableView.reloadData()
    }
    
}

extension TeebeeDetailsViewController {
    
    
    
}

extension TeebeeDetailsViewController : UITextFieldDelegate {
    
}


extension TeebeeDetailsViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return tvShow?.characters.count ?? 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:CastThumbnailCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as! CastThumbnailCell
        
        let character:Tmdb.Character = tvShow!.characters[indexPath.row]
        cell.person = character.person
        cell.character = character
        cell.applyTheme(lightTheme: toolboxView.lightTheme)
        
        return cell
    }
    
}

class EpisodesList : NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var parent:TeebeeDetailsViewController?
    {
        didSet
        {
            seasons = parent?.teebee?.seasons.filter({ season in
                season.episodes.count > 0
            }).sorted(by: { s1, s2 in s1.number < s2.number })
            
            let unwatchedSeasons = seasons?.filter({ (season) -> Bool in
                return !season.watched
            })
            
            if unwatchedSeasons?.count == 1 {
                selectedSeason = unwatchedSeasons?.first
            }
            else if unwatchedSeasons?.count == 0 {
                parent?.episodesSegmentedControl.selectedSegmentIndex = 1
            }
        }
    }
    
    var selectedSeason:Teebee.Season?
    {
        didSet
        {
            guard let selectedSeason = selectedSeason else {
                episodes = nil
                return
            }
            
            episodes = selectedSeason.episodes.filter({ e in
                e.releaseDate != nil
            }).sorted(by: { e1, e2 in
                e1.releaseDate!.compare(e2.releaseDate!) == .orderedAscending
            }).filter({ e in
                e.releaseDate!.timeIntervalSince(.distantPast) > 100
            })
        }
    }
    
    var seasons:[Teebee.Season]?
    var episodes:[Teebee.Episode]?
    
    var teebee:Teebee? {
        get {
            return parent?.teebee
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard seasons != nil else {
            return 0
        }
        
        return seasons!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let seasons = seasons else {
            return 0
        }
        
        guard let selectedSeason = selectedSeason else {
            return 1
        }
        
        guard selectedSeason.tmdbId == seasons[section].tmdbId else {
            return 0
        }
        
        return episodes!.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard indexPath.row > 0 else {
            
            let cell:SeasonCell = tableView.dequeueReusableCell(withIdentifier: "SeasonCell") as! SeasonCell
            
            let season:Teebee.Season = seasons![indexPath.section]
            
            cell.applyTheme(lightTheme: (parent?.toolboxView.lightTheme)!)
            
            cell.season = season
            
            return cell
            
        }
        
        let cell:EpisodeCell = tableView.dequeueReusableCell(withIdentifier: "EpisodeCell") as! EpisodeCell
        
        let episode:Teebee.Episode = (episodes)![indexPath.row - 1]
        cell.applyTheme(lightTheme: (parent?.toolboxView.lightTheme)!)
        
        cell.episode = episode
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard parent?.episodesSegmentedControl.selectedSegmentIndex == 0 else {
            return tableView.rowHeight
        }
        
        guard indexPath.row > 0 else {
            
            let season:Teebee.Season = seasons![indexPath.section]
            
            return season.watched ? 0 : tableView.rowHeight
        }
        
        let episode:Teebee.Episode = (episodes)![indexPath.row - 1]
        
        return episode.watched ? 0 : tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.row == 0 else {
            return
        }
        
        let season = seasons![indexPath.section]
        
        if selectedSeason?.tmdbId != season.tmdbId {
            selectedSeason = season
        }
        else {
            selectedSeason = nil
        }
        
        parent?.toolboxView.episodesTableView.reloadData()
        
        if selectedSeason != nil {
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
