//
//  Profile.swift
//  AboutMe
//
//  Created by 김영선 on 2022/07/01.
//

import Foundation

struct Profile{
    var name: String
    var email: String
    var country: String
    var link: String
    var twitter: String
    var aboutMeTitle: String
    var aboueMeContent: String
    var imageName: Data

    init(name: String, email: String, country: String, link: String, twitter: String, aboutMeTitle: String, aboutMeContent: String, imageName: Data){
        self.name = name
        self.email = email
        self.country = country
        self.link = link
        self.twitter = twitter
        self.aboutMeTitle = aboutMeTitle
        self.aboueMeContent = aboutMeContent
        self.imageName = imageName
    }
}
