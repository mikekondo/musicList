//
//  CardViewCell.swift
//  musicListApp
//
//  Created by 近藤米功 on 2021/08/01.
//

import UIKit
import VerticalCardSwiper
class CardViewCell: CardCell {
    @IBOutlet weak var artWorkImageView:UIImageView!
    @IBOutlet weak var musicNameLabel:UILabel!
    @IBOutlet weak var artistNameLabel:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    //CardCellが持っているメソッド
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    public func setRandomBackgroundColor() {
        //arc4randomでランダムで数字を生成
        let randomRed: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomGreen: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomBlue: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        self.backgroundColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    //CardCellが持っているメソッド
    override func layoutSubviews() {
        self.layer.cornerRadius = 12
        super.layoutSubviews()
    }
    //
    
}
