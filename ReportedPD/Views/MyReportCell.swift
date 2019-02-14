//
//  MyReportCell.swift
//  ReportedPD
//
//  Created by dev on 1/30/17.
//  Copyright © 2017 reported. All rights reserved.
//

import UIKit
import Parse
class MyReportCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var border: CALayer!
    
    func drawUnderLine() {
        if border != nil {
            border.removeFromSuperlayer()
        }
        
        border = CALayer()
        border.borderColor = UIColor(red: 235/255.0, green: 235/255.0, blue: 235/255.0, alpha: 1).cgColor
        border.borderWidth = 0.5
        border.frame = CGRect(x: 10, y: containerView.frame.size.height - 0.5, width: containerView.frame.size.width - 10, height: 0.5)
        containerView.layer.addSublayer(border)
    }
}
