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
import CoreBluetooth
import AVFoundation
import FBSDKCoreKit
import FBSDKLoginKit

class FindVC: UIViewController, MGLMapViewDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    var periph: CBPeripheral!
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var view2: UIView!
    var mapView: NavigationMapView!
    var navigateButton : UIButton!
    //var directionRoute: Route?
    let disneylandcoord = CLLocationCoordinate2D(latitude: 40.7366, longitude: -73.8201)
    let serviceUUID = CBUUID(string: "780A")
    var allPeripherals: [CBPeripheral]?
    var blueoothh = AVAudioSession.sharedInstance()
    var peripheralUID: String!
    var peripheralName: String!
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is on.")
//            let options: [String: Any] = [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: false)]
//            centralManager.scanForPeripherals(withServices: nil, options: nil)
            break
        case .poweredOff:
            print("Bluetooth is Off.")
            break
        case .resetting:
            break
        case .unauthorized:
            break
        case .unsupported:
            break
        case .unknown:
            break
        default:
            break
        }
    }
    
    
    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.
        button.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        self.view2.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view2.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
//        mapView = NavigationMapView(frame: view2.bounds)
//        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        view2.addSubview(mapView)
//        mapView.delegate = self
//        mapView.showsUserLocation = true
//        mapView.setUserTrackingMode(.follow, animated: true)
//        //mapView.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
//        mapView.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        if selectDevice(audioSession: blueoothh) == true {
            print("HandsFree exist: \(peripheralName!)")
            print("Peripheral UID: \(peripheralUID!)")
        }else{
            print("HandsFree doesn't exist")
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addButton()
        
        let r = GraphRequest(graphPath: "/me", parameters: ["fields":"id, email, name"], tokenString: AccessToken.current?.tokenString, version: nil, httpMethod: HTTPMethod(rawValue: "GET"))

        r.start(completionHandler: { (test, result, error) in
            if(error == nil)
            {
                print(result)
            }
        })
        
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

    }
    
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        print(peripheral.name)
//    }
    
    func selectDevice(audioSession: AVAudioSession) -> Bool {

        var bluetoothExist = false
        
       
        for output in audioSession.currentRoute.outputs {
            print(output)

            if output.portType == AVAudioSession.Port.bluetoothA2DP || output.portType == AVAudioSession.Port.bluetoothHFP || output.portType == AVAudioSession.Port.carAudio || output.portType == AVAudioSession.Port.usbAudio{
                    bluetoothExist = true
                peripheralName = output.portName
                peripheralUID = output.uid
            }else{
                    bluetoothExist = false
            }
                
            
        }

        if bluetoothExist == true {
            return true
        }else{
            return false
        }
    }
    
}

