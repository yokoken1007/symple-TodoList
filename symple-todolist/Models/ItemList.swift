//
//  ItemList.swift
//  testDelegateApp
//
//  Created by 横山　賢一 on 2022/08/24.
//

import RealmSwift

class Item: Object {
    @objc dynamic var itemStrings: String = ""
}

class ItemList: Object {
    let list = List<Item>()
}
