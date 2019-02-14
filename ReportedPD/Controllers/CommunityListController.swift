//
//  CommunityListController.swift
//  ReportedPD
//
//  Created by dev on 12/31/16.
//  Copyright © 2016 reported. All rights reserved.
//

import UIKit
import Parse
import Photos
import SVPullToRefresh

class CommunityListController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var alertLabelHeightConstraint: NSLayoutConstraint!
    
    var locationManager: CLLocationManager!
    var myLocation: CLLocation!
    
    var reportItems = [ReportModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.addPullToRefresh {
            if self.myLocation != nil {
                self.getNextData(infinite: false)
            } else {
                self.locationManager = CLLocationManager()
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.startUpdatingLocation()
                let status = CLLocationManager.authorizationStatus()
                if (status == .notDetermined || status == .denied) {
                    self.locationManager.requestWhenInUseAuthorization()
                }
            }
        }
        tableView.addInfiniteScrolling {
            if self.reportItems.count > 0 {
                self.getNextData(infinite: true)
            } else {
                self.tableView.infiniteScrollingView.stopAnimating()
            }
        }
        
        tableView.triggerPullToRefresh()
        
    }
    
    func getNextData(infinite: Bool) {
        
        if !infinite {
            let query = PFQuery(className: "report")
            query.whereKeyDoesNotExist("approved")
            query.countObjectsInBackground(block: { (count, error) in
                if error != nil {
                    self.alertLabelHeightConstraint.constant = 0
                } else {
                    if count == 0 {
                        self.alertLabelHeightConstraint.constant = 0
                    } else {
                        self.alertLabelHeightConstraint.constant = 26
                        self.alertLabel.text = "\(count) pending submissions"
                    }
                }
            })
        }
        
        let query = PFQuery(className: "report")
        query.order(byDescending: "createdAt")
        query.whereKey("approved", equalTo: true)
        query.whereKey("public", equalTo: true)
        if myLocation != nil {
            query.whereKey("position", nearGeoPoint: PFGeoPoint(location: myLocation), withinMiles: 100)
        }
        query.includeKey("user")
        query.skip = infinite ? reportItems.count : 0
        query.limit = 10
        query.findObjectsInBackground(block: { (objects, error) in
            if error != nil {
                print("error" + (error?.localizedDescription)!)
            } else {
                if !infinite {
                    self.reportItems.removeAll()
                }
                
                let currentYear = Calendar.current.component(.year, from: Date())
                
                for object in objects! {
                    let user = object["user"] as! PFObject
                    var userInfo = [String]()
                    if let race = user["race"] as? String {
                        if !race.isEmpty {
                            userInfo.append(race)
                        }
                    }
                    if let birthYear = user["birthYear"] as? String {
                        if !birthYear.isEmpty {
                            let year = currentYear - Int(birthYear)!
                            userInfo.append("\(year) years old")
                        }
                    }
                    if let gender = user["gender"] as? String {
                        if gender == "Male" || gender == "Transgender Male" {
                            userInfo.append("Male")
                        } else if gender == "Female" || gender == "Transgender Female" {
                            userInfo.append("Female")
                        }
                    }
                    let model = ReportModel(pfObject: object)
                    model.userInfo = model.person != nil ? model.person.userType : model.user_type
                    if userInfo.count > 0 {
                        model.userInfo = model.userInfo + " (\(userInfo.joined(separator: ", ")))"
                    }
                    self.reportItems.append(model)
                }
                self.emptyLabel.isHidden = self.reportItems.count != 0
                self.tableView.reloadData()
            }
            if infinite {
                self.tableView.infiniteScrollingView.stopAnimating()
            } else {
                self.tableView.pullToRefreshView.stopAnimating()
            }
        })
    }

}

extension CommunityListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = reportItems[indexPath.row]
        return (item.cellHeight != 0) ? item.cellHeight : 100
    }
    
}

extension CommunityListController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return reportItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityCell", for: indexPath) as! CommunityCell;
        cell.initPhotoView()
        
        let item = reportItems[indexPath.row]
        
        cell.tagList.tagBackgroundColor = item.commendation ? AppData.orangeColor : AppData.blueColor
        cell.tagList.removeAllTags()
        cell.tagList.addTags(item.allegations)
        cell.addressLabel.text = item.address != "" ? item.address : "address unknown"
        cell.dateLabel.text = item.getDays()
        cell.reportedTypeLabel.text = "Reported by: " + item.userInfo
        
        cell.describeLabel.text = item.describe
        
        for i in 0..<cell.photoViewList.count {
            
            let (photoView, constraint) = cell.photoViewList[i]
            
            photoView.imgView.image = nil
            photoView.loadingIcon.isHidden = true
            
            if i < item.mediaList.count {
                
                let mediaModel = item.mediaList[i]
                
                photoView.model = mediaModel
                photoView.playIcon.isHidden = !mediaModel.isVideo || mediaModel.assetPath == nil
                
                if mediaModel.image != nil {
                    
                    cell.layoutIfNeeded()
                    photoView.imgView.image = mediaModel.image
                    let w = mediaModel.image.size.width
                    constraint.constant = photoView.frame.size.width * (mediaModel.image.size.height + 20*w/295) / (325*w/295)
                    
                } else if cell.item != item {
                    
                    constraint.constant = 50
                    photoView.loadingIcon.isHidden = false
                    photoView.loadingIcon.startAnimating()
                    
                    if mediaModel.imageFile != nil {
                        
                        mediaModel.imageFile.getDataInBackground(block: { (data, error) in
                            if (error == nil) {
                                mediaModel.image = UIImage(data: data!)
                                tableView.reloadRows(at: [indexPath], with: .none)
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
                                    mediaModel.assetPath = path
                                    tableView.reloadRows(at: [indexPath], with: .none)
                                } catch {
                                    print("error")
                                }
                            }
                        })
                    }
                    
                }
                
            } else {
                photoView.model = nil
                photoView.playIcon.isHidden = true
                constraint.constant = 0
            }
        }
        
        cell.item = item
        
        cell.layoutIfNeeded()
        cell.sizeToFit()
        item.cellHeight = cell.containerView.frame.size.height
        
        return cell
    }
}

extension CommunityListController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if myLocation == nil {
            locationManager.stopUpdatingLocation()
            locationManager = nil
            myLocation = locations.last
            getNextData(infinite: false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        locationManager = nil
        getNextData(infinite: false)
    }
}
