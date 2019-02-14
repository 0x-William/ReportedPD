//
//  AllegationsController.swift
//  ReportedPD
//
//  Created by dev on 1/7/17.
//  Copyright © 2017 reported. All rights reserved.
//

import UIKit

class AllegationsController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    var categorys = [String]()
    var allegations = [[String]]()
    
    var selections = [String]()
    
    var selectedCallback: (([String]) -> Void)!
    
    var isCommendType = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let allData = isCommendType ? AppData.getCommendationData() : AppData.getAllegationData()
        navItem.title = isCommendType ? "Commendations" : "Allegations"
        for (key, value) in allData {
            categorys.append(key)
            allegations.append(value)
        }
        
    }
    
    @IBAction func updateAction(_ sender: Any) {
        dismiss(animated: true, completion: {
            self.selectedCallback?(self.selections)
        })
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension AllegationsController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categorys.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categorys[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allegations[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath)
        
        let allegation = allegations[indexPath.section][indexPath.row];
        cell.textLabel?.text = allegation
        
        cell.accessoryType = selections.contains(allegation) ? .checkmark : .none
        
        return cell
        
    }
    
}

extension AllegationsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let allegation = allegations[indexPath.section][indexPath.row];
        
        if selections.contains(allegation) {
            selections.remove(at: selections.index(of: allegation)!)
        } else {
            selections.append(allegation)
        }
        
        tableView.reloadData()

    }
    
}
