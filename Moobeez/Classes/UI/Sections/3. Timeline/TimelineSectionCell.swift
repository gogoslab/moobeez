//
//  TimelineSectionCell.swift
//  Moobeez
//
//  Created by Radu Banea on 24/02/2018.
//  Copyright © 2018 Gogo's Lab. All rights reserved.
//

import UIKit

class TimelineSectionCell: UITableViewCell {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayNameLabel: UILabel!
    @IBOutlet weak var dateBubble: UIImageView!
    
    var parentTableView: UITableView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let imageView = UIImageView(image: #imageLiteral(resourceName: "timeline_section_mask"))
        tableView.mask = imageView
    }

    var items:[TimelineItem] = [TimelineItem]() {
        didSet {
            
            tableView.reloadData()
            
            tableView.height = self.tableView.contentSize.height
            
            tableView.mask!.frame = tableView.bounds
            
            date = items.last?.date
        }
    }
    
    var date:Date? {
        didSet {
            
            guard date != nil else {
                dateBubble.isHidden = true
                dayNameLabel.isHidden = true
                dayLabel.isHidden = true
                monthLabel.isHidden = true
                return
            }
            
            dateBubble.isHidden = false
            
            let adjustedDate = date?.addingTimeInterval(SettingsManager.shared.addExtraDay ? 24 * 3600 : 0)

            if Calendar.current.isDateInToday(adjustedDate!) {
                dayNameLabel.text = "Today"
                dayNameLabel.isHidden = false
                dayLabel.isHidden = true
                monthLabel.isHidden = true
            }
//            else if Calendar.current.isDateInTomorrow(date!) {
//                dayNameLabel.text = "Tomorrow"
//                dayNameLabel.isHidden = false
//                dayLabel.isHidden = true
//                monthLabel.isHidden = true
//            }
            else {
                dayLabel.text = adjustedDate?.string(withFormat: "d")
                monthLabel.text = adjustedDate?.string(withFormat: "MMM")
                dayNameLabel.isHidden = true
                dayLabel.isHidden = false
                monthLabel.isHidden = false
            }
        }
    }
}

class TimelineItemCell : UITableViewCell {
    
    @IBOutlet weak var backdropImageView:UIImageView!
    @IBOutlet weak var shadowImageView:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var subtitleLabel:UILabel?
    @IBOutlet weak var starsView:StarsView?
    @IBOutlet weak var watchedButton: UIButton!
    
    var item:TimelineItem? {
        didSet {
            NotificationCenter.default.removeObserver(self)
            
            reloadData()
            
            if let season = item?.teebeeEpisode?.season {
                NotificationCenter.default.addObserver(forName: .TeebeeSeasonDidChangeNotification, object: season, queue: .main) { (_) in
                    self.reloadData()
                }
            }
            
            if let moobee = item?.moobee {
                NotificationCenter.default.addObserver(forName: .BeeDidChangeNotification, object: moobee.tmdbId, queue: .main) { (_) in
                    self.reloadData()
                }
            }
        }
    }
    
    func reloadData() {
        guard item != nil else {
            return
        }
        
        backdropImageView.loadTmdbBackdropWithPath(path: item!.backdropPath)
        
        titleLabel.text = item!.name
        
        subtitleLabel?.text = item!.subtitle
        
        if item!.rating >= 0 {
            starsView?.isHidden = false
            starsView?.rating = CGFloat(item!.rating)
        }
        else {
            starsView?.isHidden = true
        }
        
        let today = Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: (SettingsManager.shared.addExtraDay ? -24 * 3600 : 0)))
        
        watchedButton?.isHidden = item!.date!.timeIntervalSince(today) > 0 || item!.watched!
        
    }

    @IBAction func watchedButtonPressed(_ sender: Any) {
        item?.teebeeEpisode?.watched = true
        MoobeezManager.shared.save()
        
        if let episode = item?.teebeeEpisode {
            NotificationCenter.default.post(name: .BeeDidChangeNotification , object: episode.season?.teebee)
            NotificationCenter.default.post(name: .TeebeeSeasonDidChangeNotification, object: episode.season)
            NotificationCenter.default.post(name: .TeebeezDidChangeNotification , object: nil)
        }
        
        if let moobee = item?.moobee {
            NotificationCenter.default.post(name: .BeeDidChangeNotification , object: moobee)
            NotificationCenter.default.post(name: .MoobeezDidChangeNotification , object: nil)
        }
    }
    
    
}

extension TimelineSectionCell : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.row]
        
        let cell:TimelineItemCell = tableView.dequeueReusableCell(withIdentifier: (item.teebeeEpisode != nil ? "TVCell" : (item.moobee!.type == .seen ? "MovieCell" : "WatchlistCell"))) as! TimelineItemCell
        
        cell.item = item
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard parentTableView != nil else {
            return
        }
        
        parentTableView!.delegate?.tableView?(parentTableView!, didSelectRowAt: IndexPath(row: indexPath.row, section:parentTableView!.indexPath(for: self)!.section))
        
    }
}

