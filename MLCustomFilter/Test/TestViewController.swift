//
//  TestViewController.swift
//  MLCustomFilter
//
//  Created by Srikanth SP on 05/09/22.
//

import UIKit

class TestViewController: UIViewController, Storyboarded {
    
    var imagePicker: ImagePicker!
    
    lazy var loader: UIAlertController = {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        return alert
    }()

    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var filteredImageView: UIImageView!
    
    @IBAction func selectImage(_ sender: Any) {
        self.imagePicker.present(from: sender as! UIView)
    }
    
    @IBAction func applyFilter(_ sender: Any) {
        
        guard let filteredImage = filteredImageView.image,
              let selectedImage = selectedImageView.image else {
            return
        }
        showLoader()
        MLFilter.applyFilter(filterImage: filteredImage, selectedImage: selectedImage) { image in
            self.hideLoader()
            guard let image = image else {
                print("Empty Image after apply of filter")
                return
            }
            DispatchQueue.main.async {
                self.selectedImageView.image = image
            }
        }
    }
    
    override func viewDidLoad() {
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
    }
    
}

extension TestViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        self.selectedImageView.image = image
    }
}


extension TestViewController {
    
    func showLoader() {
        present(loader, animated: true, completion: nil)
    }
    
    func hideLoader() {
        DispatchQueue.main.async {
            self.dismiss(animated: false, completion: nil)
        }
    }
}
