//
//  WriteViewController.swift
//  AboutMe
//
//  Created by 김영선 on 2022/07/02.
//

import UIKit

enum EditorMode {
    case new
    case edit(IndexPath, Project)
}

protocol WriteProjectViewDelegate: AnyObject{
    func didSelectRegister(project: Project)
}

class WriteProjectViewController: UIViewController {

    @IBOutlet weak var registerButton: UIBarButtonItem!
    @IBOutlet weak var projectImage: UIImageView!
    @IBOutlet weak var summaryTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
        
    weak var delegate : WriteProjectViewDelegate?
    var editorMode : EditorMode = .new
    let photoPicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureProjectData()
        configureEditorMode()
        photoPicker.delegate = self
        titleTextField.delegate = self
        self.registerButton.isEnabled = false
    }
    
    private func configureEditorMode(){
        switch self.editorMode{
            case let .edit(_, project):
            self.titleTextField.text = project.title
            self.summaryTextField.text = project.summary
            self.contentTextView.text = project.contents
            self.projectImage.image = UIImage(data: project.imageName)
            self.registerButton.title = "수정"
            default:
                break
        }
    }
    
    private func configureProjectData(){
        self.contentTextView.delegate = self
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
        self.summaryTextField.addTarget(self, action: #selector(summaryTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc private func titleTextFieldDidChange(_ textField: UITextField) {
      self.validateInputField()
    }
    
    @objc private func summaryTextFieldDidChange(_ textField: UITextField) {
      self.validateInputField()
    }
    
    private func validateInputField() {
      //validateInputField() 메소드: 아래 조건 중 하나라도 false라면 confirmButton is not enabled
      self.registerButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !(self.summaryTextField.text?.isEmpty ?? true) && !(self.contentTextView.text?.isEmpty ?? true)
    }
    
    
    @IBAction func imageChangeButton(_ sender: UIButton) {
        openPhotoLibrary()
    }
    
    private func openPhotoLibrary(){
        photoPicker.sourceType = .photoLibrary
        present(photoPicker, animated: false, completion: nil)
    }
    
    @IBAction func tapRegisterButton(_ sender: UIBarButtonItem) {
        guard let title = self.titleTextField.text else {return}
        guard let summary = self.summaryTextField.text else {return}
        guard let content = self.contentTextView.text else {return}
        guard let imageData = self.projectImage.image?.pngData() else {return}
        
        switch self.editorMode{
        case .new:
            let project = Project(uuidString: UUID().uuidString, title: title, contents: content, summary: summary, imageName: imageData)
            self.delegate?.didSelectRegister(project: project)
        case let .edit(indexPath, project):
            let project = Project(uuidString: project.uuidString, title: title, contents: content, summary: summary, imageName: imageData)
            NotificationCenter.default.post(
                name: NSNotification.Name("editProject"),
                object: project,
                userInfo: nil
            )
        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension WriteProjectViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let isTitleEmpty = titleTextField.text == ""
        let isContentEmpty = contentTextView.text == ""
        let isSummaryEmpty = summaryTextField.text == ""

        registerButton.isEnabled = !isTitleEmpty && !isContentEmpty && !isSummaryEmpty
    }
}

extension WriteProjectViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    self.validateInputField()
  }
}

extension WriteProjectViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            
            let sideLength = min(image.size.width, image.size.height)
            let imageSize = image.size
            let xOffset = (imageSize.width - sideLength) / 2.0
            let yOffset = (imageSize.height - sideLength) / 2.0
            
            let cropRect = CGRect(
                x : xOffset, y : yOffset, width: sideLength, height: sideLength).integral
                
            let CGImage = image.cgImage!
            let croppedCGImage = CGImage.cropping(to: cropRect)!
            let croppedImage = UIImage(
                cgImage: croppedCGImage,
                scale: image.imageRendererFormat.scale,
                orientation: image.imageOrientation)
            
            projectImage.image = croppedImage
        }
        dismiss(animated: true, completion: nil)
    }
}
