//
//  DetailProjectViewController.swift
//  AboutMe
//
//  Created by 김영선 on 2022/07/02.
//

import UIKit

class DetailProjectViewController: UIViewController {
    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var projectImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    var editButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "수정", style: .plain, target: self, action: #selector(tapEditButton(_:)))
        return button
    }()
    
    var proj: Project?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.navigationItem.rightBarButtonItem = self.editButton
    }
    
    @objc func tapEditButton(_ sender: Any){
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "WriteProjectViewController") as? WriteProjectViewController else {return}
        guard let indexPath = self.indexPath else { return }
        guard let project = self.proj else {return}
        viewController.editorMode = .edit(indexPath, project)
        
        NotificationCenter.default.addObserver( //특정 이름의 notification의 event가 발생했는지 관찰하고 특정 event가 발생하면 특정 action을 실행
          self,
          selector: #selector(editDiaryNotification(_:)),
          name: NSNotification.Name("editProject"),
          object: nil
        )
        self.navigationController?.pushViewController(viewController, animated: true) //WriteDiaryViewController로 이동
    }
    
//    @IBAction func tapEditButton(_ sender: UIButton) {
//        //화면 전환 -> WriteProjectViewController
//        print("수정 버튼 클릭")
//        guard let viewController = self.storyboard?.instantiateViewController(identifier: "WriteProjectViewController") as? WriteProjectViewController else {return}
//        guard let indexPath = self.indexPath else { return }
//        guard let project = self.proj else {return}
//        viewController.editorMode = .edit(indexPath, project)
//
//        NotificationCenter.default.addObserver( //특정 이름의 notification의 event가 발생했는지 관찰하고 특정 event가 발생하면 특정 action을 실행
//          self,
//          selector: #selector(editDiaryNotification(_:)),
//          name: NSNotification.Name("editProject"),
//          object: nil
//        )
//        self.navigationController?.pushViewController(viewController, animated: true) //WriteDiaryViewController로 이동
//    }

    @objc func editDiaryNotification(_ notification: Notification) {  //수정된 diary 객체를 전달받아서 view에 update
        guard let project = notification.object as? Project else { return }
        self.proj = project
        self.configureView()
    }
    
    private func configureView(){
        guard let project = self.proj else {return}
        self.titleLabel.text = project.title
        self.contentTextView.text = project.contents
        self.summaryLabel.text = project.summary
        self.projectImage.image = UIImage(data: project.imageName)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self) //해당 instance에 추가된 observer 모두 제거
    }
}
