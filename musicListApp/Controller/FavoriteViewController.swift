//
//  FavoriteViewController.swift
//  musicListApp
//
//  Created by 近藤米功 on 2021/08/01.
//

import UIKit
import Firebase
import SDWebImage
import AVFoundation
import PKHUD
import SwiftVideoGenerator
class PlayMusicButton:UIButton{
    var params:Dictionary<String,Any>
    override init(frame:CGRect){
        self.params = [:]
        //super.initとは親クラスのinitを使うという意味
        super.init(frame:frame)
    }
    required init?(coder aDecoder:NSCoder) {
        self.params = [:]
        super.init(coder: aDecoder)
    }
}
class FavoriteViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,URLSessionDownloadDelegate {
    
    
    @IBOutlet weak var favTableView: UITableView!
    //お気に入り曲リストの配列
    var musicDataModelArray = [MusicDataModel]()
    //firebase内のデータ
    var postSnapArray = [PostSnap]()
    var artworkUrl = ""
    var previewUrl = ""
    var artistName = ""
    var trackCensoredName = ""
    var imageString = ""
    var userID = ""
    //データベース参照用
    var favRef = Database.database().reference()
    var userName = ""
    var player:AVAudioPlayer?
    override func viewDidLoad() {
        super.viewDidLoad()
        //favTableView.allowsSelection = true
        //保存したuserIDがあれば格納
        if UserDefaults.standard.object(forKey: "userID") != nil{
            userID = UserDefaults.standard.object(forKey: "userID") as! String
        }
        //保存したuserNameがあれば格納
        if UserDefaults.standard.object(forKey: "userName") != nil{
            userName = UserDefaults.standard.object(forKey: "userName") as! String
            //self.titleはnavigationControllerのヘッダ部分
            self.title = "\(userName)'s MusicList"
        }
        //tableViewの委任
        favTableView.delegate = self
        favTableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title  = "\(userName)'s MusicList"
        //ナビゲーションバーの色
        self.navigationController?.navigationBar.tintColor = .blue
        //navigationバーの表示
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //インディケーターを回す
        HUD.show(.progress)
        //値を取得する→usersの自分のID下にあるお気に入りにしたコンテンツすべてをobserve
        favRef.child("users").child(userID).observe(.value){
            (snapshot) in
            //過去のデータを一旦空にする
            self.musicDataModelArray.removeAll()
            //snapshot.childrenはautoIDだと思っていい.autoIDの個数分繰り返される
            for child in snapshot.children{
                let childSnapshot = child as! DataSnapshot
                //musicDataにはデータベースで保存したお気に入りコンテンツが格納される
                let musicData = MusicDataModel(snapshot: childSnapshot)
                //autoIDkeyを保存
                musicData.key = childSnapshot.key
                //新しいものを配列の先頭に入れる
                self.musicDataModelArray.insert(musicData,at:0)
                //print(musicData.key!)
                self.favTableView.reloadData()
            }
            //インディケーターを消す
            HUD.hide()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicDataModelArray.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let musicDataModel = musicDataModelArray[indexPath.row]
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        let label1 = cell.contentView.viewWithTag(2) as! UILabel
        let label2 = cell.contentView.viewWithTag(3) as! UILabel
        //このartistNameはMusicDataModelから来ている
        label1.text = musicDataModel.artistName
        label2.text = musicDataModel.musicName
        imageView.sd_setImage(with: URL(string:musicDataModel.imageString), completed: nil)
        //再生ボタン
        let playButton = PlayMusicButton(frame:CGRect(x: view.frame.size.width-375, y: 40, width: 80, height: 80))
        playButton.setImage(UIImage(named: "play2"), for: .normal)
        playButton.addTarget(self, action: #selector(playButtonTap(_ :)), for: .touchUpInside)
        playButton.params["value"]=indexPath.row
        //cell.accessoryView=playButton
        cell.contentView.addSubview(playButton)
        //カメラボタン
        let cameraButton = UIButton(frame: CGRect(x: view.frame.size.width-85, y: 50, width: 60, height: 60))
        cameraButton.setImage(UIImage(named:"camera_6"), for: .normal)
        //ボタンを押したとき
        cameraButton.addTarget(self, action: #selector(cameraButtonTap(_:)), for:.touchUpInside)
        cameraButton.tag = indexPath.row
        cell.contentView.addSubview(cameraButton)
        return cell
    }
    @objc func playButtonTap(_ sender:PlayMusicButton){
        //音楽を一旦止める
        if player?.isPlaying == true{
            player!.stop()
        }
        let indexNumber:Int = sender.params["value"] as! Int
        let urlString = musicDataModelArray[indexNumber].preViewURL
        let url = URL(string: urlString!)
        print(url!)
        //ダウンロード
        downloadMusicURL(url: url!)
    }
    
    @IBAction func backButton(_ sender: Any) {
        if player?.isPlaying == true{
            player!.stop()
        }
        self.navigationController?.popViewController(animated: true)
    }
    func downloadMusicURL(url:URL){
        var downloadTask:URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler:{(url,response,error) in
            self.play(url: url!)
        })
        downloadTask.resume()
    }
    //再生ボタン
    func play(url:URL){
        do{
            self.player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.volume=1.0
            player?.play()
        }catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    //URLSessionDownloadDelegateによるデリゲートメソッド
    //URLのダウンロードが終わった時に呼び出される
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Done")
    }
    //削除機能
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //indexPathrow番目のpostKeyを取得
        let s=musicDataModelArray[indexPath.row].key!
        //userID下にpostkeyを指定してremoveValueで削除
        musicDataModelArray.remove(at: indexPath.row)
        favRef.child("users").child(userID).child(s).removeValue()
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    
}
