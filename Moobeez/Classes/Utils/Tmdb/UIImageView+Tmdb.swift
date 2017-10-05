//
//  UIImageView+Tmdb.swift
//  Moobeez
//
//  Created by Radu Banea on 11/09/2017.
//  Copyright © 2017 Gogolabs. All rights reserved.
//

import UIKit
import Foundation
import SDWebImage

extension String {
    
    var sizeValue:Int {
        get {
            return Int(substring(from: index(after: startIndex)))!
        }
    }
    
    var sizeType:String {
        get {
            return substring(to: index(after: startIndex))
        }
    }
}

extension UIImageView {
    
    static var imageSettings:NSDictionary = {
        
        var myDict: NSDictionary?
        
        if let path = AppDelegate.GroupPath?.appendingPathComponent("ImagesSettings.plist") {
            myDict = NSDictionary(contentsOf: path)
        }
        
        return myDict!
    }()
    
    static var tmdbRootPath:String = "https://image.tmdb.org/t/p/"
    
    static func tmdbImagePath(path:String, forWidth width:Int) -> String {
        return tmdbRootPath.appending("w\(width)\(path)")
    }
    
    static func tmdbImagePath(path:String, forHeight height:Int) -> String {
        return tmdbRootPath.appending("h\(height)\(path)")
    }
    
    static func tmdbOriginalImagePath(path:String) -> String {
        return tmdbRootPath.appending("original\(path)")
    }
    
    func loadImageWithUrl(url:URL, completion: ((Bool) -> Swift.Void)? = nil) {
        sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "default_image")) { (image, error, cacheType, url) in
            if completion != nil {
                completion!(error == nil)
            }
        }
    }
    
    func loadTmdbImageWithPath(path:String, width:Int, completion: ((Bool) -> Swift.Void)? = nil) {
        loadImageWithUrl(url: URL(string: UIImageView.tmdbImagePath(path: path, forWidth: width))!, completion:completion)
    }
    
    func loadTmdbImageWithPath(path:String, height:Int, completion: ((Bool) -> Swift.Void)? = nil) {
        loadImageWithUrl(url: URL(string: UIImageView.tmdbImagePath(path: path, forHeight: height))!, completion:completion)
    }
    
    func loadTmdbOriginalImageWithPath(path:String, completion: ((Bool) -> Swift.Void)? = nil) {
        loadImageWithUrl(url: URL(string: UIImageView.tmdbOriginalImagePath(path: path))!, completion:completion)
    }
    
    func loadTmdbImageWithPath(path:String, type:String, size imageSize:CGSize, completion: ((Bool) -> Swift.Void)? = nil) {
        
        let sizes:NSArray = UIImageView.imageSettings.object(forKey: "\(type)_sizes") as! NSArray
        
        for size:String in sizes as! [String] {
            if size != "original" {
                let value:Int = size.sizeValue
                if size.sizeType == "w" {
                    if (Float(value) >= Float(imageSize.width * UIScreen.main.scale * 0.8)) {
                        loadTmdbImageWithPath(path: path, width: value, completion:completion)
                    }
                }
                else if size.sizeType == "h" {
                    if (Float(value) >= Float(imageSize.height * UIScreen.main.scale * 0.8)) {
                        loadTmdbImageWithPath(path: path, height: value, completion:completion)
                    }
                }
            } else {
                loadTmdbOriginalImageWithPath(path: path, completion:completion)
            }
        }
        
    }
    
    func loadTmdbPosterWithPath(path:String, completion: ((Bool) -> Swift.Void)? = nil) {
        loadTmdbPosterWithPath(path: path, size: frame.size, completion: completion)
    }
    
    func loadTmdbPosterWithPath(path:String, size:CGSize, completion: ((Bool) -> Swift.Void)? = nil) {
        loadTmdbImageWithPath(path: path, type: "poster", size: size, completion: completion)
    }
    
    func loadTmdbProfileWithPath(path:String, completion: ((Bool) -> Swift.Void)? = nil) {
        loadTmdbProfileWithPath(path: path, size: frame.size, completion: completion)
    }
    
    func loadTmdbProfileWithPath(path:String, size:CGSize, completion: ((Bool) -> Swift.Void)? = nil) {
        loadTmdbImageWithPath(path: path, type: "profile", size: size, completion: completion)
    }
    
    func loadTmdbBackdropWithPath(path:String, completion: ((Bool) -> Swift.Void)? = nil) {
        loadTmdbPosterWithPath(path: path, size: frame.size, completion: completion)
    }
    
    func loadTmdbBackdropWithPath(path:String, size:CGSize, completion: ((Bool) -> Swift.Void)? = nil) {
        loadTmdbImageWithPath(path: path, type: "backdrop", size: size, completion: completion)
    }
    
}
