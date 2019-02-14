//
//  HomeController.swift
//  ReportedPD
//
//  Created by dev on 12/29/16.
//  Copyright © 2016 reported. All rights reserved.
//

import UIKit
import Parse
import SVPullToRefresh

class HomeController: UIViewController {
    
    static var refreshRequest = false
    
    @IBOutlet weak var reportButtonView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    //var reports = [(PFObject?, CGFloat)]()
    var reports = [ReportModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //_ = reportButtonView.addUnderline(width: 0.5, color: AppData.borderColor)
        
        tableView.addInfiniteScrolling {
            self.getNextData()
        }
        
        if AppData.data.count == 0 {
            AppData.getDefineData(completed: {
                self.tableView.triggerInfiniteScrolling()
            })
        } else {
            HomeController.refreshRequest = true
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if HomeController.refreshRequest {
            HomeController.refreshRequest = false
            reports.removeAll()
            tableView.reloadData()
            tableView.triggerInfiniteScrolling()
        }
    }
    
    func getNextData() {
        
        let query = PFQuery(className: "report")
        query.order(byDescending: "createdAt")
        query.whereKey("user", equalTo: PFUser.current())
        query.skip = reports.count
        query.limit = 10
        query.findObjectsInBackground(block: { (objects, error) in
            
            if error == nil {
                for object in objects! {
                    self.reports.append(ReportModel(pfObject: object))
                }
                self.tableView.reloadData()
            } else {
                AppHelper.handleError(error)
            }
            
            self.tableView.infiniteScrollingView.stopAnimating()
            
        })
        
    }
    
    @IBAction func reportAction(_ sender: Any) {
        ReportController.pushController(reportModel: nil, isCommendType: false)
    }
    
    @IBAction func commendAction(_ sender: Any) {
        ReportController.pushController(reportModel: nil, isCommendType: true)
    }
    
}


extension HomeController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = reports[indexPath.row]
        return (item.cellHeight != 0) ? item.cellHeight : 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ReportController.pushController(reportModel: reports[indexPath.row], isCommendType: false)
    }
    
}

extension HomeController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyReportCell", for: indexPath) as! MyReportCell
        
        let reportModel = reports[indexPath.row]
        
        cell.descLabel.text = reportModel.describe
        cell.dateLabel.text = reportModel.getDateTimeString()
        
        cell.layoutIfNeeded()
        cell.sizeToFit()
        reportModel.cellHeight = cell.containerView.frame.size.height
        
        cell.drawUnderLine()
        
        return cell
        
    }
    
}
