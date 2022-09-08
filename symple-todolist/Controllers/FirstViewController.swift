//
//  FirstViewController.swift
//  testDelegateApp
//
//  Created by 横山　賢一 on 2022/08/18.
//

import UIKit
import RealmSwift

class FirstViewController: UIViewController {
    
    @IBOutlet weak var listTableView: UITableView!
    
    private var listFooterView = UITableViewHeaderFooterView()
    private var trashBarButtonItem: UIBarButtonItem?
    
    private var editButtonCaseFlg: Bool = false // false: default時　true: テキスト入力時
    private var plusButtonTappedFlg: Bool = false
    private var saveIndexPath: Int = 0
    
    private let realm: Realm = try! Realm()
    
    private var list: List<Item>? // 「Itemクラス」が入った配列を宣言
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "リスト"
        
        listTableView.delegate = self
        listTableView.dataSource = self
        // registerでxibをidentifierとして設定する
        listTableView.register(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: "ListCell")
        
        // DBのファイルの場所
        print("url: \(Realm.Configuration.defaultConfiguration.fileURL!)")
        list = realm.objects(ItemList.self).first!.list
        
        // バーボタンアイテムの初期化
        // editBarButtonItem = UIBarButtonItem(title: "編集", style: .done, target: self, action: #selector(editBarButtonTapped(_:)))
        // バーボタンアイテムの追加
        // self.navigationItem.rightBarButtonItems = [editBarButtonItem]
        
        // 右アイコン
        navigationItem.rightBarButtonItems = [editButtonItem] // デフォルト設定
        
        // 左アイコン
        // 画像を使うケース
        // let searchBarButtonItem = UIBarButtonItem(image: UIImage(named: "ico_search")!, style: .plain, target: self, action: #selector(didTapSearch))
        // 標準アイコンを使うケース
        trashBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashButtonPressed(_:)))
        navigationItem.leftBarButtonItem = trashBarButtonItem
        
        // Footer
        let nib: UINib = UINib(nibName: "FooterView", bundle: nil)
        listTableView.register(nib, forHeaderFooterViewReuseIdentifier: "FooterView")
        
        let judgeFlg = testMethod(hikisuu1: 0, hikisuu2: 0)
        print("judgeFlg: \(judgeFlg)")
        
    }
    
    func testMethod (hikisuu1: Int, hikisuu2: Int) -> Bool {
        if hikisuu1 == hikisuu2 {
            return true
        } else {
            return false
        }
    }
    
    @objc private func trashButtonPressed(_ sender: UIBarButtonItem) {
        // アラート
        let alert = UIAlertController(title: "", message: "全て削除しますか？", preferredStyle: .alert)
        let ok = UIAlertAction(title: "削除", style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
            
            try! self.realm.write {
                let results = self.realm.objects(Item.self)
                self.realm.delete(results) // realm.deleteAllにするとcrash
            }
            self.listTableView.reloadData()
        }
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
        
    }
    
    // 「編集」押下時に呼ばれる
    override func setEditing(_ editing: Bool, animated: Bool) {
        if editButtonCaseFlg == false {
            // print("edit：デフォルトケース")
            super.setEditing(editing, animated: animated)
            listTableView.setEditing(editing, animated: animated)
            listTableView.isEditing = editing
            
        } else {
            // print("edit：テキスト入力時ケース")
            textUpdate()
        }
    }
    
    func textUpdate () {
        let item = Item()
        let rowCount = listTableView.numberOfRows(inSection: 0) // セクションの行数を返す
        var deleteCount = 0 // 削除するセル数をカウント
        
        for i in 0 ..< rowCount {
            let indexpath: IndexPath = IndexPath(row: i, section: 0)
            let cell = listTableView.cellForRow(at: indexpath) as! ListCell
            let listNum = i - deleteCount
            
            try! self.realm.write {
                item.itemStrings = cell.cellTextField.text! // → これをrealm外で書くとエラーになる
                
                if plusButtonTappedFlg {
                    if self.list == nil {
                        // print("\(i + 1)つ目のセルデータは初回です")
                        guard item.itemStrings != "" else {
                            // print("初回：空のため登録しない")
                            return
                        }
                        let itemList = ItemList()
                        itemList.list.append(item)
                        self.realm.add(itemList)
                        self.list = realm.objects(ItemList.self).first?.list
                        
                    } else {
                        if i == rowCount - 1 {
                            // 新規セル　追加
                            // print("\(i + 1)つ目のセルデータを保存する")
                            guard item.itemStrings != "" else {
                                // print("\(i + 1)つ目のセルデータは空のため登録しない")
                                return
                            }
                            self.list!.append(item)
                        }
                    }
                } else {
                    // テキストフィールドをタップして編集時
                    // print("\(i + 1)つ目のセルデータは保存済み")
                    // 更新チェック
                    guard list![listNum].itemStrings != cell.cellTextField.text! else {
                        // print("\(listNum + 1)つ目のセルデータは変更なし")
                        return
                    }
                    if item.itemStrings == "" {
                        // データ削除
                        // print("\(listNum + 1)つ目のセルデータは空に変更されたため削除する")
                        realm.delete(list![listNum])
                        deleteCount += 1
                    } else {
                        // print("\(listNum + 1)つ目のセルデータは変更されたため修正する")
                        list![listNum].itemStrings = cell.cellTextField.text!
                    }
                }
            }
        }
        editButtonItem.title = "編集"
        editButtonCaseFlg = false
        plusButtonTappedFlg = false
        listTableView.reloadData()
        listFooterView.isHidden = false
    }

}

extension FirstViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var cellCount: Int = 0
        if !plusButtonTappedFlg {
            cellCount = realm.objects(Item.self).count
        } else {
            cellCount = realm.objects(Item.self).count + 1
        }
        
        return cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        
        cell.listCellDelegate = self
        
        // これでセルをタップ時、色は変化しなくなる
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let item = realm.objects(Item.self)
        if item.count > indexPath.row {
            cell.cellTextField.text = list![indexPath.row].itemStrings
        } else {
            cell.cellTextField.text = ""
        }
        
        if plusButtonTappedFlg {
            cell.cellTextField.becomeFirstResponder()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    // 並び替え
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        try! realm.write {
            let listItem = list![fromIndexPath.row]
            list!.remove(at: fromIndexPath.row)
            list!.insert(listItem, at: to.row)
        }
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // セル削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! realm.write {
                let item = list![indexPath.row]
                realm.delete(item)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // セクションフッターの高さ
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    // フッターに設定するViewを設定する
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        listFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FooterView")!
        
        if let footerView = listFooterView as? FooterView {
            footerView.footerViewDelegate = self
        }
        return listFooterView
    }
     
}

extension FirstViewController: ListCellDelegate {
    func tappedPleaseTextField() {
        
        editButtonItem.title = "完了"
        editButtonCaseFlg = true
        
    }
}

extension FirstViewController: FooterViewDelegate {
    func plusButtonTapped() {
        //　セルを追加
        plusButtonTappedFlg = true
        
        editButtonItem.title = "完了"
        editButtonCaseFlg = true
        
        listTableView.reloadData()
        
        listFooterView.isHidden = true
    }
}
