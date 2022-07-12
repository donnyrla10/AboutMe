//
//  EditProjectViewController.swift
//  AboutMe
//
//  Created by 김영선 on 2022/07/02.
//

import UIKit

//project 보여주는 화면
//tableView

class ProjectViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var projects = [Project](){
        didSet{
            self.saveData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //drag & drop
        self.tableView.dragInteractionEnabled = true
        self.tableView.dragDelegate = self
        self.tableView.dropDelegate = self
    
        //cell 등록
        let nib = UINib(nibName: ProjectTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: ProjectTableViewCell.identifier)
        
        //notificationcenter observer 생성
        NotificationCenter.default.addObserver( //project가 편집된 경우
            self,
            selector: #selector(editProjectNotification(_:)),
            name: NSNotification.Name("editProject"),
            object: nil
        )
        self.loadData()
    }
    
    @objc func editProjectNotification(_ notification: Notification){
        guard let data = notification.object as? Project else {return} //전달받은 객체 가져오기
        guard let index = self.projects.firstIndex(where: {$0.uuidString == data.uuidString}) else {return}
        self.projects[index] = data
        self.projects = self.projects.sorted(by: { //최신순으로 정렬
            $0.uuidString.compare($1.uuidString) == .orderedDescending
        })
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if let writeProjectViewContoller = segue.destination as? WriteProjectViewController {
        writeProjectViewContoller.delegate = self
      }
    }
    
    private func saveData(){
        let data = self.projects.map{
            [
                "id": $0.uuidString,
                "title": $0.title,
                "contents" : $0.contents,
                "summary" : $0.summary,
                "image" : $0.imageName
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "projects")
    }
    
    private func loadData(){
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "projects") as? [[String: Any]] else {return}
        self.projects = data.compactMap{
            guard let id = $0["id"] as? String else {return nil}
            guard let title = $0["title"] as? String else {return nil}
            guard let contents = $0["contents"] as? String else {return nil}
            guard let summary = $0["summary"] as? String else {return nil}
            guard let imageData = $0["image"] as? Data else {return nil}
            return Project(uuidString: id, title: title, contents: contents, summary: summary, imageName: imageData)
        }
        self.projects = self.projects.sorted(by: {
            $0.uuidString.compare($1.uuidString) == .orderedDescending
        })
    }
}

extension ProjectViewController: UITableViewDragDelegate{
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
}

extension ProjectViewController: UITableViewDropDelegate{
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if session.localDragSession != nil{
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {}
}

extension ProjectViewController: UITableViewDataSource{ //필요 정보와 데이터 제공
    
    //table cell 개수 반환
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.projects.count
    }
    
    //어떤 cell을 꺼내서 보여줄지 정하고, 어떻게 데이터를 담을지 정하는 메서드
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProjectTableViewCell.identifier, for: indexPath) as? ProjectTableViewCell else {return UITableViewCell()}
        
        let proj = self.projects[indexPath.row]
        cell.setData(proj)
        return cell
    }
    
    //편집모드에서 삭제 버튼을 눌렀을 때, 어떤 셀인지 알려주는 메서드
    //이 메서드 안에서 삭제 버튼이 눌러진 행이 테이블 뷰에서 삭제되도록 해보자
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.projects.remove(at: indexPath.row)
        //삭제된 셀의 indexPath 정보를 넘겨줘서 tableView에도 할일이 삭제되도록 한다.
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        //이렇게 구현하면, 편집모드에서 삭제 버튼을 눌렀을 때 셀이 tableView에서 삭제되고 편집 모드에 안들어가도 swipe로 삭제할 수 있다.
    }
    
    //row editable true
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //셀 행을 움직일 수 있게 하는 메서드
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //행이 다른 위치로 이동하면 sourceIndexPath 파라미터를 통해 원래 있었던 위치를 알려주고, destinationIndexPath를 통해 어디로 이동했는지 알려준다.
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //테이블뷰 셀이 재정렬된 순서대로 배열도 재정렬
        var projects = self.projects
        let project = projects[sourceIndexPath.row]
        projects.remove(at: sourceIndexPath.row) //원래 위치의 할일을 삭제하고
        projects.insert(project, at: destinationIndexPath.row) //이동 위치에 할일 삽입
        self.projects = projects //재정렬된 배열 넣어줌
    }
}

extension ProjectViewController: UITableViewDelegate{ //화면에 보이는 모습과 행동 담당
    //셀의 고정 높이 지정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    //특정 cell이 선택되었음을 알리는 메소드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailProjectViewController") as? DetailProjectViewController else {return}
        let project = self.projects[indexPath.row]
        detailViewController.proj = project
        detailViewController.indexPath = indexPath
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension ProjectViewController : WriteProjectViewDelegate{
    func didSelectRegister(project: Project) {
        print("register를 누르면")
        self.projects.append(project) //전달받은 project를 배열에 넣기
        self.projects = self.projects.sorted(by: {
            $0.uuidString.compare($1.uuidString) == .orderedDescending
        })
        self.tableView.reloadData()
    }
}
