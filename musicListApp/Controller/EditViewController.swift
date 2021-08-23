//
//  EditViewController.swift
//  musicListApp
//
//  Created by 近藤米功 on 2021/08/21.
//

import UIKit
import AVKit
import SDWebImage
import AVFoundation
import SwiftVideoGenerator
import DTGradientButton
import ChameleonFramework
class EditViewController: UIViewController {
    //CameraViewControllerから受け取ったcameraVideoURLが入る
    var editVideoURL:URL?
    //CameraViewControllerから受け取ったcameraMusicURLが入る
    var editMusicURL:URL?
    //合成後のURL
    var videoPath:URL?
    var playerController:AVPlayerViewController?
    var player:AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("videoURL",editVideoURL!)
        print("MusicURL",editMusicURL!)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //ナビゲーションバーを隠さない(バックボタンを表示するため)
        self.navigationController?.isNavigationBarHidden = false
    }
    //viewWillApperの後に呼ばれる
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //viewにビデオを表示する
        setUPVideoPlayer(url: editVideoURL!)
    }
    func setUPVideoPlayer(url:URL){
        //viewControllerを親から取り除く？？
        playerController?.removeFromParent()
        player = nil
        player = AVPlayer(url: url)
        self.player?.volume = 1
        view.backgroundColor = .black
        //AVPlayerViewController()インスタンスの初期化
        playerController=AVPlayerViewController()
        //UIImageの幅決めと一緒
        playerController?.videoGravity = .resizeAspectFill
        //playerControllerの大きさを定義
        playerController?.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height-100)
        playerController?.showsPlaybackControls = false
        playerController?.player = player!
        //playerControllerをViewの上に追加
        self.addChild(playerController!)
        self.view.addSubview((playerController?.view)!)
        //再生が終わる瞬間にselectorが呼ばれる
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        
        //cancelButtonの表示
        let cancelButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0))
        cancelButton.setImage(UIImage(named: "cancel"), for: UIControl.State())
        //cancelButtonをtouchUpInsideしたら#selector(cancel)をして画面を戻る
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        //cancelボタンの表示
        view.addSubview(cancelButton)
        //再生
        player?.play()
    }
    @objc func cancel(){
        //画面を戻る
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //playerの繰り返し処理
    @objc func playerItemDidReachEnd(_ notification:Notification){
        if self.player != nil{
            //playerの再生時間を始めに戻す
            self.player?.seek(to: CMTime.zero)
            self.player?.volume = 1
            self.player?.play()
        }
    }
    
    @IBAction func fusionButton(_ sender: Any) {
        //loadingViewを出す
        LoadingView.lockView()
        //SwiftVideoGeneratorによるライブラリ(VideoGenerator)
        VideoGenerator.fileName = "newAudioMovie"
        VideoGenerator.current.mergeVideoWithAudio(videoUrl: editVideoURL!, audioUrl:editMusicURL!) { (result) in
            //lonadingViewを閉じる
            LoadingView.unlockView()
            switch result{
            case .success(let url):
                //値を渡しながら画面遷移
                let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let FusionVC = storyboard.instantiateViewController(withIdentifier: "FusionVC") as! FusionVideoViewController
                FusionVC.FusionURL = url
                self.navigationController?.pushViewController(FusionVC, animated: true)
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
