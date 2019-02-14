//
//  CommunityController.swift
//  ReportedPD
//
//  Created by dev on 12/31/16.
//  Copyright © 2016 reported. All rights reserved.
//

import UIKit
import Parse

class CommunityController: UIViewController {

    @IBOutlet weak var switchButton: UIBarButtonItem!
    
    var listController: CommunityListController!
    var mapController: CommunityMapController!
    
    var initializedMap = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listController = storyboard?.instantiateViewController(withIdentifier: "CommunityListController") as! CommunityListController
        addChildViewController(listController)
        view.addSubview(listController.view)

        mapController = storyboard?.instantiateViewController(withIdentifier: "CommunityMapController") as! CommunityMapController
        addChildViewController(mapController!)
        view.addSubview(mapController.view)
        
        mapController?.view.isHidden = true
    }
    
    @IBAction func switchView(_ sender: AnyObject) {
        if mapController.view.isHidden {
            switchButton.image = UIImage(named: "community-list-icon")
            listController.view.isHidden = true
            mapController.view.isHidden = false
            if !initializedMap {
                initializedMap = true
                mapController.initMap()
            }
        } else {
            switchButton.image = UIImage(named: "community-map-icon")
            listController.view.isHidden = false
            mapController.view.isHidden = true
        }
    }
}
