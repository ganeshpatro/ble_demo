//
//  ViewController.swift
//  BleExampleDemo
//
//  Created by KaHa Admin on 18/04/18.
//  Copyright © 2018 KaHa Admin. All rights reserved.
//

import UIKit
import CoreBluetooth
import FirebaseMessaging
import FirebaseInstanceID
import Alamofire

class ViewController: UIViewController {
    @IBOutlet weak var textFieldDeviceName: UITextField!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelUUID: UILabel!
    @IBOutlet weak var labelConnectionStatus: UILabel!
    @IBOutlet weak var viewDeviceFound: UIView!
    
    @IBOutlet weak var acticityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorConnect: UIActivityIndicatorView!
    
    @IBOutlet weak var btnConnect: UIButton!
    
    let deviceManager = DeviceManager.shared
    var blueToothEnabled = false
    var cPeripheral: CBPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

//        Messaging.messaging().subscribe(toTopic: "car_parked")
//        Messaging.messaging().subscribe(toTopic: "car_unparked")
        
        deviceManager.delegate = self
        viewDeviceFound.isHidden = true
        
        AppDelegate.sharedApplication().showLocalNotification(withMessage: "Hello Ganesh")
        
        NotificationCenter.default.addObserver(self, selector: #selector(startScan), name: NSNotification.Name(rawValue: "start_scaniing"), object: nil)
        
        textFieldDeviceName.text = "Clove_1_TWSD01A"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlert(msg: String) {
        
        let alertController = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        let leftButtonAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(leftButtonAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func startScan() {
        
        
        
        if !blueToothEnabled {
            showAlert(msg: "Please Enable Blueetooth!")
            return
        }
        
//        if textFieldDeviceName.text?.count == 0 {
//            return
//        }
        
        //deviceManager.startScan([CBUUID(string: "180A")])
        //deviceManager.startScan([CBUUID(string: "FEE7")])
        deviceManager.startScan([CBUUID(string: "FEF5")])
        
        acticityIndicator.isHidden = false
    }

    @IBAction func scanBtnAction(_ sender: Any) {
    textFieldDeviceName.resignFirstResponder()
       startScan()
    }
    
    @IBAction func onClickOfConnect(_ sender: Any) {
        
        if let central  = cPeripheral {
            activityIndicatorConnect.isHidden = false
            deviceManager.connect(central)
        }
        
    }
    
    
}

extension ViewController: DeviceManagerDelegate {
    
        func centralManagerState(_ state: CBManagerState) {
            
            switch state {
                
            case .poweredOn:
                blueToothEnabled = true
            
            case .poweredOff:
                blueToothEnabled = false
                showAlert(msg: "Please Enable Blueetooth!")
            case .resetting:
                blueToothEnabled = false
                
            case .unauthorized:
                blueToothEnabled = false
                
            case .unknown:
                blueToothEnabled = false
                
            case .unsupported:
                blueToothEnabled = false
            }
        }
        
        func discovered(_ peripheral: CBPeripheral,
                        with advertisement: [String: Any],
                        and rssi: NSNumber) {
            
            guard let peripheralName = peripheral.name else { return }
            debugPrint("Found: \(peripheralName) -- \(advertisement) \n\n ")
            let name = textFieldDeviceName.text
            
            if peripheralName.contains(name!) {
                acticityIndicator.isHidden = true
                
                cPeripheral = peripheral
                viewDeviceFound.isHidden = false
                
                labelName.text = peripheralName
                labelUUID.text = peripheral.identifier.uuidString
                labelConnectionStatus.text = "Not Connected"
                //btnConnect.isEnabled = true
                
                if let alreadyExistingPeripheral = cPeripheral {
                    deviceManager.connect(alreadyExistingPeripheral)
                }
                
            }
    
        }
    
        func connected(_ peripheral: CBPeripheral) {
            activityIndicatorConnect.isHidden = true
            labelConnectionStatus.text = "Connected"
            //btnConnect.titleLabel?.text = "Di"
          //  btnConnect.isEnabled = false
            
         //   AppDelegate.sharedApplication().showLocalNotification(withMessage: "\(String(describing: peripheral.name)) connected!!!")
            sendPushMessage("Your car is Moving-UnParked !!!", "Your BLE device is connected")
            
            AppDelegate.sharedApplication().endBackgroundTask()

        }
        
        func failToConnect(_ peripheral: CBPeripheral,
                           with error: Error?) {
            
        }
        
        func disconnected(_ peripheral: CBPeripheral,
                          with error: Error?) {
            
           // AppDelegate.sharedApplication().showLocalNotification(withMessage: "\(String(describing: peripheral.name)) disconnected!!!")
            print("\(String(describing: peripheral.name)) disconnected!!!")
            
            sendPushMessage("Your car is Parked !!!", "Your BLE device is diconnected")
            
            labelConnectionStatus.text = "Not Connected"
           // btnConnect.isEnabled = true
            
            AppDelegate.sharedApplication().startConnectTimer()
        }
    
    
    func sendPushMessage(_ title: String, _ body: String) {
        // Alamofire 3
        let not_parameters: Parameters = [
            "body":body,
            "title":title
        ]
        let parameters: Parameters = [
            "to": "/topics/car_parked",
            "notification":not_parameters
        ]
        
        let url = "https://fcm.googleapis.com/fcm/send"

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization":"key=AIzaSyANVvCv8oV-Y5AfaYKETOoWBCz4eXDQkNA"
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { (response) in
            print("Response is = \(response.response)")
        }
    }
}


