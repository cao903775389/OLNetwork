//
//  TestTableViewCell.swift
//  OLNetwork
//
//  Created by 逢阳曹 on 2017/4/13.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

class TestTableViewCell: UITableViewCell {

    @IBOutlet weak var coverImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
