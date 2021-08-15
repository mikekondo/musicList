//
//  SelectViewController.swift
//  musicListApp
//
//  Created by 近藤米功 on 2021/07/31.
//

import UIKit
import VerticalCardSwiper
import SDWebImage
import PKHUD
import Firebase
import ChameleonFramework
class SelectViewController: UIViewController,VerticalCardSwiperDelegate,VerticalCardSwiperDatasource {
    //SearchViewControllerからの受け取り用配列
    var artistNameArray = [String]()
    var musicNameArray = [String]()
    var previewURLArray = [String]()
    var imageStringArray = [String]()
    var indexNumber = Int()
    var userID = String()
    var userName = String()
    //右にスワイプした時に好きなものを入れる配列
    var likeArtistNameArray = [String]()
    var likeMusicNameArray = [String]()
    var likePreviewURLArray = [String]()
    var likeImageStringArray = [String]()
    var likeArtistViewUrlArray = [String]()
    @IBOutlet weak var cardSwiper: VerticalCardSwiper!
    override func viewDidLoad() {
        super.viewDidLoad()
        cardSwiper.delegate = self
        cardSwiper.datasource = self
        //CardViewCell.xibを使えるようにする
        cardSwiper.register(nib:UINib(nibName: "CardViewCell", bundle: nil), forCellWithReuseIdentifier: "CardViewCell")
        cardSwiper.reloadData()

    }
    func numberOfCards(verticalCardSwiperView: VerticalCardSwiperView) -> Int {
        //まあどのカウントでもいい
        return artistNameArray.count
    }
    
    func cardForItemAt(verticalCardSwiperView: VerticalCardSwiperView, cardForItemAt index: Int) -> CardCell {
        
        if let cardCell = verticalCardSwiperView.dequeueReusableCell(withReuseIdentifier: "CardViewCell", for: index) as? CardViewCell {
            //カードの背景色もランダムで表示
            verticalCardSwiperView.backgroundColor = UIColor.randomFlat()
            view.backgroundColor = verticalCardSwiperView.backgroundColor
            //セル(カード)に配列を表示させる
            let artistName = artistNameArray[index]
            let musicName =  musicNameArray[index]
            cardCell.setRandomBackgroundColor()
            cardCell.artistNameLabel.text = artistName
            cardCell.artistNameLabel.textColor = UIColor.white
            cardCell.musicNameLabel.text = musicName
            cardCell.musicNameLabel.textColor = UIColor.white
            cardCell.artWorkImageView.sd_setImage(with: URL(string: imageStringArray[index]), completed: nil)
            return cardCell
        }
        return CardCell()
    }
    
    func willSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection) {
            artistNameArray.remove(at: index)
            musicNameArray.remove(at: index)
            previewURLArray.remove(at: index)
            imageStringArray.remove(at: index)
        }
    //右にスワイプした時にした時に好きなものとして、新しい配列に入れてあげる
    //スワイプした時に発動されるデリゲートメソッド
    func didSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection) {
        //indexには何番目のカードかが入っている
        indexNumber = index
        //右にスワイプした時に呼ばれる箇所
        if swipeDirection == .Right{
            //好きなものとして新しい配列に入れる
            likeArtistNameArray.append(artistNameArray[indexNumber])
            likeMusicNameArray.append(musicNameArray[indexNumber])
            likePreviewURLArray.append(previewURLArray[indexNumber])
            likeImageStringArray.append(imageStringArray[indexNumber])
            if (likeArtistNameArray.count != 0 && likeMusicNameArray.count != 0 && likePreviewURLArray.count != 0 && likeImageStringArray.count != 0)
            {
                let musicDataModel = MusicDataModel(artistName:artistNameArray[indexNumber], musicName: musicNameArray[indexNumber], preViewURL: previewURLArray[indexNumber], imageString: imageStringArray[indexNumber], userID: userID, userName: userName,key:"0")
                //firebaseに好きな曲のコンテンツを保存する
                musicDataModel.save()
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
