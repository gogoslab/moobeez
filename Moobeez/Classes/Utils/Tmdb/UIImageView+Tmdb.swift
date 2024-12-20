//
//  UIImageView+Tmdb.swift
//  Moobeez
//
//  Created by Radu Banea on 11/09/2017.
//  Copyright © 2017 Gogo's Lab. All rights reserved.
//

import UIKit
import Foundation
import SDWebImage

extension String {
    
    var sizeValue:Int {
        get {
            return self == "original" ? Int.max : Int("\(self[index(after: startIndex)...])")!
        }
    }
    
    var sizeType:String {
        get {
            return self == "original" ? "original" : "\(self[..<index(after: startIndex)])"
        }
    }
}

extension UIImageView {
    
    static var imageSettings:[String : Any] = {
        
        var imageSettings:[String : Any]?
        
        if let path = AppDelegate.GroupPath?.appendingPathComponent("ImagesSettings.plist") {
            imageSettings = NSDictionary(contentsOf: path) as? [String : Any]
        }
        
        return imageSettings ?? [:]
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
    
    func loadImageWithUrl(url:URL, placeholder:UIImage? = nil, completion: ((Bool) -> Swift.Void)? = nil) {
        
        #if MAIN
        let options:SDWebImageOptions = []
        #else
        let options = SDWebImageOptions.scaleDownLargeImages
        #endif
        
        sd_setImage(with: url, placeholderImage: placeholder, options: options, progress: nil) { (image, error, cacheType, url) in
            if completion != nil {
                completion!(error == nil)
            }
        }
    }
    
    func loadTmdbImageWithPath(path:String, width:Int, placeholder:UIImage? = nil, completion: ((Bool) -> Swift.Void)? = nil) {
        loadImageWithUrl(url: URL(string: UIImageView.tmdbImagePath(path: path, forWidth: width))!, placeholder: placeholder, completion:completion)
    }
    
    func loadTmdbImageWithPath(path:String, height:Int, placeholder:UIImage? = nil, completion: ((Bool) -> Swift.Void)? = nil) {
        loadImageWithUrl(url: URL(string: UIImageView.tmdbImagePath(path: path, forHeight: height))!, placeholder: placeholder, completion:completion)
    }
    
    func loadTmdbOriginalImageWithPath(path:String, placeholder:UIImage? = nil, completion: ((Bool) -> Swift.Void)? = nil) {
        loadImageWithUrl(url: URL(string: UIImageView.tmdbOriginalImagePath(path: path))!, placeholder: placeholder, completion:completion)
    }
    
    func loadTmdbImageWithPath(path:String?, type:String, size imageSize:CGSize, placeholder:UIImage? = nil, completion: ((Bool) -> Swift.Void)? = nil) {
        
        guard let path = path else {
            image = placeholder
            return
        }
        
        var sizes = UIImageView.imageSettings["\(type)_sizes"] as! [String]
        
        sizes = sizes.sorted { $0.sizeValue < $1.sizeValue }
        
        for size:String in sizes {
            if size != "original" {
                let value:Int = size.sizeValue
                if size.sizeType == "w" {
                    if (Float(value) >= Float(imageSize.width * UIScreen.main.scale * 0.8)) {
                        loadTmdbImageWithPath(path: path, width: value, placeholder: placeholder, completion:completion)
                        break
                    }
                }
                else if size.sizeType == "h" {
                    if (Float(value) >= Float(imageSize.height * UIScreen.main.scale * 0.8)) {
                        loadTmdbImageWithPath(path: path, height: value, placeholder: placeholder, completion:completion)
                        break
                    }
                }
            } else {
                loadTmdbOriginalImageWithPath(path: path, placeholder: placeholder, completion:completion)
                break
            }
        }
        
    }
    
    func loadTmdbPosterWithPath(path:String?, placeholder:UIImage? = #imageLiteral(resourceName: "default_image"), completion: ((Bool) -> Swift.Void)? = nil) {
        loadTmdbPosterWithPath(path: path, size: frame.size, placeholder: placeholder, completion: completion)
    }
    
    func loadTmdbPosterWithPath(path:String?, size:CGSize, placeholder:UIImage? = #imageLiteral(resourceName: "default_image"), completion: ((Bool) -> Swift.Void)? = nil) {
        loadTmdbImageWithPath(path: path, type: "poster", size: size, placeholder: placeholder, completion: completion)
    }
    
    func loadTmdbProfileWithPath(path:String?, placeholder:UIImage? = #imageLiteral(resourceName: "default_image"), completion: ((Bool) -> Swift.Void)? = nil) {
        loadTmdbProfileWithPath(path: path, size: frame.size, placeholder: placeholder, completion: completion)
    }
    
    func loadTmdbProfileWithPath(path:String?, size:CGSize, placeholder:UIImage? = #imageLiteral(resourceName: "default_image"), completion: ((Bool) -> Swift.Void)? = nil) {
        loadTmdbImageWithPath(path: path, type: "profile", size: size, placeholder: placeholder, completion: completion)
    }
    
    func loadTmdbBackdropWithPath(path:String?, placeholder:UIImage? = #imageLiteral(resourceName: "default_image"), completion: ((Bool) -> Swift.Void)? = nil) {
        loadTmdbPosterWithPath(path: path, size: frame.size, placeholder: placeholder, completion: completion)
    }
    
    func loadTmdbBackdropWithPath(path:String?, size:CGSize, placeholder:UIImage? = #imageLiteral(resourceName: "default_image"), completion: ((Bool) -> Swift.Void)? = nil) {
        loadTmdbImageWithPath(path: path, type: "backdrop", size: size, placeholder: placeholder, completion: completion)
    }
    
    func loadTmdbImage(image:Tmdb.Image, completion: ((Bool) -> Swift.Void)? = nil) {
        if image.isPoster {
            loadTmdbPosterWithPath(path: image.path, placeholder:nil, completion: completion)
        }
        else {
            loadTmdbBackdropWithPath(path: image.path, placeholder:nil, completion: completion)
        }
    }
    
}
