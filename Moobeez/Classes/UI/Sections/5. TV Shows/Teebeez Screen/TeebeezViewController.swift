//
//  TeebeezViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 10/09/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import UIKit
import CoreData

class TeebeezViewController: MBViewController {

    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var searchBarWidthConstraint: NSLayoutConstraint!

    @IBOutlet var collectionView: UICollectionView!
    
    let segmentedTitles:[String] = ["To see", "Soon", "All"]
    
    var results:[Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTitleLogo()
        
        reloadItems()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(showTvShowSearch))
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadItems), name: .TeebeezDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let teebeezToUpdate:[Teebee] = MoobeezManager.shared.teebeez.filter({ teebee in
            teebee.lastUpdateDate?.timeIntervalSinceNow ?? 0 < -24 * 3600
        })
        
        updateTeebeez(teebeezToUpdate)
    }

    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        
        if segue.destination is TeebeeDetailsViewController {
            
            let teebeeViewController:TeebeeDetailsViewController = segue.destination as! TeebeeDetailsViewController
            
            let cell:BeeCell? = sender as? BeeCell
            
            teebeeViewController.teebee = cell?.bee as? Teebee
            teebeeViewController.posterImage = cell?.posterImageView.image
        }
        
     }
    
    override func summaryViewForViewController(_ viewController: UIViewController) -> UIView? {
        
        guard viewController is TeebeeDetailsViewController else {
            return nil
        }
        
        for beeCell:UICollectionViewCell in collectionView.visibleCells {
            if (beeCell as! BeeCell).bee?.tmdbId == (viewController as! TeebeeDetailsViewController).teebee?.tmdbId {
                return beeCell
            }
        }
        
        return nil
    }
 
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        reloadItems()
    }
    
    @objc func showTvShowSearch() {
        performSegue(withIdentifier: "TvShowSearchSegue", sender: nil)
    }
    
    @objc func reloadItems () {
        
        let today = Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: (SettingsManager.shared.addExtraDay ? -24 * 3600 : 0)))
        let tommorow = today.addingTimeInterval(24 * 3600)
        let nextWeek = today.addingTimeInterval(7 * 24 * 3600)

        let filter = searchBar.text ?? ""
        
        var teebeez = MoobeezManager.shared.teebeez
            
           teebeez = teebeez.filter({ teebee in
               return !teebee.temporary && (filter.isEmpty || teebee.name.contains(filter))
        })
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            results = teebeez.filter({ teebee in
                teebee.notWatchedEpisodesCount > 0
            }).map({ teebee in
                (teebee, teebee.notWatchedEpisodesCount)
            })
            
            break
        case 1:
            results = []
            
            let episodes: [Teebee.Episode] = teebeez.flatMap { teebee in
                return teebee.episodesBetween(startDate: tommorow, endDate: nextWeek)
            }.sorted(by: { e1, e2 in
                return e1.releaseDate!.compare(e2.releaseDate!) == .orderedAscending
             })
            
            var groupped: [String : [Teebee.Episode]] = [:]
            
            groupped = episodes.reduce(into: groupped) { partialResult, episode in
                if partialResult[episode.formattedDate] == nil {
                    partialResult[episode.formattedDate] = [Teebee.Episode]()
                }
                partialResult[episode.formattedDate]!.append(episode)
            }
            
            let dates = ["Today", "Tommorow", "This week", "Next week", "Soon"]
            
            for date in dates {
                if let episodes = groupped[date] {
                    results.append((date, episodes))
                }
            }
            
            break
        case 2:
            results = teebeez
        default:
            break
        }
                
        collectionView.reloadData()
        
    }
    
    func updateTeebeez(_ teebeez:[Teebee], index: Int = 0) {
        
        self.progressBar.progress = Float(index) / Float(teebeez.count)
        
        guard index < teebeez.count else {
            progressBar.isHidden = true
            return
        }
        
        progressBar.isHidden = false
        
        let nextTeebee = teebeez[index]
        
        guard let tmdbId = nextTeebee.tmdbId else {
            self.updateTeebeez(teebeez, index: index + 1)
            return
        }
        
        TmdbService.startTvShowConnection(tmdbId: tmdbId) { (error, _) in
            if error == nil {
                nextTeebee.lastUpdateDate = Date()
                nextTeebee.save()
            }
            else {
                Console.error("error updating \(nextTeebee.name)")
            }
            
            DispatchQueue.main.async {
                self.updateTeebeez(teebeez, index: index + 1)
            }
        }
        
        
        
    }
}

extension TeebeezViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if segmentedControl.selectedSegmentIndex == 1 {
            return results.count
        }
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 1 {
            return (results[section] as! (String, [Teebee.Episode])).1.count
        }
        
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:BeeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BeeCell", for: indexPath) as! BeeCell
        
        cell.notifications = 0
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let item = results[indexPath.item] as! (teebee: Teebee, count: Int)
            cell.bee = item.teebee
            cell.notifications = item.count
            
            break
        case 1:
            cell.bee = (results[indexPath.section] as! (String, episodes: [Teebee.Episode])).episodes[indexPath.item].season!.teebee
            
            break
        case 2:
            cell.bee = results[indexPath.item] as! Teebee
        default:
            break
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.size.width - 10 * 4) / 3
        
        let screenSize = UIScreen.main.bounds.size
        
        return CGSize(width: width, height: width * screenSize.height / screenSize.width)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if segmentedControl.selectedSegmentIndex == 1 {
            return CGSize(width: collectionView.frame.size.width, height: 30)
        }
        
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader && segmentedControl.selectedSegmentIndex == 1 {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView", for: indexPath) as! HeaderView
            
            headerView.titleLabel.text = (results[indexPath.section] as! (date: String, [Teebee.Episode])).date
            
            return headerView
        }
        
        return UICollectionReusableView()
    }
}

extension TeebeezViewController : UISearchBarDelegate {
 
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadItems()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        UIView.animate(withDuration: 0.3) {

            self.searchBarWidthConstraint.isActive = true
            
            for i in 0...self.segmentedControl.numberOfSegments-1 {
                let title = self.segmentedTitles[i]
                self.segmentedControl.setTitle(String(title.prefix(1)), forSegmentAt: i)
            }
            
            searchBar.showsCancelButton = true
            
            searchBar.superview?.layoutIfNeeded()

        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {

        UIView.animate(withDuration: 0.3, animations: {

            self.searchBarWidthConstraint.isActive = false
            
            searchBar.showsCancelButton = false
            
            searchBar.superview?.layoutIfNeeded()

        })
        { (_) in

            for i in 0...self.segmentedControl.numberOfSegments-1 {
                let title = self.segmentedTitles[i]
                self.segmentedControl.setTitle(title, forSegmentAt: i);
            }
            
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
        reloadItems()
    }
    
}

