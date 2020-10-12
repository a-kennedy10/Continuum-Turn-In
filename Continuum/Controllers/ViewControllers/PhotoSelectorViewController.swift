//
//  PhotoSelectorViewController.swift
//  Continuum
//
//  Created by Alex Kennedy on 10/7/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit

protocol PhotoSelectorViewControllerDelegate: AnyObject {
    func photoSelectorViewControllerSelected(image: UIImage)
}

class PhotoSelectorViewController: UIViewController {

    // MARK: - outlets
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var selectPhotoButton: UIButton!
    
    
    // MARK: - properties
    weak var delegate: PhotoSelectorViewControllerDelegate?
    
    
    // MARK: - lifecycle
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        photoImageView.image = nil
        selectPhotoButton.setTitle("Select Photo", for: .normal)
    }
    
    
    // MARK: - actions
    @IBAction func selectPhotoButtonTapped(_ sender: Any) {
        presentImagePickerActionSheet()
    }

}
// MARK: - extensions

extension PhotoSelectorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectPhotoButton.setTitle("", for: .normal)
            photoImageView.image = photo
            delegate?.photoSelectorViewControllerSelected(image: photo)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func presentImagePickerActionSheet() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let actionSheet = UIAlertController(title: "Pick a photo", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            actionSheet.addAction(UIAlertAction(title: "Photos", style: .default, handler: { (_) in
                imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
                self.present(imagePickerController, animated: true)
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
                imagePickerController.sourceType = UIImagePickerController.SourceType.camera
                self.present(imagePickerController, animated: true)
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
    }
}
