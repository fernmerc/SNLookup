//
//  ViewController.swift
//  SN Lookup
//
//  Created by Fernando Mercado on 8/6/23.
//
import MLImage
import MLKit
import UIKit

extension String {
    var isHexNumber: Bool {
        filter(\.isHexDigit).count == count
    }
}

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var sidField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    var imagePicker = UIImagePickerController()
    var barcodeImg: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func defaultButtonPressed(_ sender: Any) {
        // set url to default houstonradar
        urlField.text = "http://olddumbar.houston-radar.com/serialsid-lookup.php"
        resultLabel.text = "Set to default URL."
    }
    
    @IBAction func lookupButtonPressed(_ sender: Any) {
        // check if url and sid valid
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
                // async call to lookup func
                let serialLookup = try await lookupSN(urlField.text!, sidField.text!)
                print("Received ping")
                if serialLookup.Status == "Success" {
                    let result = serialLookup.Lookup[sidField.text!]!
                    if result != "" {
                        // got valid response
                        resultLabel.text = "SN: \(result)"
                    } else {
                        // sid not found
                        resultLabel.text = "Device not found, try another SID"
                    }
                    
                } else {
                    // correct domain, incorrect path
                    resultLabel.text = "Error: \(serialLookup.Status)"
                }
                
            } catch {
                // domain completely wrong
                print("The error is:",error)
                resultLabel.text = "Failed to establish connection to host."
            }
        }
    }
    
    @IBAction func scanButtonPressed(_ sender: Any) {
        // leads to library picker
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                    imagePicker.delegate = self
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.allowsEditing = false

                    present(imagePicker, animated: true, completion: nil)
                }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true, completion: nil)
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                // user chose an image
                barcodeImg = image
                hexFromBarcode(img: image)
                print("success")
            }

        }
    
    func hexFromBarcode(img: UIImage) {
        // set the format for the scanner to focus only on code128
        let format = BarcodeFormat.code128
        let barcodeOptions = BarcodeScannerOptions(formats: format)
        
        // setup the image
        let image = VisionImage(image: barcodeImg)
        image.orientation = barcodeImg.imageOrientation
        
        // create scanner object
        let barcodeScanner = BarcodeScanner.barcodeScanner(options: barcodeOptions)
        
        // image processing
        barcodeScanner.process(image) { features, error in guard error == nil, let features = features, !features.isEmpty else {
            // Error handling
            print("bad image read")
            return
        }
            // Recognized barcodes
            for feature in features {
                self.sidField.text = feature.rawValue
            }
        }
    }

}

