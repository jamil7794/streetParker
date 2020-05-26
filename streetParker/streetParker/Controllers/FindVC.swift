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
    var name: String?
    var email: String?

    
    
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
        
        mapView = NavigationMapView(frame: view2.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view2.addSubview(mapView)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        //mapView.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        mapView.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
//        if selectDevice(audioSession: blueoothh) == true {
//            print("HandsFree exist: \(peripheralName!)")
//            print("Peripheral UID: \(peripheralUID!)")
//        }else{
//            print("HandsFree doesn't exist")
//        }
        
        Dataservice.instance.checkForBluetoothConnection { (device) in
            if device {
                print("Device Found")
            }else{
                print("Device not Found")
            }
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = AccessToken.current,
            !token.isExpired {
            
            var coreDataEmail = ""
            let randString = "FBUser" //.gitignore
            Dataservice.instance.fetchUserInfo { (em) in
                print("Fetched user email from core data: \(em)")
                coreDataEmail = em
            }
            Authservice.instance.loginSocialUser(withEmail: coreDataEmail, andPassword: randString) { (success, error) in
                if success {
                    print("Logged in with core data email")
                    //self.dismiss(animated: true, completion: nil)
                }else{
                    print("Logged in with core data email error: \(error?.localizedDescription)")
                }
            }
        }
        print(Auth.auth().currentUser)
        //addButton()
        
//        let r = GraphRequest(graphPath: "/me", parameters: ["fields":"id, email, name"], tokenString: AccessToken.current?.tokenString, version: nil, httpMethod: HTTPMethod(rawValue: "GET"))
//
//        r.start(completionHandler: { (test, result, error) in
//            if(error == nil)
//            {
//                print(result)
//            }
//        })
        
//        if self.user?.name != nil {
//             print("Name in FindVC: " + )
//        }else{
//        hread 1: EXC_BREAKPOINT (code=1, subcode=0x1041434c8)
//            print("Error: user is nil")
//        }
       
//        self.email = (Auth.auth().currentUser?.email)!
        
//        var coreDataEmail = ""
//        var randString = ""
//        Dataservice.instance.fetchUserInfo { (em) in
//            print("Fetched user email from core data: \(em)")
//            coreDataEmail = em
//        }
//        Authservice.instance.loginSocialUser(withEmail: coreDataEmail, andPassword: randString) { (success, error) in
//            if success {
//                print("Logged in with core data email")
//            }else{
//                print("Logged in with core data email: \(error?.localizedDescription)")
//            }
//        }
        
//        if Auth.auth().currentUser != nil {
//            print("FINDVC Auth.auth().currentUser.emsil: " + (Auth.auth().currentUser?.email)!)
//        }else{
//            print("FINDVC Auth.auth().currentUser.emsil: nil" + (Auth.auth().currentUser?.email)!)
//        }
        //print("Name in FINDVC" + name)
        
        
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
    
    
    // MARK: - SelectDevice
//    func selectDevice(audioSession: AVAudioSession) -> Bool {
//
//        var bluetoothExist = false
//        
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: AVAudioSession.CategoryOptions.allowBluetooth)
//            try AVAudioSession.sharedInstance().setActive(true)
//            
//        } catch {
//            print(error)
//        }
//        
//       
//        for output in audioSession.currentRoute.outputs {
//            print(output)
//
//            
//            
// 
//        
//            if output.portType == AVAudioSession.Port.bluetoothHFP || output.portType == AVAudioSession.Port.carAudio {
//                
//                //|| output.portType == AVAudioSession.Port.usbAudio
//                //<AVAudioSessionPortDescription: 0x282d3bbc0, type = BluetoothHFP; name = HandsFreeLink; UID = 74:D7:CA:EB:C0:A2-tsco; selectedDataSource = (null)>
////                HandsFree exist: HandsFreeLink
////                Peripheral UID: 74:D7:CA:EB:C0:A2-tsco
////                2020-05-23 23:02:46.939377-0400 streetParker[370:21202]
//                bluetoothExist = true
//                peripheralName = output.portName
//                peripheralUID = output.uid
//            }else{
//                bluetoothExist = false
//            }
//            
//        }
//
//        if bluetoothExist == true {
//            return true
//        }else{
//            return false
//        }
//    }

}

