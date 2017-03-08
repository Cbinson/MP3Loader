//
//  WebViewController.swift
//  location
//
//  Created by binsonchang on 2016/11/30.
//  Copyright © 2016年 binsonchang. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class WebViewController: UIViewController {
    
    
    var videoId: String!
    

//    @IBOutlet weak var mainWebView: UIWebView!
    @IBOutlet weak var mainVideoView: YTPlayerView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print("[webVC] videoId:\(videoId)")
        
//        let videoUrl = URL(string: "https://www.youtube.com/watch?v=\(videoId!)")
//        
//        let request = URLRequest(url: videoUrl!)
//        
//        self.mainWebView.loadRequest(request)
        
        
        self.mainVideoView.load(withVideoId: videoId!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
