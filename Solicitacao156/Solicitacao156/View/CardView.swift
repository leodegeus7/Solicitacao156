//
//  CardView.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 10/06/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class CardView: UIView,MKMapViewDelegate {

    @IBOutlet weak var cardSubView: UIView!
    
    @IBOutlet weak var spinView: UIActivityIndicatorView!
    var contatosSuper:ContatosTableViewController!
    var contact:Contact!
    
    @IBOutlet weak var cancelLabel: UIButton!
    
    @IBOutlet weak var foneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func draw(_ rect: CGRect) {
        print("teste")
        spinView.isHidden = true
                cancelLabel.setTitleColor(Constants.color, for: .normal)
        nameLabel.text = contact.name
        addressLabel.text = contact.address
        foneLabel.text = contact.fone
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CardView.tapAddress))
        addressLabel.isUserInteractionEnabled = true
        addressLabel.addGestureRecognizer(tap)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(CardView.tapFone))
        foneLabel.isUserInteractionEnabled = true
        foneLabel.addGestureRecognizer(tap2)
        cardSubView.layer.cornerRadius = 10
        mapView.delegate = self
        findPlace()
    }
    
    @objc func tapAddress() {
        let geocoder = CLGeocoder()
        let locationString = contact.address
        spinView.isHidden = false
        self.isUserInteractionEnabled = false
        geocoder.geocodeAddressString(locationString) { (placemarks, error) in
            self.spinView.isHidden = true
            self.isUserInteractionEnabled = true
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let location = placemarks?.first?.location {
                    let coordinates = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude)
                    let regionSpan =   MKCoordinateRegionMakeWithDistance(coordinates, 1000, 1000)
                    let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = self.contact.name
                    mapItem.openInMaps(launchOptions:[
                    MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center)
                    ] as [String : Any])
                }
            }
        }
    }
    
    func findPlace() {
        var localSearchRequest:MKLocalSearchRequest!
        var localSearch:MKLocalSearch!
        var pointAnnotation:MKPointAnnotation!
        var pinAnnotationView:MKPinAnnotationView!
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = contact.address
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))

                return
            }
            
            pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = self.contact.name
            let coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            pointAnnotation.coordinate = coordinate
            
            
            pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = pointAnnotation.coordinate
            self.mapView.addAnnotation(pinAnnotationView.annotation!)
            

            self.zoomToLocation(location: coordinate)
        }
    }
    
    func zoomToLocation(location : CLLocationCoordinate2D,latitudinalMeters:CLLocationDistance = 100,longitudinalMeters:CLLocationDistance = 100)
    {
        let region = MKCoordinateRegionMakeWithDistance(location, latitudinalMeters, longitudinalMeters)
        mapView.setRegion(region, animated: true)
    }
    
    @objc func tapFone() {
        var fone = contact.fone
        fone = fone.replacingOccurrences(of: "(", with: "")
        fone = fone.replacingOccurrences(of: ")", with: "")
        fone = fone.replacingOccurrences(of: " ", with: "")
        fone = fone.replacingOccurrences(of: "-", with: "")

        if let url = URL(string: "tel://\(contact)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    @IBAction func buttonOffClicked(_ sender: Any) {
        dismiss()
    }
    @IBAction func buttonXClicked(_ sender: Any) {
        dismiss()
    }
    
    func dismiss() {
        removeFromSuperview()
    }
    
}
