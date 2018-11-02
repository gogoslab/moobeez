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
    
    var episodes:[TeebeeEpisode] = [TeebeeEpisode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        let today = Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: (SettingsManager.shared.addExtraDay ? -24 * 3600 : 0)))
        
        episodes = MoobeezManager.shared.moobeezDatabase.fetch(predicate: NSPredicate(format: "watched == 0 AND releaseDate < %@", today as CVarArg), sort: [NSSortDescriptor(key: "releaseDate", ascending: true), NSSortDescriptor(key: "number", ascending: true)])
        collectionView.reloadData()
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
        collectionView.reloadData()
    }
    
}

extension TodayViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
    
}
