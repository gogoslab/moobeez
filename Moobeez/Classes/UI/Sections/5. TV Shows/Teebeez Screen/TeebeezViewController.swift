//
//  TeebeezViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 10/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
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
    
    var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>?
    {
        get {
            if (segmentedControl.selectedSegmentIndex == 1) {
                return episodesResultsController;
            }
            return teebeezResultsController;
        }
    }
    
    var teebeezResultsController:NSFetchedResultsController<NSFetchRequestResult>? = nil
    var episodesResultsController:NSFetchedResultsController<NSFetchRequestResult>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTitleLogo()
        
        let context = MoobeezManager.shared.moobeezDatabase.context
        
        var fetchRequest = NSFetchRequest<NSFetchRequestResult> (entityName: "TeebeeEpisode")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "releaseDate", ascending: false)]
        teebeezResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "", cacheName: nil)
        
        fetchRequest = NSFetchRequest<NSFetchRequestResult> (entityName: "TeebeeEpisode")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "releaseDate", ascending: true)]
        
        episodesResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "formattedDate", cacheName: nil)
        
        reloadItems()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(showTvShowSearch))
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadItems), name: .TeebeezDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let teebeezToUpdate:[Teebee] = MoobeezManager.shared.moobeezDatabase.fetch(predicate: NSPredicate(format: "lastUpdate < %@", NSDate(timeIntervalSinceNow:-24 * 3600)))
        
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
        
        var predicateFormat:String = ""
        var args:[Any]?
        
        let today = Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: (SettingsManager.shared.addExtraDay ? -24 * 3600 : 0)))
        let tommorow = today.addingTimeInterval(24 * 3600)
        let nextWeek = today.addingTimeInterval(7 * 24 * 3600)

        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            predicateFormat = "watched == 0 AND releaseDate < %@ AND releaseDate.timeIntervalSince1970 > 100 AND season.teebee.temporary == false"
            args = [tommorow]
            
            let keypathExp = NSExpression(forKeyPath: "tmdbId") // can be any column
            let countExpression = NSExpression(forFunction: "count:", arguments: [keypathExp])

            let countExpressionDescription = NSExpressionDescription()
            countExpressionDescription.expression = countExpression
            countExpressionDescription.name = "count"
            countExpressionDescription.expressionResultType = .integer16AttributeType

            fetchedResultsController?.fetchRequest.propertiesToFetch = ["season.teebee", countExpressionDescription]
            fetchedResultsController?.fetchRequest.propertiesToGroupBy = ["season.teebee"]

            fetchedResultsController?.fetchRequest.resultType = .dictionaryResultType
            
            break
        case 1:
            predicateFormat = "watched == 0 AND releaseDate >= %@ AND releaseDate <= %@ AND season.teebee.temporary == false"
            args = [tommorow, nextWeek]
            break
        case 2:
            predicateFormat = "season.teebee.temporary == false"
            fetchedResultsController?.fetchRequest.propertiesToFetch = ["season.teebee"]
            fetchedResultsController?.fetchRequest.propertiesToGroupBy = ["season.teebee"]

            fetchedResultsController?.fetchRequest.resultType = .dictionaryResultType
            
        default:
            break
        }
        
        if searchBar.text != nil && (searchBar.text)!.count > 0 {
            if predicateFormat.count > 0 {
                predicateFormat = predicateFormat + " AND "
            }
            predicateFormat = predicateFormat + "season.teebee.name CONTAINS[cd] '\(searchBar.text!)'"
        }
        
        if predicateFormat.count > 0 {
            if args == nil {
                fetchedResultsController?.fetchRequest.predicate = NSPredicate(format: predicateFormat)
            }
            else {
                fetchedResultsController?.fetchRequest.predicate = NSPredicate(format: predicateFormat, argumentArray: args)
            }
        }
        else {
            fetchedResultsController?.fetchRequest.predicate = nil
        }

        
        do {
            try fetchedResultsController?.performFetch()
            collectionView.reloadData()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
    }
    
    func updateTeebeez(_ teebeez:[Teebee], index: Int = 0) {
        
        self.progressBar.progress = Float(index) / Float(teebeez.count)
        
        guard index < teebeez.count else {
            progressBar.isHidden = true
            return
        }
        
        progressBar.isHidden = false
        
        let nextTeebee = teebeez[index]
        
        TmdbService.startTvShowConnection(tmdbId: nextTeebee.tmdbId) { (error, _) in
            if error == nil {
                nextTeebee.lastUpdate = Date()
                MoobeezManager.shared.save()
            }
            else {
                print("error updating \(nextTeebee.name ?? "unknown")")
            }
            
            DispatchQueue.main.async {
                self.updateTeebeez(teebeez, index: index + 1)
            }
        }
        
        
        
    }
}

extension TeebeezViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let frc = fetchedResultsController {
            return frc.sections!.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = self.fetchedResultsController?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:BeeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BeeCell", for: indexPath) as! BeeCell
        
        guard let sections = self.fetchedResultsController?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        
        let sectionInfo = sections[indexPath.section]
        
        let rowInfo = sectionInfo.objects![indexPath.row]
        
        if rowInfo is Dictionary<String, Any> {
            let dictionary = rowInfo as! Dictionary<String, Any>
            
            do {
                let teebee:Teebee? = try MoobeezManager.shared.moobeezDatabase.context.existingObject(with: dictionary["season.teebee"]! as! NSManagedObjectID) as? Teebee
                cell.bee = teebee
                if dictionary["count"] != nil {
                    cell.notifications = dictionary["count"] as! Int16
                }
                else {
                    cell.notifications = 0;
                }
                
            } catch {
                fatalError("Failed to fetch teebeez: \(error)")
            }
        }
        else if rowInfo is TeebeeEpisode {
            cell.bee = (rowInfo as! TeebeeEpisode).season?.teebee
            cell.notifications = 0;
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.size.width - 10 * 4) / 3
        
        return CGSize(width: width, height: width * (UIApplication.shared.keyWindow?.frame.size.height)! /
            (UIApplication.shared.keyWindow?.frame.size.width)!)
        
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
            
            let sectionInfo = self.fetchedResultsController?.sections![indexPath.section]
            
            headerView.titleLabel.text = sectionInfo?.name.uppercased()
            
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

