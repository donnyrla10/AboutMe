//
//  tagCollectionViewCell.swift
//  AboutMe
//
//  Created by 김영선 on 2022/07/07.
//

import UIKit

class tagCollectionViewCell: UICollectionViewCell {
    
    let tagLabel : UILabel = {
        let tagLabel = UILabel()
        tagLabel.textColor = .gray
        tagLabel.font = .systemFont(ofSize: 14)
        return tagLabel
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        contentView.addSubview(tagLabel)
        contentView.layer.cornerRadius = 4
        
        setConstraint()
    }
    
    private func setConstraint(){
        tagLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        tagLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 10).isActive = true
        tagLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        tagLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 10).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
