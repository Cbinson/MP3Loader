//
//  VideoTableViewCell.swift
//  location
//
//  Created by binsonchang on 2016/11/29.
//  Copyright © 2016年 binsonchang. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak var videoImg: UIImageView!
    
    @IBOutlet weak var videoTitle: UILabel!
    
    @IBOutlet weak var downLoadBtn: UIButton!
    
    @IBOutlet weak var videoTime: UILabel!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var downloadProcessView: UIProgressView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initVideoCell(videoDic dic:Dictionary<String, AnyObject>) {
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
