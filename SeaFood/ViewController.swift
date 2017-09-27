//
//  ViewController.swift
//  SeaFood
//
//  Created by Apple on 27/09/17.
//  Copyright © 2017 Harsh Bhardwaj. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let apiKey = "bb8116c7989294409501191aff44cdc4f831ee5e"
    let version = "2017-09-27"
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    var classificationResults: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.sourceType = .camera
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.setNavigationTitleAsync(title: "Processing...")
        self.cameraButton.isEnabled = false
        SVProgressHUD.show()

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {

            imageView.image = image
            imagePicker.dismiss(animated: true, completion: nil)
            
            let visualRecognitionEngine = VisualRecognition(apiKey: apiKey, version: version)
            let imageData = UIImageJPEGRepresentation(image, 0.01)
            let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileUrl = documentUrl.appendingPathComponent("tempImage.jpg")
            try? imageData?.write(to: fileUrl, options: [])

            visualRecognitionEngine.classify(imageFile: fileUrl, success: { (classifiedImages) in
                let classes = classifiedImages.images.first!.classifiers.first!.classes
                self.classificationResults.removeAll()
                
                for i in 0..<classes.count {
                    self.classificationResults.append(classes[i].classification)
                }
                
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                }
                
                if self.classificationResults.contains("hotdog") {
                    self.setNavigationTitleAsync(title: "Hotdog!")
                } else {
                    self.setNavigationTitleAsync(title: "Not Hotdog!")
                }
            })
        } else {
            print("Unable to load the image.")
        }
    }
    
    func setNavigationTitleAsync(title: String) {
        DispatchQueue.main.async {
            self.navigationItem.title = title
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {

        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
}
