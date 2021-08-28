//
//  LoginViewController.swift
//  musicListApp
//
//  Created by 近藤米功 on 2021/07/31.
//

import UIKit
import Firebase
import FirebaseAuth
import DTGradientButton
import AVFoundation
class LoginViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    var player = AVPlayer()
    let path = Bundle.main.path(forResource: "Record", ofType: "mp4")
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        //背景を動画にする
        player = AVPlayer(url: URL(fileURLWithPath: path!))
        player.play()
        let playerLayer=AVPlayerLayer(player:player)
        playerLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        playerLayer.videoGravity = .resizeAspectFill
        //背景が一番奥
        playerLayer.zPosition = -1
        view.layer.insertSublayer(playerLayer, at: 0)
        //無限ループ
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { (notification) in
            self.player.seek(to: .zero)
            self.player.play()
        }
    }
    
    //UITextFieldDelegateによるデリゲートメソッド
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //リターン押したときにキーボードが閉じる
        textField.resignFirstResponder()
        return true
    }
    @IBAction func login(_ sender: Any) {
        //もしtextFieldの値が空でない場合
        if (textField.text?.isEmpty != true){
            //textFieldの値をuserNameとして、自分のアプリ内に保存
            UserDefaults.standard.set(textField.text,forKey: "userName")
        }
        else{
            //textFieldの値が空ならば、振動させる(UIKitの中にある)ddd
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        //FirebaseAuthの中にIDと名前(textField.text)を保存する
        //Auth.auth().signInAnonymouslyはユーザID取得(resuld)のために使う
        Auth.auth().signInAnonymously { result, error in
            //errorにnilが入っていたら(resultに値が入っていたら)
            if (error == nil){
                //resultの中のuserIDを取得
                guard let user = result?.user else{ return }
                //データベースの中のuserIDを取得
                let userID = user.uid
                //userIDをアプリ内に保存
                UserDefaults.standard.set(userID,forKey:"userID")
                //userIDとuserNameを使用してSaveProfileクラスのインスタンスを生成
                let saveProfile = SaveProfile(userID: userID, userName: self.textField.text!)
                //userIDとuserNameをfirebaseに保存する
                saveProfile.saveProfile()
                //profileにuserIDとuserNameを保存
                self.dismiss(animated: true, completion: nil)
            }
            else{
                print(error?.localizedDescription as Any)
                //アラート
            }
        }
    }
}



