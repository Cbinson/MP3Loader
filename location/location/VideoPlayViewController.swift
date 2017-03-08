//
//  VideoPlayViewController.swift
//  location
//
//  Created by binsonchang on 2016/12/6.
//  Copyright © 2016年 binsonchang. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation
import CoreMedia
import AudioToolbox



class VideoPlayViewController: UIViewController {
    
    @IBOutlet weak var musicTitle: UILabel!
    @IBOutlet weak var musicImg: UIImageView!
    @IBOutlet weak var musicProcessView: UIProgressView!
    
    @IBOutlet weak var voiceBtn: UIButton!
    
    @IBOutlet weak var voiceSlider: UISlider!
    @IBOutlet weak var musicPlayBtn: UIButton!
    @IBOutlet weak var musicForwardBtn: UIButton!
    @IBOutlet weak var musicRewind: UIButton!
    @IBOutlet weak var musicStopBtn: UIButton!
    
    @IBOutlet weak var musicLoopBtn: UIButton!
    
    var documentsPath :String!
    
    
    var musicTitleArry:[String] = [String]()
    
    var musicArry:[URL] = [URL]()
    
    
    var playerLayer:AVPlayerLayer!
    var queuePlayer:AVQueuePlayer!
    
    var isPlaying:Bool = false  //記錄 是否為播放狀態
    var isVoiceOn:Bool = true   //記錄 聲音是否開啟
    var isLoop:Bool = false     //記錄 是否為循環播放
    
    var volumeNum:Float!
    
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    
    //var receiveMusicName:String!
    
    var parentName:String!
    
    var musicPath:String!
    
    var playItem:URL!
    var player:AVPlayer!
    
    
    var playTrackIdx:Int!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
//        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let urlAbsoluteStr:String = NSHomeDirectory() + "/Documents"//urls[urls.count-1].absoluteString
        
        documentsPath = urlAbsoluteStr //urls[urls.count-1].absoluteString
        
        
        do{
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            
        }catch{
            print("\(error)")
        }
        
        self.systemVolumeListener()
        
        
        
        self.musicStopBtn.isEnabled = false
        
