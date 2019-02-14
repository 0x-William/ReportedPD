//
//  CommunityCell.swift
//  ReportedPD
//
//  Created by dev on 12/31/16.
//  Copyright © 2016 reported. All rights reserved.
//

import UIKit

class CommunityCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tagList: TagListView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var reportedTypeLabel: UILabel!
    @IBOutlet weak var describeLabel: UILabel!    
    @IBOutlet weak var photoView0: PhotoView!
    @IBOutlet weak var photo0HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoView1: PhotoView!
    @IBOutlet weak var photo1HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoView2: PhotoView!
    @IBOutlet weak var photo2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoView3: PhotoView!
    @IBOutlet weak var photo3HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoView4: PhotoView!
    @IBOutlet weak var photo4HeightConstraint: NSLayoutConstraint!
    
    var item: ReportModel?
    
    var photoViewList: [(PhotoView, NSLayoutConstraint)]!
    
    func initPhotoView() {
        if photoViewList == nil {
            photoViewList = [
                (photoView0, photo0HeightConstraint),
                (photoView1, photo1HeightConstraint),
                (photoView2, photo2HeightConstraint),
                (photoView3, photo3HeightConstraint),
                (photoView4, photo4HeightConstraint)
            ]
            
            for (photoView, _) in photoViewList {
                photoView.deleteButton.removeFromSuperview()
                photoView.titleField.removeFromSuperview()
            }
        }
    }
    
}
