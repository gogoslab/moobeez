//
//  TodayViewController.swift
//  Today
//
//  Created by Radu Banea on 01/11/2018.
//  Copyright © 2018 Gogolabs. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var placeholderLabel: UILabel!
    
    var episodes:[TeebeeEpisode] = [TeebeeEpisode]()
    let episodesPerRow:Int = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        let today = Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: (SettingsManager.shared.addExtraDay ? -24 * 3600 : 0)))
        
        episodes = MoobeezManager.shared.moobeezDatabase.fetch(predicate: NSPredicate(format: "watched == 0 AND releaseDate < %@ AND releaseDate.timeIntervalSince1970 > 100", today as CVarArg), sort: [NSSortDescriptor(key: "releaseDate", ascending: true), NSSortDescriptor(key: "number", ascending: true)])
        collectionView.reloadData()
        placeholderLabel.isHidden = episodes.count > 0
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        collectionView.reloadData()
        placeholderLabel.isHidden = episodes.count > 0
        
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
            
            return rowHeight * CGFloat(rowsCount) + height
        }
    }
    
}

extension TodayViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TvEpisodeCell", for: indexPath) as! TvEpisodeCell
        
        cell.episode = episodes[indexPath.row]
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        
        var leftWidth = collectionView.frame.width
        leftWidth -= (layout.sectionInset.left + layout.sectionInset.right)
        leftWidth -= (CGFloat(episodesPerRow - 1) * layout.minimumInteritemSpacing)
        
        
        return CGSize(width: leftWidth / CGFloat(episodesPerRow), height: layout.itemSize.height)
        
    }
    
}
