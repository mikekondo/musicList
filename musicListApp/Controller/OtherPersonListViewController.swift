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
class OtherPersonListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,URLSessionDownloadDelegate {
    @IBOutlet weak var favTableView: UITableView!
    //CameraViewControllerに渡す音源URL
    var musicURL:URL?
    var musicDataModelArray = [MusicDataModel]()
    var artworkUrl = ""
    var previewUrl = ""
    var artistName = ""
    var trackCensoredName = ""
    var imageString = ""
    var userID = ""
    var favRef = Database.database().reference()
    var userName = ""
    var player:AVAudioPlayer?
    override func viewDidLoad() {
        super.viewDidLoad()
        favTableView.allowsSelection = true
        favTableView.delegate = self
        favTableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "\(userName)'s MusicList"
        self.navigationController?.navigationBar.tintColor = .white
        //navigationバーの表示
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //インディケーターを回す
        HUD.show(.progress)
        //値を取得する→usersの自分のIDの下にあるお気に入りにしたコンテンツすべて
        favRef.child("users").child(userID).observe(.value){
            (snapshot) in
            self.musicDataModelArray.removeAll()
            for child in snapshot.children{
                let childSnapshot = child as! DataSnapshot
                let musicData = MusicDataModel(snapshot: childSnapshot)
                self.musicDataModelArray.insert(musicData,at:0)
                self.favTableView.reloadData()
            }
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
        cell.isHighlighted=false
        let musicDataModel = musicDataModelArray[indexPath.row]
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        let label1 = cell.contentView.viewWithTag(2) as! UILabel
        let label2 = cell.contentView.viewWithTag(3) as! UILabel
        //このartistNameはMusicDataModelから来ている
        label1.text = musicDataModel.artistName
        label2.text = musicDataModel.musicName
        imageView.sd_setImage(with: URL(string:musicDataModel.imageString), completed: nil)
//        //再生ボタン
//        let playButton = PlayMusicButton(frame:CGRect(x: view.frame.size.width-335, y: 40, width: 80, height: 80))
//        playButton.setImage(UIImage(named: "play2"), for: .normal)
//        playButton.addTarget(self, action: #selector(playButtonTap(_ :)), for: .touchUpInside)
//        playButton.params["value"]=indexPath.row
//        //cell.accessoryView=playButton
//        cell.contentView.addSubview(playButton)
        //カメラボタン
        let cameraButton = UIButton(frame: CGRect(x: view.frame.size.width-75, y: 50, width: 60, height: 60))
        cameraButton.setImage(UIImage(named:"camera"), for: .normal)
        //ボタンを押したとき
        cameraButton.addTarget(self, action: #selector(cameraButtonTap(_:)), for:.touchUpInside)
        cameraButton.tag = indexPath.row
        cell.contentView.addSubview(cameraButton)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let urlString = musicDataModelArray[indexPath.row].preViewURL
        let url = URL(string: urlString!)
        downloadMusicURL(url: url!)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    @objc func cameraButtonTap(_ sender:UIButton){
        //音声が流れている時止める
        if player?.isPlaying == true{
            player?.stop()
        }
        //値を渡しながら画面遷移
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let CameraVC = storyboard.instantiateViewController(withIdentifier: "CameraVC") as! CameraViewController
        //sender.tagを用いて、musicURLを取得
        musicURL = URL(string: self.musicDataModelArray[sender.tag].preViewURL)!
        //CameraViewControllerにmusicURLを渡す
        CameraVC.cameraMusicURL = musicURL
        //CameraViewControllerに画面遷移
        self.navigationController?.pushViewController(CameraVC, animated: true)
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
    

}

