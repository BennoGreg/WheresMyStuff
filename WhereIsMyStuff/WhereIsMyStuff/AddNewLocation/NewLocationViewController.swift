//
//  NewLocationViewController.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 18.05.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit
import Mapbox
import MapboxGeocoder



class NewLocationViewController: UIViewController, MGLMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate{
    
    
    let geocoder = Geocoder.shared

    
    
    var query: String = "Krondorf 30"
    
    
    var homeStatic = CLLocationCoordinate2D(latitude: 48.523189, longitude: 13.944133)
    var locationManager = CLLocationManager()
    
    var initialStart = true
    
    let locationClass = LocationClass.locations
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addLocationMap: MGLMapView!
    @IBOutlet weak var locateButton: UIButton!
    
    var location = CLLocationCoordinate2D()
    var placemark: GeocodedPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        self.tabBarController?.tabBar.isHidden = true
        dismissKeyboard()
        

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        
        searchBar.delegate = self
        
        
        self.addLocationMap.autoresizingMask=[.flexibleWidth,.flexibleHeight]
        
        
        self.addLocationMap.styleURL = MGLStyle.streetsStyleURL
        self.addLocationMap.isZoomEnabled = true
        self.addLocationMap.delegate = self
       
        
        
        addLocationMap.showsUserLocation = true
        // Do any additional setup after loading the view.
        
        navigationController?.navigationBar.alpha = 0.9
        searchBar.alpha = 0.9
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        addLocationMap.removeFromSuperview()
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
  
    
    func lookUpAdress(searchString: String){
       let options = ForwardGeocodeOptions(query: searchString)
        
        //options.allowedISOCountryCodes = ["CA"]
        options.allowedScopes = [.address, .pointOfInterest]
        

        var coordinate: CLLocationCoordinate2D?
        
        let task = geocoder.geocode(options) { (placemarks, attribution, error) -> Void in
            guard let placemark = placemarks?.first else{
                return
            }
            if let coordinate = placemark.location?.coordinate, let postalAdress = placemark.postalAddress{
                self.addAnnotation(coordinate: coordinate, adress: placemark.address, postalAdress: postalAdress)
                self.locationManager.stopUpdatingLocation()
                self.placemark = placemark
                self.location = coordinate
                
            }
            
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.searchTextField.text{
            lookUpAdress(searchString: searchText)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinates = manager.location?.coordinate else {
            return
        }
        if initialStart{
            self.addLocationMap.setCenter(coordinates, animated: true)
            self.addLocationMap.zoomLevel = 17
            initialStart = true
        }
        
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        
    }
    
    
    
    func addAnnotation(coordinate: CLLocationCoordinate2D, adress: String?, postalAdress: CNPostalAddress){
        let annotation = MGLPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(postalAdress.street) \(adress ?? "")"
        annotation.subtitle = "\(postalAdress.city) \(postalAdress.postalCode), \(postalAdress.country)"
        if let annotations = self.addLocationMap.annotations{
            self.addLocationMap.removeAnnotations(annotations)
            
        }
        
        self.addLocationMap.addAnnotation(annotation)
        self.addLocationMap.setCenter(coordinate, animated: true)
        self.addLocationMap.zoomLevel = 17
        
    }
    
    @IBAction func getLocation(_ sender: UIButton) {
        guard let coordinate = locationManager.location?.coordinate else{
            return
        }
        
        addLocationMap.setCenter(coordinate, animated: true)
        var resultPlacemark: Placemark?
        getPlacemark(of: coordinate) { (placemark, error) in
            resultPlacemark = placemark
            print(resultPlacemark)
        }
        
        
    }
    
    
    func getPlacemark(of coordinate: CLLocationCoordinate2D, reverseCodingCompletionHandler: @escaping (GeocodedPlacemark, NSError?) -> Void){
        
        let options = ReverseGeocodeOptions(coordinate: coordinate)
        
        let task = geocoder.geocode(options) { (placemarks, attribution, error) in
            guard let placemark = placemarks?.first else{
                return
            }
            print(placemark.address)
            reverseCodingCompletionHandler(placemark,error)
        }
        
    }
    
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        return UIButton(type: .contactAdd)
    }
    
    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        mapView.deselectAnnotation(annotation, animated: false)
         
        // Show an alert containing the annotation's details
        let alert = UIAlertController(title: "Save your location", message: "Enter the name of your Location", preferredStyle: .alert)
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "Adresstype"
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in
            let postalAddress = self.placemark?.postalAddress
            let address = Int(self.placemark?.address ?? "")
            self.locationClass.save(coordinates: self.location, name: alert.textFields?[0].text ?? "Home", street: postalAddress?.street, houseNumber: address, city: postalAddress?.city, zipCode: Int(postalAddress?.postalCode ?? "0"), country: postalAddress?.country)
            self.tabBarController?.tabBar.isHidden = false
            self.navigationController?.popToRootViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



