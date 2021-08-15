//
//  SaveProfile.swift
//  musicListApp
//
//  Created by 近藤米功 on 2021/07/31.
//

import Foundation
import Firebase
import PKHUD
class SaveProfile{
    var userID:String!=""
    var userName:String!=""
    var ref:DatabaseReference!
    init(userID:String,userName:String){
        self.userID = userID
        self.userName = userName
        //リファレンスの生成
        //ログインの時に拾えるuidを先頭につけて送信する。受信する時もuidから引っ張ってくる
        //下記はデータベースに保存する機能(profileという名前をつけて)
        ref = Database.database().reference().child("profile").childByAutoId()
        
    }
    init(snapShot:DataSnapshot){
        ref = snapShot.ref
        //valueが空じゃなかったら
        if let value = snapShot.value as? [String:Any]{
            userID = value["userID"] as? String
            userName = value["userName"] as? String
        }
    }
    func toContents()->[String:Any]{
        return ["userID":userID!,"userName":userName as Any]
    }
    func saveProfile(){
        //ref(ここだとprofile)の中にuserIDとuserNameを入れる
        ref.setValue(toContents())
        UserDefaults.standard.set(ref.key, forKey: "autoID")
    }
    
    
}
