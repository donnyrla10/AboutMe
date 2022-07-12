//
//  ViewController.swift
//  AboutMe
//
//  Created by 김영선 on 2022/07/01.
//

import UIKit

class ProfileViewController: UIViewController{

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var twitterLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    
    @IBOutlet weak var aboutMeView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    
    private var profile = Profile(name: "", email: "", country: "", link: "", twitter: "", aboutMeTitle: "", aboutMeContent: "", imageName: Data()){
        didSet{
            self.saveUserData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadUserData()
        profileImage.layer.cornerRadius = profileImage.bounds.size.width / 2
        aboutMeView.layer.cornerRadius = 10
        NotificationCenter.default.addObserver( //데이터를 viewcontroller 간에 전달
            self,
            selector: #selector(settingNotification(_:)),
            name: NSNotification.Name("setting"),
            object: nil
        )
    }
    
    @objc func settingNotification(_ notification: Notification){
        guard let data = notification.object as? Profile else {return} //전달받은 수정된 profile 객체 가져오기
        self.profile = data
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingProfileViewController = segue.destination as? SettingProfileViewController {
            settingProfileViewController.delegate = self
            settingProfileViewController.name = self.nameLabel.text
            settingProfileViewController.email = self.emailLabel.text
            settingProfileViewController.country = self.countryLabel.text
            settingProfileViewController.link = self.linkLabel.text
            settingProfileViewController.twitter = self.twitterLabel.text
            settingProfileViewController.aboutMeTitle = self.titleLabel.text
            settingProfileViewController.aboutMeContent = self.contentTextView.text
            settingProfileViewController.imageData = self.profileImage.image?.pngData()
        }
    }
    
    private func saveUserData(){
        let userDefault = UserDefaults.standard
        userDefault.set(self.profile.name, forKey: "userName")
        userDefault.set(self.profile.email, forKey: "userEmail")
        userDefault.set(self.profile.country, forKey: "userCountry")
        userDefault.set(self.profile.link, forKey: "userLink")
        userDefault.set(self.profile.twitter, forKey: "userTwitter")
        userDefault.set(self.profile.aboutMeTitle, forKey: "introTitle")
        userDefault.set(self.profile.aboueMeContent, forKey: "introContent")
        userDefault.set(self.profile.imageName, forKey: "profileImage")
        print("save")
    }
    
    private func loadUserData(){
        print("load1")
        let userDefault = UserDefaults.standard
        guard let name = userDefault.object(forKey: "userName") as? String else {return}
        guard let email = userDefault.object(forKey: "userEmail") as? String else {return}
        guard let country = userDefault.object(forKey: "userCountry") as? String else {return}
        guard let link = userDefault.object(forKey: "userLink") as? String else {return}
        guard let twitter = userDefault.object(forKey: "userTwitter") as? String else {return}
        guard let aboutTitle = userDefault.object(forKey: "introTitle") as? String else {return}
        guard let aboutContent = userDefault.object(forKey: "introContent") as? String else {return}
        guard let imageName = userDefault.object(forKey: "profileImage") as? Data else {return}
        
        self.nameLabel.text = name
        self.emailLabel.text = email
        self.countryLabel.text = country
        self.linkLabel.text = link
        self.twitterLabel.text = twitter
        self.titleLabel.text = aboutTitle
        self.contentTextView.text = aboutContent
        self.profileImage.image = UIImage(data: imageName)
        
        print("load2")
    }
}

extension ProfileViewController: SettingProfileDelegate {
    func changeSettingProfile(name: String?, email: String?, country: String?, link: String?, twitter: String?, aboutMeTitle: String?, aboutMeContent: String?, imageData: Data?) {
        if let name = name { self.nameLabel.text = name }
        if let email = email { self.emailLabel.text = email }
        if let country = country { self.countryLabel.text = country }
        if let link = link { self.linkLabel.text = link }
        if let twitter = twitter { self.twitterLabel.text = twitter }
        if let aboutMeTitle = aboutMeTitle { self.titleLabel.text = aboutMeTitle }
        if let aboutMeContent = aboutMeContent { self.contentTextView.text = aboutMeContent }
        if let imageData = imageData {self.profileImage.image = UIImage(data: imageData)}
    }
}

