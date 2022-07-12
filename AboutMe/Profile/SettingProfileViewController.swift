//
//  SettingProfileViewController.swift
//  AboutMe
//
//  Created by 김영선 on 2022/07/01.
//

import UIKit
import CoreData

protocol SettingProfileDelegate: AnyObject{
    func changeSettingProfile(name: String?, email: String?, country: String?, link: String?, twitter: String?, aboutMeTitle: String?, aboutMeContent: String?, imageData: Data?) //profileviewcontroller에서 정리
}

class SettingProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileButton: UIButton!
    var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(tapSaveButton(_:)))
        return button
    }()

    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var twitterTextField: UITextField!
    @IBOutlet weak var aboutMeTitleTextField: UITextField!
    @IBOutlet weak var aboutMeTextView: UITextView!
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    
    let photoPicker = UIImagePickerController()
    weak var delegate : SettingProfileDelegate? //private 권한이면 안됨. profileviewcontroller로 넘어가야 되기 때문
    
    var name: String?
    var email: String?
    var country: String?
    var link: String?
    var twitter: String?
    var aboutMeTitle: String?
    var aboutMeContent: String?
    var imageData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.saveButton
        photoPicker.delegate = self
        self.saveButton.isEnabled = false
        profileImage.layer.cornerRadius = profileImage.bounds.size.width / 2 //동그란 프로필 사진 picker
        configureTextField()
        configureViewBoundary()
        configureTextFieldDelegate()
        configureView()
    }
    
    private func configureView(){
        if let name = self.name{ self.nameTextField.text = name }
        if let email = self.email{ self.emailTextField.text = email }
        if let country = self.country{ self.countryTextField.text = country }
        if let link = self.link{ self.linkTextField.text = link }
        if let twitter = self.twitter{ self.twitterTextField.text = twitter }
        if let aboutMeTitle = self.aboutMeTitle{ self.aboutMeTitleTextField.text = aboutMeTitle }
        if let aboutMeContent = self.aboutMeContent { self.aboutMeTextView.text = aboutMeContent }
        if let imageData = self.imageData{ self.profileImage.image = UIImage(data: imageData) }
    }
    
    private func configureViewBoundary(){
        self.firstView.layer.cornerRadius = 10
        self.secondView.layer.cornerRadius = 10
    }
    
    private func configureTextField(){
        self.nameTextField.addTarget(self, action: #selector(nameTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc private func nameTextFieldDidChange(_ textField: UITextField) {
      self.validateInputField()
    }
        
    private func validateInputField() {
      //validateInputField() 메소드: 아래 조건 중 하나라도 false라면 confirmButton is not enabled
      self.saveButton.isEnabled = !(self.nameTextField.text?.isEmpty ?? true)
    }

    private func configureTextFieldDelegate(){
        nameTextField.delegate = self
        emailTextField.delegate = self
        countryTextField.delegate = self
        linkTextField.delegate = self
        twitterTextField.delegate = self
        aboutMeTitleTextField.delegate = self
    }
    
    @objc func tapSaveButton(_ sender: Any){
        guard let name = self.nameTextField.text else {return}
        guard let email = self.emailTextField.text else {return}
        guard let country = self.countryTextField.text else {return}
        guard let link = self.linkTextField.text else {return}
        guard let twitter = self.twitterTextField.text else {return}
        guard let aboutMeTitle = self.aboutMeTitleTextField.text else {return}
        guard let aboutMeContent = self.aboutMeTextView.text else {return}
        guard let imageData = self.profileImage.image?.pngData() else {return}
        
        self.delegate?.changeSettingProfile(name: name, email: email, country: country, link: link, twitter: twitter, aboutMeTitle: aboutMeTitle, aboutMeContent: aboutMeContent, imageData: imageData)
        
        let profile = Profile(name: name, email: email, country: country, link: link, twitter: twitter, aboutMeTitle: aboutMeTitle, aboutMeContent: aboutMeContent, imageName: imageData) //객체 생성
        NotificationCenter.default.post(
            name: NSNotification.Name("setting"),
            object: profile,
            userInfo: nil
        )
        print("프로필 데이터 저장")
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func imageChangeButton(_ sender: UIButton) {
        //image picker 기능
        openPhotoLibrary()
    }
    
    func openPhotoLibrary(){
        photoPicker.sourceType = .photoLibrary
        present(photoPicker, animated: false, completion: nil)
    }
}

extension SettingProfileViewController: UITextFieldDelegate{
    //이메일/비번 입력끝나고 리턴버튼을 눌렀을 때 키보드가 사라져야 한다.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

    //이름이 제대로 입력되었는지 확인해서 다음 버튼을 활성화시킨다.
    func textFieldDidEndEditing(_ textField: UITextField) {
        let isNameEmpty = nameTextField.text == ""
        saveButton.isEnabled = !isNameEmpty
    }
}

extension SettingProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
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
            
            profileImage.image = croppedImage
        }
        dismiss(animated: true, completion: nil)
    }
}
