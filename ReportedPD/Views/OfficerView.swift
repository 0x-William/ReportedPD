//
//  OfficerView.swift
//  ReportedPD
//
//  Created by dev on 1/23/17.
//  Copyright © 2017 reported. All rights reserved.
//

import UIKit

class OfficerView: UIView {

    @IBOutlet weak var userButton: UIButton!
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        let bundle = Bundle(for: self.classForCoder)
        let nib = UINib(nibName: "OfficerView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }

}
