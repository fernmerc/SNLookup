//
//  ViewController.swift
//  SN Lookup
//
//  Created by Fernando Mercado on 8/6/23.
//

import UIKit

extension String {
    var isHexNumber: Bool {
        filter(\.isHexDigit).count == count
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var sidField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func defaultButtonPressed(_ sender: Any) {
        urlField.text = "http://olddumbar.houston-radar.com/serialsid-lookup.php"
        resultLabel.text = "Set to default URL."
    }
    
    @IBAction func lookupButtonPressed(_ sender: Any) {
        // check if url valid url and sid 12 digit hex code
        guard urlField.text != "" else {
            resultLabel.text = "Please enter valid URL"
            return
        }
        guard sidField.text!.isHexNumber && sidField.text!.count == 12 else {
            resultLabel.text = "Please enter valid 12-digit hex code"
            return
        }
        
        // Has valid URL and SID, attempt lookup
        Task {
            do {
                let serialLookup = try await lookupSN(urlField.text!, sidField.text!)
                print("Received ping")
                if serialLookup.Status == "Success" {
                    let result = serialLookup.Lookup[sidField.text!]!
                    if result != "" {
                        resultLabel.text = "SN: \(result)"
                    } else {
                        resultLabel.text = "Device not found, try another SID"
                    }
                    
                } else {
                    resultLabel.text = "Error: \(serialLookup.Status)"
                }
                
            } catch {
                print("The error is:",error)
                resultLabel.text = "Failed to establish connection to host or bad response."
            }
        }
    }
    
}

