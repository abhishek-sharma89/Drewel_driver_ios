//
//  MapViewVC.swift
//  DrewelDriver
//
//  Created by Octal on 10/09/18.
//  Copyright © 2018 Octal. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewVC: UIViewController {
    @IBOutlet weak var customView: UIView!
    
    var mapView = GMSMapView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadMapView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadMapView() {
        DispatchQueue.main.async {
            
            let camera = GMSCameraPosition.camera(withLatitude: currentLat, longitude: currentLng,
                                                  zoom: 16)
            self.mapView = GMSMapView.map(withFrame: self.customView.bounds, camera: camera)
            self.mapView.isMyLocationEnabled = true //self.isProvider;
            self.mapView.camera = camera;
            self.mapView.settings.myLocationButton = false;
            self.mapView.tintColor = kThemeColor1;
            
            do {
                // Set the map style by passing the URL of the local file. Make sure style.json is present in your project
                if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                    self.mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    print("Unable to find style.json")
                }
            } catch {
                print("The style definition could not be loaded: \(error)")
            }
            self.mapView.removeFromSuperview()
            self.customView.addSubview(self.mapView)
            
//            self.setDestinationMarkerView()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
