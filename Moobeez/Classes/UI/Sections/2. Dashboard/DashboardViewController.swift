//
//  DashboardViewController.swift
//  Moobeez
//
//  Created by Radu Banea on 02/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit

class DashboardViewController: TimelineViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func loadItems() {
        items = MoobeezManager.shared.loadDashboardItems()
    }
    
    override func scrollToFirstItem() {
        
        guard items != nil && items!.count > 0 else {
            return
        }
        
        tableView.scrollToRow(at: IndexPath(row:items!.last!.1.count - 1, section: items!.count - 1), at: UITableViewScrollPosition.middle , animated: false)
    }

}
