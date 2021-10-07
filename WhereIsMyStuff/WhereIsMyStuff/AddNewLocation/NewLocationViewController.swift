//
//  NewLocationViewController.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 18.05.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit
import CoreLocation
import MapboxMaps
import MapboxGeocoder
import Contacts



class NewLocationViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate{
    
    
    let geocoder = Geocoder.shared

    
    
    var query: String = "Krondorf 30"
    
    
    var homeStatic = CLLocationCoordinate2D(latitude: 48.523189, longitude: 13.944133)
    var locationManager = CLLocationManager()
    internal lazy var annotationManager: PointAnnotationManager = {
        return addLocationMap.annotations.makePointAnnotationManager()
    }()
    
    var initialStart = true
    
    let locationClass = LocationClass.locations
    var style: StyleURI {
        get {
            if let style = StyleURI(rawValue: MapStyle.shared.mapStyleUrl) {
                return style
            }
            return .light
        }
    }
    
    
    
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var locateButton: UIButton!
    
    
    var location = CLLocationCoordinate2D()
    var placemark: GeocodedPlacemark?
    var addLocationMap: MapView!
    var eventCancelable: Cancelable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        self.tabBarController?.tabBar.isHidden = true
        dismissKeyboard()
        

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        let addLocationButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(NewLocationViewController.saveLocation(sender:)))
        self.navigationItem.rightBarButtonItem = addLocationButton
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        searchBar.delegate = self
        
        
        addLocationMap = MapView(frame: parentView.bounds)
        
    
        self.addLocationMap.autoresizingMask=[.flexibleWidth,.flexibleHeight]
        
        addLocationMap.mapboxMap.loadStyleURI(style) {[weak self] result in
            guard let strongself = self else {return}
            switch result {
            case .success(_):
                print("Map loaded style")
                if CLLocationManager.locationServicesEnabled() {
                    strongself.locationManager.delegate = self
                    strongself.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    strongself.locationManager.startUpdatingLocation()
                }
            case let .failure(error):
                print("An error ocurred \(error)")
            }
        }
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewLocationViewController.hideKeyboard))
        addLocationMap.hideKeyboardWhenTappedAround(tap: tap)
        
        
        //addLocationMap.showsUserLocation = true
        // Do any additional setup after loading the view.
        
        navigationController?.navigationBar.alpha = 0.9
        searchBar.alpha = 0.9
        parentView.addSubview(addLocationMap)
        parentView.sendSubviewToBack(addLocationMap)
        //annotationManager.delegate = self //Bug in MapBox SDK
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        addLocationMap.removeFromSuperview()
    }
    
//    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
//        return true
//    }
    

    
    func lookUpAdress(searchString: String){
       let options = ForwardGeocodeOptions(query: searchString)
        
        //options.allowedISOCountryCodes = ["CA"]
        options.allowedScopes = [.address, .pointOfInterest]
        

        var coordinate: CLLocationCoordinate2D?
        
        let task = geocoder.geocode(options) { [self](placemarks, attribution, error) -> Void in
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
            self.addLocationMap.location.options.puckType = .puck2D()
            self.addLocationMap.mapboxMap.setCamera(to: CameraOptions(center: coordinates, zoom: 17))
            //self.addLocationMap.zoomLevel = 17
            initialStart = true
        }
        
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        
    }
    
    
    
    func addAnnotation(coordinate: CLLocationCoordinate2D, adress: String?, postalAdress: CNPostalAddress){
        var annotation = PointAnnotation.init(coordinate: coordinate)
        //annotation.textField = "\(postalAdress.street) \(adress ?? "")"
        
        let userInfo = [LocationKey.street.rawValue: postalAdress.street,
                        LocationKey.number.rawValue: adress ?? "",
                        LocationKey.zipCode.rawValue: postalAdress.postalCode,
                        LocationKey.country.rawValue: postalAdress.country]
        
        annotation.userInfo = userInfo

        //annotation.subtitle = "\(postalAdress.city) \(postalAdress.postalCode), \(postalAdress.country)"
        annotation.image = .init(image: UIImage(named: "red_pin")!, name: "red_pin")
        annotationManager.annotations = [annotation]
        
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        
        addLocationMap.mapboxMap.setCamera(to: CameraOptions(center: coordinate, zoom: 17))
        
    }
    
    @IBAction func getLocation(_ sender: UIButton) {
        guard let coordinate = locationManager.location?.coordinate else{
            return
        }
    
        addLocationMap.mapboxMap.setCamera(to: CameraOptions(center: coordinate, zoom: 17))
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
    
    
    fileprivate func presentAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
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
    
    
    
    @objc func saveLocation(sender: UIBarButtonItem) {
        guard let userinfo = annotationManager.annotations[0].userInfo else { return }
        
        let message = """
            \(userinfo[LocationKey.street.rawValue] ?? "") \(userinfo[LocationKey.number.rawValue] ?? "")
            Enter the name of your Location
            """
        let title = "Save your location"
        
        presentAlert(title, message)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        addLocationMap.mapboxMap.loadStyleURI(style)
    }
    
    @objc func hideKeyboard() {
        searchBar.endEditing(true)
    }
    
    /// Function to add Annotation by clicking on annotation (currently not possible due to Bug in MapBox SDK)
    
//    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
//        print("from Function: \(manager.sourceId)")
//        print("from self: \(annotationManager.sourceId)")
//        guard let userinfo = annotationManager.annotations[0].userInfo else { return }
//
//        let message = """
//            \(userinfo[LocationKey.street.rawValue] ?? "") \(userinfo[LocationKey.number.rawValue] ?? "")
//            Enter the name of your Location
//            """
//        let title = "Save your location"
//
//        presentAlert(title, message)
//    }
    
//    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
//        mapView.deselectAnnotation(annotation, animated: false)
//         
//        // Show an alert containing the annotation's details
//        let alert = UIAlertController(title: "Save your location", message: "Enter the name of your Location", preferredStyle: .alert)
//        
//        alert.addTextField { (textfield) in
//            textfield.placeholder = "Adresstype"
//        }
//        
//        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in
//            let postalAddress = self.placemark?.postalAddress
//            let address = Int(self.placemark?.address ?? "")
//            self.locationClass.save(coordinates: self.location, name: alert.textFields?[0].text ?? "Home", street: postalAddress?.street, houseNumber: address, city: postalAddress?.city, zipCode: Int(postalAddress?.postalCode ?? "0"), country: postalAddress?.country)
//            self.tabBarController?.tabBar.isHidden = false
//            self.navigationController?.popToRootViewController(animated: true)
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        
//        
//        self.present(alert, animated: true, completion: nil)
//    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}




