//
//  MusicDataModel.swift
//  musicListApp
//
//  Created by 近藤米功 on 2021/08/01.
//

import Foundation
import Firebase
import PKHUD


class MusicDataModel {
    
    var artistName:String! = ""
    var musicName:String! = ""
    var preViewURL:String! = ""
    var imageString:String! = ""
    var userID:String! = ""
    var userName:String! = ""
    var artistViewUrl:String! = ""
    let ref:DatabaseReference!
    //autoID保存用のkey
    var key:String! = ""
    
    init(artistName:String,musicName:String,preViewURL:String,imageString:String,userID:String,userName:String,key:String){
        self.artistName = artistName
        self.musicName = musicName
        self.preViewURL = preViewURL
        self.imageString = imageString
        self.userID = userID
        self.userName = userName
        self.key = key
        ref = Database.database().reference().child("users").child(userID).childByAutoId()
    }
    
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
        }
    }
    
    
    func toContents()->[String:Any]{
        return ["artistName":artistName!,"musicName":musicName!,"preViewURL":preViewURL!,"imageString":imageString!,"userID":userID!,"userName":userName!]
    }
    func save(){
        ref.setValue(toContents())
    }
    
}

