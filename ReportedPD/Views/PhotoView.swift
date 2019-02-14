//
//  PhotoView.swift
//  ReportedPD
//
//  Created by dev on 1/23/17.
//  Copyright © 2017 reported. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class PhotoView: UIView {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var playIcon: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    
    var model: MediaModel!
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        titleField.settingDoneToolbar()
    }
    
    func xibSetup() {
        let bundle = Bundle(for: self.classForCoder)
        let nib = UINib(nibName: "PhotoView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }

    @IBAction func showPhoto(_ sender: Any) {
        model?.showMedia(imageRect: (sender as! UIView).frame)
    }

}

