//
//  FusionVideoViewController.swift
//  musicListApp
//
//  Created by 近藤米功 on 2021/08/21.
//

import UIKit
import AVKit
import Photos
import PKHUD
class FusionVideoViewController: UIViewController {
    //EditViewControllerから受け取った音源と動画の融合URLが入る
    var FusionURL:URL?
    var player:AVPlayer?
    var playerController:AVPlayerViewController?
    @IBOutlet weak var saveLabel: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        //ナビゲーションバーを消す
        self.navigationController?.isNavigationBarHidden = false
    }
    override func viewDidAppear(_ animated: Bool) {
        //完成された動画URLの再生(passedURL)
        setUPVideoPlayer(url: FusionURL!)
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
    //playerの繰り返し処理
    @objc func playerItemDidReachEnd(_ notification:Notification){
        if self.player != nil{
            //playerの再生時間を始めに戻す
            self.player?.seek(to: CMTime.zero)
            self.player?.volume = 1
            self.player?.play()
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func savePhotoLibrary(_ sender: Any) {
        //動画を保存する
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.FusionURL!)
        } completionHandler: { (result, error) in
            if error != nil{
                print(error.debugDescription)
            }
            if result{
                print("動画を保存しました")
                //self.saveLabel.titleLabel?.text = "complete"
            }
        }
    }
}
