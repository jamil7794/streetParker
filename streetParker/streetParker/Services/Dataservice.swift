//
//  Dataservice.swift
//  streetParker
//
//  Created by Jamil Jalal on 11/14/19.
//  Copyright © 2019 Jamil Jalal. All rights reserved.
//

import Foundation
import Firebase
import CoreData
import AVFoundation

let DB_BASE = Database.database().reference()


class Dataservice{
    static let instance = Dataservice()

    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_CHAT = DB_BASE.child("chat")

    var REF_BASE : DatabaseReference {
        return _REF_BASE
    }

    var REF_USERS : DatabaseReference {
        return _REF_USERS
    }

    var REF_CHAT : DatabaseReference {
        return _REF_CHAT
    }

    func createDBUser(uid: String, userData: Dictionary<String,Any>){
        REF_USERS.child(uid).updateChildValues(userData)
    }

    func uploadLocation(){

    }

    func printAllEmails(forEmail emaill: String, handler: @escaping (_ emailArray: [String]) -> ()){

        var emailArray = [String]()
        REF_USERS.observe(.value) { (userSnapShot) in
            // we gonna watch all the user

            guard let userSnapshot = userSnapShot.children.allObjects as? [DataSnapshot] else {return}
            for user in userSnapshot {
                let email = user.childSnapshot(forPath: "email").value as! String
                emailArray.append(email)
            }
            handler(emailArray)
        }
    }

    func getNameForEmail(forEmail em: String, handler: @escaping (_ name: String) -> ()){

        var name = String()
        REF_USERS.observe(.value) { (userSnapShot) in
            // we gonna watch all the user

            guard let userSnapshot = userSnapShot.children.allObjects as? [DataSnapshot] else {return}
            for user in userSnapshot {
                let email = user.childSnapshot(forPath: "email").value as! String
                if em == email {
                    if(user.hasChild("Name")){
                        let FIreName = user.childSnapshot(forPath: "Name").value as! String
                        name = FIreName
                        handler(name)
                    }else{
                        name = "\((Auth.auth().currentUser?.email)!)"
                        handler(name)
                    }


                }
            }

        }
    }

    func uploadCarInfo(forEmail em: String, forName name: String, forLicPlate plNumber: String, forCarColor color: String, handler: @escaping (_ name: String) -> ()){

        REF_USERS.observeSingleEvent(of: .value) { (userSnapShot) in
                  // we gonna watch all the user

                  guard let userSnapshot = userSnapShot.children.allObjects as? [DataSnapshot] else {return}
                  for user in userSnapshot {
                      let email = user.childSnapshot(forPath: "email").value as! String
                      if em == email {
                            let uid = Auth.auth().currentUser?.uid
                            let userData = ["email": em, "provider": Auth.auth().currentUser?.providerID, "Name": name, "License Plate": plNumber, "Car Color": color]
                            self.REF_USERS.child(uid!).updateChildValues(userData)
                            handler("\(em) Updated to Firebase: uploadCarInfo")
                            break
                      }
                    
                    }
                }
        
    }
    
    func checkForBluetoothConnection(completion: (_ finished: Bool) -> ()){
        let audioSession = AVAudioSession()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: AVAudioSession.CategoryOptions.allowBluetooth)
            try AVAudioSession.sharedInstance().setActive(true)
                    
        } catch {
            print(error)
        }
                
               
        for output in audioSession.currentRoute.outputs {
                    print(output)

            if output.portType == AVAudioSession.Port.bluetoothHFP || output.portType == AVAudioSession.Port.carAudio {

                print("Bluetooth HFP Found: \(output.portName)")
                print("Bluetooth HFP Device UUID: \(output.uid)")
                completion(true)
            }else{
                print("Bluetooth HFP not found")
                completion(false)
            }
                    
        }

    }

    func fetchUserInfo(handler: @escaping (_ name: String) -> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAndCar")
        // fetch through this entity
        // Thread 1: Exception: "NSFetchRequest could not locate an NSEntityDescription for entity name 'userEmail'"
        do{
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "userEmail") as! String)
                let email = data.value(forKey: "userEmail") as! String
                handler(email)
            }

        }catch{
            let email = "Coudn't return anything "
            debugPrint("Could not fetch: \(error.localizedDescription)")
            handler(email)
        }

    }

    func deleteAllDataFromCoreData(completion: (_ complete: Bool) ->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAndCar")
        do{
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {

                managedContext.delete(data)
            }
            completion(true)
        }catch{
            debugPrint("Could not fetch: \(error.localizedDescription)")
            completion(false)
        }
    }


    
    func save(forEmail em: String, completion: (_ finished: Bool) -> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        let user = UserAndCar(context: managedContext)
        user.userEmail = em

        
        do{
           try managedContext.save()
            print("User Info successfully saved")
            completion(true)
        } catch {
            print("Could not save data: \(error.localizedDescription)")
            completion(false)
        }
        
    }
}



