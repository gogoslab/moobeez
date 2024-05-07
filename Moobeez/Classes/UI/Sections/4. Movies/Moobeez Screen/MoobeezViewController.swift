//
//  MoobeezViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 10/09/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import UIKit
import CoreData

class MoobeezViewController: MBViewController {

    @IBOutlet var searchBar: UITextField!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var searchBarWidthConstraint: NSLayoutConstraint!

    @IBOutlet var collectionView: UICollectionView!
    
    let segmentedTitles:[String] = ["Seen", "Watchlist", "Favorites"]
    
    var moobeez:[Moobee] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTitleLogo()
        
        moobeez = MoobeezManager.shared.moobeez.filter({ moobee in
            moobee.type == .seen
        }).sorted(by: { m1, m2 in
            m1.date!.compare(m2.date!) == .orderedDescending
        })
        
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
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            moobeez = MoobeezManager.shared.moobeez.filter({ moobee in
                moobee.type == .seen
            }).sorted(by: { m1, m2 in
                m1.date!.compare(m2.date!) == .orderedDescending
            })
            break
        case 1:
            moobeez = MoobeezManager.shared.moobeez.filter({ moobee in
                moobee.type == .watchlist
            }).sorted(by: { m1, m2 in
                m1.date!.compare(m2.date!) == .orderedDescending
            })
            break
        case 2:
            moobeez = MoobeezManager.shared.moobeez.filter({ moobee in
                moobee.type == .seen && moobee.isFavorite
            }).sorted(by: { m1, m2 in
                m1.date!.compare(m2.date!) == .orderedDescending
            })
            
        default:
            break
        }
        
        if let filter = searchBar.text, filter.count > 0 {
            moobeez = moobeez.filter({ moobee in
                moobee.name.contains(filter)
            })
        }
        
        collectionView.reloadData()
    }
}

extension MoobeezViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moobeez.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:BeeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BeeCell", for: indexPath) as! BeeCell
        
        cell.bee = moobeez[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.size.width - 10 * 4) / 3
        
        let screenSize = UIScreen.main.bounds.size
        
        return CGSize(width: width, height: width * screenSize.height / screenSize.width)
        
    }
}

extension MoobeezViewController : UITextFieldDelegate {
 
    @IBAction func searchButtonPressed(_ sender:Any?) {
        searchBar.becomeFirstResponder()
    }
    
    @IBAction func searchCloseButtonPressed(_ sender:Any?) {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        reloadItems()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.3) {

            self.searchBarWidthConstraint.isActive = true
            
            for i in 0...self.segmentedControl.numberOfSegments-1 {
                let title = self.segmentedTitles[i]
                self.segmentedControl.setTitle(String(title.prefix(1)), forSegmentAt: i)
            }
            
            self.segmentedControl.superview?.layoutIfNeeded()

        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        UIView.animate(withDuration: 0.3, animations: {

            self.searchBarWidthConstraint.isActive = false
            
            self.segmentedControl.superview?.layoutIfNeeded()

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

