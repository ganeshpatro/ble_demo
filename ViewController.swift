//
//  ViewController.swift
//  BleExampleDemo
//
//  Created by KaHa Admin on 18/04/18.
//  Copyright © 2018 KaHa Admin. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    @IBOutlet weak var textFieldDeviceName: UITextField!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelUUID: UILabel!
    @IBOutlet weak var labelConnectionStatus: UILabel!
    @IBOutlet weak var viewDeviceFound: UIView!
    
    @IBOutlet weak var acticityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorConnect: UIActivityIndicatorView!
    
    @IBOutlet weak var btnConnect: UIButton!
    
    let deviceManager = DeviceManager()
    var blueToothEnabled = false
    var cPeripheral: CBPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        deviceManager.delegate = self
        viewDeviceFound.isHidden = true
        
        AppDelegate.sharedApplication().showLocalNotification(withMessage: "Hello Ganesh")
        
        NotificationCenter.default.addObserver(self, selector: #selector(startScan), name: NSNotification.Name(rawValue: "start_scaniing"), object: nil)

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
        
        deviceManager.startScan(nil)
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
            debugPrint("Found: \(peripheralName)")
            let name = textFieldDeviceName.text
            
            if peripheralName.contains(name!) {
                acticityIndicator.isHidden = true
                
                cPeripheral = peripheral
                viewDeviceFound.isHidden = false
                
                labelName.text = peripheralName
                labelUUID.text = peripheral.identifier.uuidString
                labelConnectionStatus.text = "Not Connected"
                //btnConnect.isEnabled = true
            }
    
        }
    
        func connected(_ peripheral: CBPeripheral) {
            activityIndicatorConnect.isHidden = true
            labelConnectionStatus.text = "Connected"
            //btnConnect.titleLabel?.text = "Di"
          //  btnConnect.isEnabled = false
            
            AppDelegate.sharedApplication().showLocalNotification(withMessage: "\(String(describing: peripheral.name)) connected!!!")

        }
        
        func failToConnect(_ peripheral: CBPeripheral,
                           with error: Error?) {
            
        }
        
        func disconnected(_ peripheral: CBPeripheral,
                          with error: Error?) {
            
            AppDelegate.sharedApplication().showLocalNotification(withMessage: "\(String(describing: peripheral.name)) disconnected!!!")
            labelConnectionStatus.text = "Not Connected"
           // btnConnect.isEnabled = true
            
            AppDelegate.sharedApplication().startConnectTimer()
        }
    
    
    
    
    
    
    
    
}