        self.musicProcessView.progress = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.parentName == "folder" {
            
            self.musicLoopBtn.backgroundColor = UIColor.gray
            
            if self.player != nil {
                self.player = nil
                
            }
            
            /*play music*/
            self.playMusic(itemIdx: self.playTrackIdx)
            
            /*set play time*/
            self.initStartTimeAndEndTime()
            
        }else{
            self.initAvPlaer()
            self.musicItemToQueue()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        self.viewDidAppear(true)
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        self.viewDidDisappear(true)
        
//        UIApplication.shared.endReceivingRemoteControlEvents()
        
        if self.parentName == "folder" {
            self.player.pause()
            self.player.seek(to: CMTimeMake(0, 1))
            self.player.rate = 0
            
            self.player = nil
            self.playItem = nil
            
        }else{
            //clear musicArry
            if self.musicArry.count != 0 {
                self.queuePlayer.seek(to: CMTimeMake(0, 1))
                self.queuePlayer.rate = 0
                
                self.musicArry.removeAll()
                self.musicArry = [URL]()
            }
        }
        
    }
    
    
    func initStartTimeAndEndTime() {
        /*set end time*/
        self.endTime.text = self.combatMusicAllTime()
        
        let duration:CMTime = (self.player.currentItem?.asset.duration)!
        let currentseconds:Float = Float(CMTimeGetSeconds(duration))
        
        self.player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: DispatchQueue.main, using: {
            (time : CMTime) in
            
            let timeSec:Float = Float(time.value)/Float(time.timescale)
            let min:Int = Int(timeSec)/60
            let sec:Int = Int(timeSec)%60
            let combatTime:String = String(format: "%02d:%02d",min,sec)
            
            self.startTime.text = combatTime
            
            
            self.musicProcessView.progress = timeSec/currentseconds
            
            if timeSec/currentseconds == 1.0 {
                if self.isLoop {
                    self.clickForwordBtn(self.musicForwardBtn)
                }else{
                    self.clickStopBtn(self.musicStopBtn)
                }
            }
        })
    }
    
    
    func combatMusicAllTime() -> String {
        let duration:CMTime = (self.player.currentItem?.asset.duration)!
        let currentseconds:Float = Float(CMTimeGetSeconds(duration))
        let timeDate:Date = Date(timeIntervalSince1970:TimeInterval(currentseconds))
        let timFormater:DateFormatter = DateFormatter()
        timFormater.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        
        if Int(currentseconds/3600.0) == 0 {
            timFormater.dateFormat = "mm:ss"
        }else{
            timFormater.dateFormat = "HH:mm:ss"
        }
        
        let alltime:String = timFormater.string(from: timeDate)
        
        return alltime
    }
    
    
    func systemVolumeListener(){
        NotificationCenter.default.addObserver(self, selector: #selector(voiceChange(notification:)), name:NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"),
                                               object:nil)
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    
    func voiceChange(notification:NSNotification){
        
        self.volumeNum = notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"]as!Float
        
        if self.parentName == "folder" {
            self.player.volume = self.volumeNum
        }else{
            self.queuePlayer.volume = self.volumeNum
        }
        
        self.voiceSlider.value = self.volumeNum
        
        if self.volumeNum == 0 {
            self.voiceSlider.isEnabled = false
        }
        
    }
    
    
    func initAvPlaer() {
        self.playerLayer = AVPlayerLayer()
        playerLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(playerLayer, above: self.view.layer)
    }
    
    
    
    func musicItemToQueue() {
        
        let customAllowedSet =  NSCharacterSet(charactersIn:"`#%^{}\"[]|\\<> ").inverted

        var mArry:[AVPlayerItem] = [AVPlayerItem]()
        
        /*到document資料夾取檔名*/
        let musicArry:[String] = try! FileManager.default.contentsOfDirectory(atPath: documentsPath as String)
        for idx in 0..<musicArry.count {
            
            var musicUrl:URL!
            let fileName:String = musicArry[idx]
            
            if fileName != ".DS_Store" {
//                print("music_title:\(fileName)")
                var cFilePath:String = "file://\(documentsPath as String)/\(fileName)"
                cFilePath = cFilePath.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!
                musicUrl = URL(string: cFilePath)! as URL
                
                
                let tmpMusicItem:AVPlayerItem = AVPlayerItem(url: musicUrl as URL)
                
                mArry.append(tmpMusicItem)
            }
        }
        
        self.queuePlayer = AVQueuePlayer(items: mArry)
        
        self.playerLayer.player = self.queuePlayer
    }
    
    
    
    
    
    
    @IBAction func clickPlayBtn(_ sender: UIButton) {
        
        
        if !isPlaying {
            /*play state*/
            isPlaying = true
            self.musicPlayBtn.setImage(UIImage(named: "Pause"), for: UIControlState.normal)
            
            self.musicStopBtn.isEnabled = true
            
            if self.parentName == "folder" {
                self.player.play()
            }else{
                self.queuePlayer.play()
            }
            
            
            
        }else{
            /*stop state*/
            isPlaying = false
            self.musicPlayBtn.setImage(UIImage(named: "Play"), for: UIControlState.normal)
            
//            self.musicStopBtn.isEnabled = false
            
            if self.parentName == "folder" {
                self.player.pause()
            }else{
                self.queuePlayer.pause()
            }
            
        }
    }
    
    @IBAction func clickStopBtn(_ sender: UIButton) {
        isPlaying = false
        self.musicPlayBtn.setImage(UIImage(named: "Play"), for: UIControlState.normal)
        
        self.musicStopBtn.isEnabled = false
        
        self.musicProcessView.progress = 0
        
        if self.parentName == "folder" {
            self.player.seek(to: CMTimeMake(0, 1))
            self.player.rate = 0
        }else{
            self.queuePlayer.seek(to: CMTimeMake(0, 1))
            self.queuePlayer.rate = 0
        }
        
    }
    
    @IBAction func clickForwordBtn(_ sender: UIButton) {    //下一首
        
        if (self.playTrackIdx + 1) == self.musicArry.count - 1 {
            self.playTrackIdx = 0
        }else{
            self.playTrackIdx =  self.playTrackIdx + 1
        }
        
        self.clickStopBtn(self.musicStopBtn)
        
        self.playMusic(itemIdx: self.playTrackIdx)
        
        /*set play time*/
        self.initStartTimeAndEndTime()
    }
    
    @IBAction func clickRewindBtn(_ sender: UIButton) {     //上一首
        if (self.playTrackIdx - 1) < 0 {
            self.playTrackIdx = self.musicArry.count - 1
        }else{
            self.playTrackIdx =  self.playTrackIdx - 1
        }
        
        self.clickStopBtn(self.musicStopBtn)
        
        self.playMusic(itemIdx: self.playTrackIdx)
        
        /*set play time*/
        self.initStartTimeAndEndTime()
    }
    
    @IBAction func clickVoiceOnOffBtn(_ sender: UIButton) {
        if isVoiceOn {
            self.isVoiceOn = false
            self.voiceBtn.setImage(UIImage(named: "Sound_off"), for: UIControlState.normal)
            
            self.voiceSlider.value = 0
            self.voiceSlider.isEnabled = false
            
            
            if self.parentName == "folder" {
                self.player.isMuted = true
            }else{
                self.queuePlayer.isMuted = true
            }
            
        }else{
            self.isVoiceOn = true
            self.voiceBtn.setImage(UIImage(named: "Sound_alt"), for: UIControlState.normal)
            
            if self.volumeNum == nil {
                self.volumeNum = AVAudioSession.sharedInstance().outputVolume
            }
            
            self.voiceSlider.value = 1.0
            self.voiceSlider.isEnabled = true
            
            if self.parentName == "folder" {
                self.player.isMuted = false
            }else{
                self.queuePlayer.isMuted = false
            }
            
        }
    }
    
    
    @IBAction func clickVolumeSlider(_ sender: UISlider) {
        print("vol:\(self.voiceSlider.value)")
        
        if self.parentName == "folder" {
            self.player.volume = self.voiceSlider.value
        }else{
            self.queuePlayer.volume = self.voiceSlider.value
        }
        
    }
    
    @IBAction func clickLoopBtn(_ sender: UIButton) {
        if self.isLoop {
            self.isLoop = false
            self.musicLoopBtn.backgroundColor = UIColor.gray
        }else{
            self.isLoop = true
            self.musicLoopBtn.backgroundColor = UIColor.clear
        }
    }
    
    
    
    
    
    
    func playMusic(itemIdx:Int) {
        self.isPlaying = true
        
        self.musicTitle.text = self.musicTitleArry[itemIdx] 
        
        self.player = AVPlayer(url: self.musicArry[itemIdx])//AVPlayer(url: self.playItem)
        self.player.play()
        
        /*set button image*/
        self.musicPlayBtn.setImage(UIImage(named: "Pause"), for: UIControlState.normal)
        self.musicStopBtn.isEnabled = true
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
