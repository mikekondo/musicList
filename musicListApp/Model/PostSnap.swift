//
//  PostSnap.swift
//  musicListApp
//
//  Created by 近藤米功 on 2021/08/07.
//

import Foundation
import Firebase
struct PostSnap{
    var artistName:String! = ""
    var musicName:String! = ""
    var preViewURL:String! = ""
    var imageString:String! = ""
    var userID:String! = ""
    var userName:String! = ""
    var artistViewUrl:String! = ""
    var postKey:String! = ""
    let ref:DatabaseReference!
    init(snapshot:DataSnapshot){
        ref = snapshot.ref
        //valueが空じゃなかったら
        if let value = snapshot.value as? [String:Any]{
            artistName =  value["artistName"] as? String
            musicName =  value["musicName"] as? String
            imageString =  value["imageString"] as? String
            preViewURL =  value["preViewURL"] as? String
            userID =  value["userID"] as? String
            userName =  value["userName"] as? String
            postKey = value["postKey"] as? String
        }
    }
}
