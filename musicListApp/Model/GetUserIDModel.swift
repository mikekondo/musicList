//
//  GetUserIDModel.swift
//  musicListApp
//
//  Created by 近藤米功 on 2021/08/01.
//

import Foundation
import Firebase
import PKHUD
class GetUserIDModel{
    var userID:String! = ""
    var userName:String! = ""
    var ref:DatabaseReference! = Database.database().reference().child("profile")
    init(snapshot:DataSnapshot){
        ref=snapshot.ref
        if let value = snapshot.value as? [String:Any]{
            userID = value["userID"] as? String
            userName = value["userName"] as? String
        }
    }
    
}
