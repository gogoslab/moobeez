//
//  MoobeezViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 10/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit
import CoreData

class MoobeezViewController: MBViewController {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var searchBarWidthConstraint: NSLayoutConstraint!

    @IBOutlet var collectionView: UICollectionView!
    
    let segmentedTitles:[String] = ["Seen", "Watchlist", "Favorites"]
    
    var fetchedResultsController:NSFetchedResultsController<Moobee>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTitleLogo()
        
        let context = MoobeezManager.shared.persistentContainer.viewContext;
        let fetchRequest = NSFetchRequest<Moobee> (entityName: "Moobee")

        fetchRequest.predicate = NSPredicate(format: "type == %ld", MoobeeType.seen.rawValue)
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(showMovieSearch))
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadItems), name: .MoobeezDidChangeNotification, object: nil)
    }

    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        
        if let moobeeViewController = segue.destination as? MoobeeDetailsViewController {
            
            let cell:BeeCell? = sender as? BeeCell
            
            moobeeViewController.moobee = cell?.bee as? Moobee
            moobeeViewController.posterImage = cell?.posterImageView.image
        }
     }
    
    override func summaryViewForViewController(_ viewController: UIViewController) -> UIView? {
        
        guard viewController is MoobeeDetailsViewController else {
            return nil
        }
        
        for beeCell:UICollectionViewCell in collectionView.visibleCells {
            if (beeCell as! BeeCell).bee?.tmdbId == (viewController as! MoobeeDetailsViewController).moobee?.tmdbId {
                return beeCell
            }
        }
        
        return nil
    }
 
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        reloadItems()
    }
    
    @objc func showMovieSearch() {
        performSegue(withIdentifier: "MovieSearchSegue", sender: nil)
    }
    
    @objc func reloadItems () {
        
        var predicateFormat:String = ""
        var sortDescriptors:[NSSortDescriptor]?
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            predicateFormat = "type == \(MoobeeType.seen.rawValue)"
            sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            break
        case 1:
            predicateFormat = "type == \(MoobeeType.watchlist.rawValue)"
            sortDescriptors = [NSSortDescriptor(key: "releaseDate", ascending: false)]
            break
        case 2:
            predicateFormat = "type == \(MoobeeType.seen.rawValue) AND isFavorite == 1"
            sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
        default:
            break
        }
        
        if searchBar.text != nil && (searchBar.text)!.count > 0 {
            predicateFormat = predicateFormat + " AND name CONTAINS[cd] '\(searchBar.text!)'"
        }
        
        fetchedResultsController?.fetchRequest.predicate = NSPredicate(format: predicateFormat)
        fetchedResultsController?.fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            try fetchedResultsController?.performFetch()
            collectionView.reloadData()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
    }
}

extension MoobeezViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        
        cell.bee = rowInfo as? Bee
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.size.width - 10 * 4) / 3
        
        return CGSize(width: width, height: width * (UIApplication.shared.keyWindow?.frame.size.height)! /
            (UIApplication.shared.keyWindow?.frame.size.width)!)
        
    }
}

extension MoobeezViewController : UISearchBarDelegate {
 
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

