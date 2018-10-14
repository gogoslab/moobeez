//
//  TimelineViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 02/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

class TimelineViewController: MBViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var items:[(Date, [TimelineItem])]?
    
    var initialAppear:Bool = true
    
    var future:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        loadItems()
        
        tableView.reloadData()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if initialAppear {
            scrollToFirstItem()
        }

        initialAppear = false
    }
    
    func loadItems() {
        if future {
            items = MoobeezManager.shared.loadTimelineItems()
        }
        else {
            items = MoobeezManager.shared.loadDashboardItems()
        }
    }
    
    func scrollToFirstItem() {
        guard items != nil && items!.count > 0 else {
            return
        }
        
        if future {
            let firstIndex = items?.index(where: {return $0.0 >= Calendar.current.startOfDay(for: Date())})
            
            if firstIndex != nil {
                tableView.scrollToRow(at: IndexPath(row:0, section: firstIndex!), at: .top, animated: false)
            }
        }
        else {
            tableView.scrollToRow(at: IndexPath(row:items!.last!.1.count - 1, section: items!.count - 1), at: UITableView.ScrollPosition.middle , animated: false)
        }
    }
    
    override func isSame(with viewController: MBViewController) -> Bool {
        if super.isSame(with: viewController) {
            if (viewController as! TimelineViewController).future == future {
                return true
            }
        }
        
        return false
    }
}


extension TimelineViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard items != nil else {
            return 0
        }
        
        return items!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard items != nil else {
            return 0
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TimelineSectionCell = tableView.dequeueReusableCell(withIdentifier: "TimelineSectionCell") as! TimelineSectionCell
        
        cell.items = items![indexPath.section].1
        cell.parentTableView = tableView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CGFloat(140 * items![indexPath.section].1.count + 20)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = items![indexPath.section].1[indexPath.row]
        
        if item.moobee != nil {
            
            let viewController = storyboard?.instantiateViewController(withIdentifier: "MoobeeDetailsViewController") as! MoobeeDetailsViewController
            viewController.moobee = item.moobee
            
            showDetailsViewController(viewController)
            
            return
        }
        
        if item.teebeeEpisode != nil {
            
            let viewController = storyboard?.instantiateViewController(withIdentifier: "TeebeeDetailsViewController") as! TeebeeDetailsViewController
            viewController.teebee = item.teebeeEpisode?.season?.teebee
            
            showDetailsViewController(viewController)
            
            return
        }
        
    }
    
}
