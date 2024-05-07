//
//  TodayViewController.swift
//  Today
//
//  Created by Radu Banea on 01/11/2018.
//  Copyright © 2018 Gogo's Lab. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var placeholderLabel: UILabel!
    
    var episodes:[Teebee.Episode] = [Teebee.Episode]()
    var shows:[[Teebee.Episode]] = [[Teebee.Episode]]()
    let episodesPerRow:Int = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        initConsole()
                
        episodes = WidgetManager.episodes
        shows = Array(Dictionary(grouping: episodes, by: {$0.season!.teebee!.tmdbId }).values)
        
        collectionView.reloadData()
        placeholderLabel.isHidden = episodes.count > 0
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = episodes.count > episodesPerRow ? .expanded : .compact
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        collectionView.reloadData()
        placeholderLabel.isHidden = episodes.count > 0
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = episodes.count > episodesPerRow ? .expanded : .compact
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = maxSize
        } else {
            self.preferredContentSize = CGSize(width: maxSize.width, height: prefferedHeight)
        }
        collectionView.reloadData()
        placeholderLabel.isHidden = episodes.count > 0
    }
    
    var prefferedHeight:CGFloat {
        get {
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            
            let rowHeight = layout.itemSize.height
            
            let rowsCount = (episodes.count - 1) / episodesPerRow + 1
            
            let height = layout.sectionInset.bottom + layout.sectionInset.top + layout.minimumLineSpacing * CGFloat(rowsCount - 1)
            
            return rowHeight * CGFloat(rowsCount) + height + 10
        }
    }
    
    var showCompact:Bool {
        get {
            return (episodes.count > episodesPerRow) && (extensionContext?.widgetActiveDisplayMode ?? .compact == .compact)
        }
    }
    
    var cellsCount:Int {
        return showCompact ? shows.count : episodes.count
    }
}

extension TodayViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return cellsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellsCount > 2 ? "TvEpisodeCell" : "TvEpisodeBigCell", for: indexPath) as! TvEpisodeCell
        
        if showCompact {
            let episodes = shows[indexPath.row]
            cell.episode = episodes.first
            if episodes.count > 1 {
                cell.titleLabel.text = "\(episodes.count) \(cellsCount > 2 ? "EP" : "Episodes")"
            }
        }
        else {
            cell.episode = episodes[indexPath.row]
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let episodesPerRow = cellsCount > 2 ? self.episodesPerRow : cellsCount
        
        var leftWidth = collectionView.frame.width
        leftWidth -= (layout.sectionInset.left + layout.sectionInset.right)
        leftWidth -= (CGFloat(episodesPerRow - 1) * layout.minimumInteritemSpacing)
        
        
        return CGSize(width: leftWidth / CGFloat(episodesPerRow), height: layout.itemSize.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let episode = showCompact ? shows[indexPath.row].first! : episodes[indexPath.row]
        let myAppUrl = URL(string: "moobeez://teebee?id=\(episode.season!.teebee!.tmdbId)&season=\(episode.season!.number)&episode=\(episode.number)")!
        extensionContext?.open(myAppUrl, completionHandler: { (_) in
            
        })

    }
    
}
