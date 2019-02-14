//
//  CommunityMapController.swift
//  ReportedPD
//
//  Created by dev on 12/31/16.
//  Copyright © 2016 reported. All rights reserved.
//

import UIKit
import Parse
import GoogleMaps
import AVFoundation
import AVKit

class CommunityMapController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var carousel: iCarousel!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var allItems = [ReportModel]()
    var visibleItems = [ReportModel]()
    var currentMarker: GMSMarker!
    
    var locationManager: CLLocationManager!
    var myLocation = CLLocation(latitude: 40.7128, longitude: -74.0059)
    var foundMyLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.delegate = self
        mapView.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 9)
        carousel.type = .linear
        carousel.isPagingEnabled = true        
    }
    
    func initMap() {
        AppHelper.showLoading("Loading...")
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        let status = CLLocationManager.authorizationStatus()
        if (status == .notDetermined || status == .denied) {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func getData() {
       
        let query = PFQuery(className: "report")
        query.order(byDescending: "createdAt")
        query.whereKey("approved", equalTo: true)
        query.whereKey("public", equalTo: true)
        query.limit = 1000
        query.findObjectsInBackground(block: { (objects, error) in
            AppHelper.hideLoading()
            if error != nil {
                print("error" + (error?.localizedDescription)!)
            } else {
                
                var nearModel: ReportModel!
                var minDistance: Double = 160934    // 100mile
                for object in objects! {
                    let model = ReportModel(pfObject: object)
                    self.allItems.append(model)
                    
                    let distance = self.myLocation.distance(from: CLLocation(latitude: model.latitude, longitude: model.longitude))
                    if distance < minDistance {
                        minDistance = distance
                        nearModel = model
                    }
                }
                
                if self.foundMyLocation {
                    if minDistance < 160934 {
                        let latitude = self.myLocation.coordinate.latitude
                        let longitude = self.myLocation.coordinate.longitude
                        if nearModel != nil {
                            let dx = (nearModel.latitude - latitude) * 1.4
                            let dy = (nearModel.longitude - longitude) * 1.4
                            let bounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: latitude+dx, longitude: longitude+dy),
                                                             coordinate: CLLocationCoordinate2D(latitude: latitude-dx, longitude: longitude-dy))
                            self.mapView.camera = self.mapView.camera(for: bounds, insets: UIEdgeInsets())!
                            return
                        }
                    }
                    self.mapView.camera = GMSCameraPosition.camera(withTarget: self.myLocation.coordinate, zoom: 9)
                } else {
                    self.updatedCamera()
                }
            }
        })
    }
    
    func setMarker(_ index: Int) {
        
        if index < 0 || index >= visibleItems.count {
            return
        }
        
        let marker = visibleItems[index].marker!
        
        if currentMarker != marker {
            
            if currentMarker != nil {
                (currentMarker.iconView as! MapPin).unselectPin()
            }
            
            currentMarker = marker
            currentMarker.map = mapView
            (currentMarker.iconView as! MapPin).selectPin()
        }
    }
    
    func updatedCamera() {
        
        // init data
        var oldReportItems = visibleItems
        visibleItems.removeAll()
        
        // get items
        for item in allItems {
            if mapView.projection.contains(CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)) {
                visibleItems.append(item)
            }
        }
        
        var currentIndex = 0
        
        if visibleItems.count > 0 {
            
            // sort items
            visibleItems.sort(by: { (item1, item2) -> Bool in
                let dist1 = myLocation.distance(from: CLLocation(latitude: item1.latitude, longitude: item1.longitude))
                let dist2 = myLocation.distance(from: CLLocation(latitude: item2.latitude, longitude: item2.longitude))
                return Double(dist1) < Double(dist2)
            })
            
            // make marks
            for index in 0..<visibleItems.count {
                let item = visibleItems[index]
                
                // check old marks
                for index1 in 0..<oldReportItems.count {
                    let oldItem = oldReportItems[index1]
                    if item == oldItem {
                        oldReportItems.remove(at: index1)
                        break
                    }
                }
                
                // create mark
                if item.marker == nil {
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
                    marker.appearAnimation = GMSMarkerAnimation.pop
                    marker.iconView = MapPin.create(number: index+1)
                    item.marker = marker
                } else {
                    (item.marker?.iconView as! MapPin).numberLabel.text = String(index+1)
                    if currentMarker == item.marker {
                        currentIndex = index
                    }
                }
                item.marker?.map = mapView
            }
            
        }
        
        carousel.reloadData()
        carousel.isScrollEnabled = visibleItems.count > 1
        if visibleItems.count > 0 {
            carousel.currentItemIndex = currentIndex
            setMarker(currentIndex)
        }
        
        emptyLabel.isHidden = visibleItems.count > 0
        
        // remove old marks
        for oldItem in oldReportItems {
            oldItem.marker?.map = nil
        }
        
    }
    
}

extension CommunityMapController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        updatedCamera()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let mapPin = marker.iconView as! MapPin
        let index = Int(mapPin.numberLabel.text!)
        carousel.currentItemIndex = index! - 1
        return true
    }
    
}

extension CommunityMapController: iCarouselDataSource {
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return visibleItems.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        //create new view if no view is available for recycling
        
        var communityItem: CommunityMapItem!
        if view == nil {
            communityItem = CommunityMapItem.instanceFromNib(carousel.bounds)
        } else {
            communityItem = view as! CommunityMapItem
        }
        
        communityItem.item = visibleItems[index]
        communityItem.counterLabel.text = "\(index+1) of \(visibleItems.count)"
        return communityItem
    }
    
}

extension CommunityMapController: iCarouselDelegate {
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case .wrap:
            return 1
        default:
            return value
        }
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        setMarker(carousel.currentItemIndex)
    }
    
}

extension CommunityMapController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locationManager != nil {
            locationManager.stopUpdatingLocation()
            locationManager = nil
            foundMyLocation = true
            myLocation = locations.last!
            getData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        locationManager = nil
        getData()
    }
}
