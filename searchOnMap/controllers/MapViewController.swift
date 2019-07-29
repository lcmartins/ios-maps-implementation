//
//  MapViewController.swift
//  searchOnMap
//
//  Created by Luciano de Castro Martins on 27/06/2018.
//  Copyright © 2018 luciano. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData

class MapViewController: UIViewController {
    
    // MARK: - properties
    
    var location: Location?
    var locations: [Location]?
    var coreDataProvider = CoreDataProvider()
    let kMapViewIdentifier = "mapView"
    
    // MARK: - overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBarButton()
    }
    
    override func loadView() {
        if let local = location,
            let lat = local.latitude,
            let lng = local.longitude {
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 18)
            let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
            mapView.mapType = .normal
            view = mapView
            generatePin(local, mapView: mapView)
            return
        }
        
        if let locals = locations,
            let local = locals.first,
            let lat = local.latitude,
            let lng = local.longitude {
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 6)
            let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
            view = mapView
            
            
            locals.forEach { (local) in
                generatePin(local, mapView: mapView)
            }
        }
    }
    
    // MARK: - core data methods
    
    @objc func saveData() {
        guard let local = location else { return }
        coreDataProvider.saveData(local)
        addBarButton()
    }
    
    @objc func deleteData() {
        let alertController = UIAlertController(title: "Delete record", message: "are you sure to delete?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Ok", style: .default) {[weak self] _  in
            guard let local = self?.location else { return }
            self?.coreDataProvider.deleteData(local)
            self?.addBarButton()
        }
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        alertController.addAction(confirmAction)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - private methods
    
    private func addBarButton()  {
        guard let local = location else { return }
        let savedData = coreDataProvider.isSaved(local)
        
        if let isSaved = savedData.isSaved,
            isSaved {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "delete", style: .plain, target: self, action: #selector(deleteData))
            return
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save", style: .plain, target: self, action: #selector(saveData))
    }
    
    private func generatePin(_ local: Location, mapView: GMSMapView) {
        guard let lat = local.latitude,
        let lng = local.longitude else { return }
        
        let pin = UIImage(named: "ball_marker")
        let pinView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 50))
        pinView.contentMode = .scaleAspectFill
        pinView.image = pin
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        marker.title = local.formattedAddress
        marker.snippet = local.coordinates
        marker.iconView = pinView
        marker.map = mapView
    }

}
