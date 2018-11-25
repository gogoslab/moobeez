//
//  SearchMoviesViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 09/10/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import UIKit

class SearchMoviesViewController: MBViewController {

    @IBOutlet var contentView:UIView!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var searchBar:SearchBar!
    
    var movies:[TmdbMovie]?
    
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
        
        if segue.destination is MoobeeDetailsViewController {
            
            let moobeeViewController:MoobeeDetailsViewController = segue.destination as! MoobeeDetailsViewController
            
            let cell:SearchResultCell? = sender as? SearchResultCell
            
            moobeeViewController.movie = cell?.movie
            moobeeViewController.posterImage = cell?.posterImageView?.image
        }
        
    }
    
    override func summaryViewForViewController(_ viewController: UIViewController) -> UIView? {
        
        guard viewController is MoobeeDetailsViewController else {
            return nil
        }
        
        for cell:UITableViewCell in tableView.visibleCells {
            if (cell as! SearchResultCell).movie?.tmdbId == (viewController as! MoobeeDetailsViewController).movie?.tmdbId {
                return (cell as! SearchResultCell).posterImageView
            }
        }
        
        return nil
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        hideDetailsViewController()
    }
}

extension SearchMoviesViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard movies != nil else {
            return 0
        }
        
        return movies!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:SearchResultCell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell") as! SearchResultCell
        
        let movie:TmdbMovie = movies![indexPath.row]
        
        cell.movie = movie
        
        return cell
    }
    
}

extension SearchMoviesViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        TmdbService.startSearchMoviesConnection(query: searchBar.text!) { (error, movies) in
            
            if error == nil {
                DispatchQueue.main.async {
                    self.movies = movies
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
