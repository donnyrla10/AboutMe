//
//  ProjectTableViewCell.swift
//  AboutMe
//
//  Created by 김영선 on 2022/07/05.
//

import UIKit

class ProjectTableViewCell: UITableViewCell {

    @IBOutlet weak var projectImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    static let identifier = "ProjectTableViewCell"
    
    override func awakeFromNib() { //초기화
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //projectData를 Outlet 변수에 넣기
    func setData(_ projectData: Project){
        projectImageView.image = UIImage(data: projectData.imageName)
        titleLabel.text = projectData.title
        summaryLabel.text = projectData.summary
    }
}
