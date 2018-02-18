//
//  SearchTVsViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 09/10/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

class SearchTVsViewController: MBViewController {

    @IBOutlet var contentView:UIView!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var searchBar:SearchBar!
    
    var tvShows:[TmdbTvShow]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        searchBar.becomeFirstResponder()
    }
    

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.destination is TeebeeDetailsViewController {
            
            let teebeeViewController:TeebeeDetailsViewController = segue.destination as! TeebeeDetailsViewController
            
            let cell:SearchResultCell? = sender as? SearchResultCell
            
            teebeeViewController.tvShow = cell?.tvShow
            teebeeViewController.posterImage = cell?.posterImageView?.image
        }
        
    }
    
    override func summaryViewForViewController(_ viewController: UIViewController) -> UIView? {
        
        guard viewController is TeebeeDetailsViewController else {
            return nil
        }
        
        for cell:UITableViewCell in tableView.visibleCells {
            if (cell as! SearchResultCell).tvShow?.tmdbId == (viewController as! TeebeeDetailsViewController).tvShow?.tmdbId {
                return (cell as! SearchResultCell).posterImageView
            }
        }
        
        return nil
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        hideDetailsViewController()
    }
}

extension SearchTVsViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard tvShows != nil else {
            return 0
        }
        
        return tvShows!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:SearchResultCell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell") as! SearchResultCell
        
        let tvShow:TmdbTvShow = tvShows![indexPath.row]
        
        cell.tvShow = tvShow
        
        return cell
    }
    
}

extension SearchTVsViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        TmdbService.startSearchTvShowsConnection(query: searchBar.text!) { (error, tvShows) in
            
            if error == nil {
                DispatchQueue.main.async {
                    self.tvShows = tvShows
                    self.tableView.reloadData()
                    self.searchBar.resignFirstResponder()
                }
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
