//
//  FindVC.swift
//  streetParker
//
//  Created by Jamil Jalal on 11/15/19.
//  Copyright © 2019 Jamil Jalal. All rights reserved.
//

import UIKit
import Firebase
//import MapboxCoreNavigation
import MapboxNavigation
//import MapboxDirections

class FindVC: UIViewController, MGLMapViewDelegate {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var view2: UIView!
    var mapView: NavigationMapView!
    var navigateButton : UIButton!
    //var directionRoute: Route?
    
    let disneylandcoord = CLLocationCoordinate2D(latitude: 40.7366, longitude: -73.8201)
    
    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.
        button.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        self.view2.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view2.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        
        mapView = NavigationMapView(frame: view2.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view2.addSubview(mapView)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        //mapView.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        mapView.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        
        
        addButton()
        
        
       
    }
    
    
    func addButton(){
        navigateButton = UIButton(frame: CGRect(x: (view2.frame.width/2) - 100, y: view2.frame.height - 80, width: 200, height: 50))
        navigateButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        navigateButton.setTitle("Navigate", for: .normal)
        navigateButton.setTitleColor(UIColor(displayP3Red: 59/255, green: 170/255, blue: 208/255, alpha: 1), for: .normal)
        navigateButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 10)
        navigateButton.layer.cornerRadius = 25
        navigateButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        navigateButton.layer.shadowColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        navigateButton.layer.shadowRadius = 5
        navigateButton.layer.shadowOpacity = 0.3
        navigateButton.addTarget(self, action: #selector(navigateButtonWasPressed(_:)), for: .touchUpInside)
        view2.addSubview(navigateButton)
    }


    @objc func navigateButtonWasPressed(_ sender: UIButton){
        mapView.setUserTrackingMode(.none, animated: false)
        
        let annotation = MGLPointAnnotation()
        annotation.coordinate = disneylandcoord
        
        
        let coordinateBounds = MGLCoordinateBounds(sw: disneylandcoord, ne: mapView.userLocation!.coordinate)
        let inset = UIEdgeInsets(top: 58, left: 58, bottom: 58, right: 58)
        let routeCam = mapView.cameraThatFitsCoordinateBounds(coordinateBounds, edgePadding: inset)
        mapView.setCamera(routeCam, animated: true)
        mapView.addAnnotation(annotation)
//        calculateRoute(from: (mapView.userLocation!.coordinate), to: disneylandcoord) { (route, error) in
//            if error != nil {
//                print("error getting route")
//            }
//        }
    }
    
//    func calculateRoute(from originCoor: CLLocationCoordinate2D, to destinationCoor: CLLocationCoordinate2D, completion: @escaping (Route?, Error?) -> Void){
//
//        let origin = Waypoint(coordinate: originCoor, coordinateAccuracy: -1, name: "Start")
//        let destination = Waypoint(coordinate: originCoor, coordinateAccuracy: -1, name: "Finish")
//
//        let options = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)
//
//        Directions.shared.calculate(options) { (waypoints, route, error) in
//            self.directionRoute = route?.first
//            self.drawRoute(route: self.directionRoute!)
//            //drae line
//
//            let coordinateBounds = MGLCoordinateBounds(sw: destinationCoor, ne: originCoor)
//            let inset = UIEdgeInsets(top: 58, left: 58, bottom: 58, right: 58)
//            let routeCam = self.mapView.cameraThatFitsCoordinateBounds(coordinateBounds, edgePadding: inset)
//            self.mapView.setCamera(routeCam, animated: true)
//        }
//    }
    
//    func drawRoute(route: Route){
//        guard route.coordinateCount > 0 else {return}
//        let routeCoordinates = route.coordinates!
//        let polyline = MGLPolylineFeature(coordinates: routeCoordinates, count: route.coordinateCount)
//
//
//        if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource{
//            source.shape = polyline
//        } else {
//            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
//
//            let linestyle = MGLLineStyleLayer(identifier: "route-style", source: source)
//            linestyle.lineColor = NSExpression(forConstantValue: UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1))
//            linestyle.lineWidth = NSExpression(forConstantValue: 4.0)
//
//            mapView.style?.addSource(source)
//            mapView.style?.addLayer(linestyle)
//        }
//    }
}
