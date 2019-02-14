//
//  CommunityMapItem.swift
//  ReportedPD
//
//  Created by dev on 2/19/17.
//  Copyright © 2017 reported. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

class CommunityMapItem: UIView {
    
    var imageView: UIImageView!
    var loadingView: UIActivityIndicatorView!
    var playerIcon: UIImageView!
    
    var addressLabel: UILabel!
    var dateLabel: UILabel!
    var reportedTypeLabel: UILabel!
    
    var counterLabel: UILabel!
    
    var item: ReportModel! {
        didSet {
            
            dateLabel.text = item.getDays()
            addressLabel.text = item.address != "" ? item.address : "address unknown"
            reportedTypeLabel.text = "Reported by: " + item.user_type
            
            imageView.image = nil
            playerIcon.isHidden = true
            loadingView.isHidden = true
            
            if item.mediaList.count > 0 {
                
                let mediaModel = item.mediaList[0]
                
                if mediaModel.image != nil {
                    imageView.image = mediaModel.image
                    playerIcon.isHidden = !mediaModel.isVideo || mediaModel.assetPath == nil
                } else {
                    loadingView.isHidden = false
                    loadingView.startAnimating()
                    playerIcon.isHidden = true
                
                    let currentItem: ReportModel! = item
                    
                    if mediaModel.imageFile != nil {
                        mediaModel.imageFile.getDataInBackground(block: { (data, error) in
                            if (error == nil) {
                                mediaModel.image = UIImage(data: data!)
                                if self.item == currentItem {
                                    self.imageView.image = mediaModel.image
                                    self.loadingView.isHidden = true
                                }
                            }
                        })
                    } else if mediaModel.videoFile != nil {
                        mediaModel.videoFile.getPathInBackground(block: { (path, error) in
                            if (error == nil) {
                                let asset = AVAsset(url: URL(fileURLWithPath: path!))
                                let assetImageGenerator = AVAssetImageGenerator(asset: asset)
                                assetImageGenerator.appliesPreferredTrackTransform = true
                                var time = asset.duration
                                time.value = min(time.value, 1)
                                do {
                                    let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
                                    mediaModel.image = UIImage(cgImage: imageRef)
                                    if self.item == currentItem {
                                        self.imageView.image = mediaModel.image
                                        self.loadingView.isHidden = true
                                        self.playerIcon.isHidden = false
                                    }
                                } catch {
                                    print("error")
                                }
                            }
                        })
                    }
                }
                
            } else {
                imageView.image = UIImage(named: "no-img")
            }
            
        }
    }
    
    func showPhoto(_ sender: AnyObject) {
        if item != nil && item.mediaList.count > 0 {
            let model = item.mediaList[0]
            model.showMedia(imageRect: (sender as! UIView).frame)
        }
    }
    
    class func instanceFromNib(_ frame:CGRect) -> CommunityMapItem {
        let view = UINib(nibName: "CommunityMapItem", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let communityMapItem = CommunityMapItem(frame: frame)
        communityMapItem.addSubview(view)
        communityMapItem.imageView = view.viewWithTag(1) as! UIImageView
        communityMapItem.loadingView = view.viewWithTag(2) as! UIActivityIndicatorView
        communityMapItem.playerIcon = view.viewWithTag(4) as! UIImageView
        communityMapItem.addressLabel = view.viewWithTag(10) as! UILabel
        communityMapItem.dateLabel = view.viewWithTag(11) as! UILabel
        communityMapItem.reportedTypeLabel = view.viewWithTag(12) as! UILabel
        communityMapItem.counterLabel = view.viewWithTag(20) as! UILabel
        
        let imageButton = view.viewWithTag(3) as! UIButton
        imageButton.addTarget(communityMapItem, action: #selector(CommunityMapItem.showPhoto(_:)), for: .touchUpInside)
        
        communityMapItem.addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: communityMapItem, attribute: .leading, multiplier: 1.0, constant: 0))
        communityMapItem.addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: communityMapItem, attribute: .trailing, multiplier: 1.0, constant: 0))
        communityMapItem.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: communityMapItem, attribute: .top, multiplier: 1.0, constant: 0))
        communityMapItem.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: communityMapItem, attribute: .bottom, multiplier: 1.0, constant: 0))
        
        return communityMapItem
    }
    
}
