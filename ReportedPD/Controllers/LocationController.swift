//
//  LocationController.swift
//  ReportedPD
//
//  Created by dev on 12/30/16.
//  Copyright © 2016 reported. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class LocationController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var searchController: UISearchController!
    
    var coordinate: CLLocationCoordinate2D!
    var address: String!
    var selectedCallback: ((CLLocationCoordinate2D, (String, String)) -> Void)!
    
    var observer = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if selectedCallback == nil {
            navBar.items?[0].rightBarButtonItem = nil
            
            searchButton.isHidden = true
            pinImageView.isHidden = true
            
            let marker = GMSMarker()
            marker.map = mapView
            marker.snippet = address
            marker.position = coordinate
            marker.icon = UIImage(named: "map-default-pin")
            mapView.selectedMarker = marker
        } else {
            mapView.delegate = self
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
        
        if coordinate != nil {
            mapView.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 15)
        } else {
            mapView.addObserver(self, forKeyPath: "myLocation", options: .new, context: nil)
            observer = true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if observer {
            mapView.removeObserver(self, forKeyPath: "myLocation")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {        
        mapView.removeObserver(self, forKeyPath: "myLocation")
        observer = false
        if (coordinate == nil) {
            let location = change?[NSKeyValueChangeKey.newKey] as! CLLocation
            coordinate = location.coordinate
            mapView.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 15)
        }
    }
    
    @IBAction func searchLocation(_ sender: AnyObject) {
        let resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController.searchResultsUpdater = resultsViewController
        present(searchController!, animated: true, completion: nil)
    }
    
    @IBAction func updateAction(_ sender: AnyObject) {
        
        AppHelper.showLoading("")
        GMSGeocoder().reverseGeocodeCoordinate(coordinate) { (response, error) in
            AppHelper.hideLoading()
            
            let results: [GMSAddress] = (response?.results())!

            var address = ""
            if results.count > 0 {
                let lines = results[0].lines!
                if lines.count > 1 {
                    for i in 0..<lines.count {
                        if address != "" {
                            address = address + ", "
                        }
                        address = address + lines[i]
                    }
                }
            }
            
            var address1 = ""
            if results.count > 1 {
                let lines = results[1].lines!
                if lines.count > 1 {
                    for i in 0..<lines.count {
                        if address1 != "" {
                            address1 = address1 + ", "
                        }
                        address1 = address1 + lines[i]
                    }
                }
            }
            
            self.dismiss(animated: true, completion: {
                self.selectedCallback?(self.coordinate, (address, address1))
            })
        }
        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    static func showModal(coordinate: CLLocationCoordinate2D!, address: String!,
                          selectedCallback:((CLLocationCoordinate2D, (String, String)) -> Void)!) {
        
        let topController = AppHelper.getTopController()!
        let controller = topController.storyboard?.instantiateViewController(withIdentifier: "LocationController") as! LocationController
        controller.coordinate = coordinate
        controller.address = address
        controller.selectedCallback = selectedCallback
        topController.present(controller, animated: true, completion: nil)
        
    }
    
}

extension LocationController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        coordinate = position.target
    }
    
}

extension LocationController: GMSAutocompleteResultsViewControllerDelegate {
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        mapView.camera = GMSCameraPosition.camera(withTarget: place.coordinate, zoom: 15)
        searchController.dismiss(animated: true, completion: nil)
    }
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        dismiss(animated: true, completion: nil)
        print("Error: ", error.localizedDescription)
    }
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}


