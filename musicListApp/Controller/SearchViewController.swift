//
//  SearchViewController.swift
//  musicListApp
//
//  Created by 近藤米功 on 2021/07/31.
//

import UIKit
import PKHUD
import Alamofire
import SwiftyJSON
import DTGradientButton
import FirebaseAuth
import Firebase
import ChameleonFramework
import AVFoundation
class SearchViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var searchTextField: UITextField!
    //モデルで作れるが一旦ここに作る
    var artistNameArray = [String]()
    var musicNameArray = [String]()
    var previewURLArray = [String]()
    var imageStringArray = [String]()
    var userID = String()
    var userName = String()
    var autoID = String()
    var player = AVPlayer()
    let path = Bundle.main.path(forResource: "autoWave", ofType: "mp4")
    override func viewDidLoad() {
        super.viewDidLoad()
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
        //ユーザ登録済みならautoIDに保存していた値に格納
        if UserDefaults.standard.object(forKey: "autoID") != nil{
            autoID = UserDefaults.standard.object(forKey: "autoID") as! String
            self.title = "SearchMusic"
            print(autoID)
       }//ユーザ登録をしていない場合はLoginViewControllerに画面遷移する
       else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(identifier: "LoginViewController")
            //fullScreenに設定
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
            
        }
        //ユーザ登録をしていて、userIDとuserNameに値が入っていたらuserNameとuserIDに値を格納
        if UserDefaults.standard.object(forKey: "userID") != nil && UserDefaults.standard.object(forKey: "userName") != nil{
            
            userID = UserDefaults.standard.object(forKey: "userID") as! String
            userName = UserDefaults.standard.object(forKey: "userName") as! String
            
        }
        //UITextFieldDelegateの委任
        searchTextField.delegate = self
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        //ナビゲーションバーを隠さない(バックボタンを表示するため)
//        self.navigationController?.isNavigationBarHidden = true
//    }
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        //バーの色(ChameleonFramework)
        self.navigationController?.navigationBar.standardAppearance.backgroundColor = UIColor.flatGray()
        //ナビゲーションバーのBackButtonを消す
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    //returnを押すとキーボードが閉じる処理(UITextFieldDelegateによるデリゲートメソッド)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    //任意の点をタッチするとキーボードが閉じる処理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchTextField.resignFirstResponder()
    }
    
    @IBAction func moveToSelectCardView(_ sender: Any) {
        //パース(JSON解析)を行う
        startParse(keyword:searchTextField.text!)
    }
    func moveToCard(){
        performSegue(withIdentifier: "selectVC", sender: nil)
    }
    //画面遷移しながら値渡し
    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        
        if searchTextField.text != nil && segue.identifier == "selectVC"{
            
            let selectVC = segue.destination as! SelectViewController
            selectVC.artistNameArray = self.artistNameArray
            selectVC.imageStringArray = self.imageStringArray
            selectVC.musicNameArray = self.musicNameArray
            selectVC.previewURLArray = self.previewURLArray
            selectVC.userID = self.userID
            selectVC.userName =  self.userName
        }
    }
    func startParse(keyword:String){
        //インディケーターを回す
        HUD.show(.progress)
        //値の初期化(これをしないと過去に格納されたデータと混同する)
        imageStringArray = [String]()
        previewURLArray = [String]()
        artistNameArray = [String]()
        musicNameArray = [String]()
        
        let urlString = "https://itunes.apple.com/search?term=\(keyword)&country=jp"
        
        let encodeUrlString:String = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        //AF.requestはurlStringをJSON解析したresponse.dataを受け取るために行う
        AF.request(encodeUrlString, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON{
            (response) in
            
            print(response)
            switch response.result{
            case .success:
                //responseデータを読み込む
                let json:JSON = JSON(response.data as Any)
                //検索結果のカウント
                let resultCount:Int = json["resultCount"].int!
                //検索カウントの結果分、配列に格納する
                for i in 0 ..< resultCount{
                    
                    var artWorkUrl = json["results"][i]["artworkUrl60"].string
                    let previewUrl = json["results"][i]["previewUrl"].string
                    let artistName = json["results"][i]["artistName"].string
                    let trackCensoredName = json["results"][i]["trackCensoredName"].string
                    //アーティスト写真を大きくする処理
                    if let range = artWorkUrl!.range(of:"60x60bb"){
                        artWorkUrl?.replaceSubrange(range, with: "320x320bb")
                    }
                    self.imageStringArray.append(artWorkUrl!)
                    self.previewURLArray.append(previewUrl!)
                    self.artistNameArray.append(artistName!)
                    self.musicNameArray.append(trackCensoredName!)
                    //for文がちょうど終わるタイミング
                    if self.musicNameArray.count == resultCount{
                        //カード画面へ遷移
                        self.moveToCard()
                    }
                }
                //インディケーターを閉じる
                HUD.hide()
        
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func moveToFav(_ sender: Any) {
        //画面遷移(StoryBoardIDがfavのVC)
                let favVC = self.storyboard?.instantiateViewController(identifier: "fav") as! FavoriteViewController
                self.navigationController?.pushViewController(favVC, animated: true)
    }
    
    @IBAction func moveToList(_ sender: Any) {
        //画面遷移(StoryBoardIDがlistのVC)
                let listVC = self.storyboard?.instantiateViewController(identifier: "list") as! ListTableViewController
                self.navigationController?.pushViewController(listVC, animated: true)
    }
    
    
}
