//
//  VideoFolderViewController.swift
//  location
//
//  Created by robinson on 2016/12/10.
//  Copyright © 2016年 binsonchang. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class VideoFolderViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var documentsPath :String!
    
    
    
    var mutableMusicArry:NSMutableArray = []
    
    @IBOutlet weak var mainTableView: UITableView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let urlAbsoluteStr:String = NSHomeDirectory() + "/Documents"
        documentsPath = urlAbsoluteStr
        
        self.mainTableView.rowHeight = 80
        
        self.mainTableView.setEditing(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.resortArry()
    }
    
    func resortArry() {
        
        var musicArry:Array<Dictionary<String, AnyObject>> = []
        
        let customAllowedSet =  NSCharacterSet(charactersIn:"`#%^{}\"[]|\\<> ").inverted
        
        /*到document資料夾取檔名*/
        let musicDocumentArry:[String] = try! FileManager.default.contentsOfDirectory(atPath: documentsPath as String)
        for idx in 0..<musicDocumentArry.count {
            
            let musicTitle = musicDocumentArry[idx]
//            print("musicTitle:\(musicTitle)")
            
            var musicUrl:URL!
            var tmpMusicDic:Dictionary<String, AnyObject> = Dictionary()
            
            tmpMusicDic["MUSIC_TITLE"] = musicTitle as AnyObject?
            
             if musicTitle != ".DS_Store" {
                let tmpTitle:String = musicTitle as String
                
                var cFilePath:String = "file://\(documentsPath as String)/\(tmpTitle)"
                cFilePath = cFilePath.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!
                musicUrl = URL(string: cFilePath)! as URL
                
//                let tmpMusicItem:AVPlayerItem = AVPlayerItem(url: musicUrl as URL)
                tmpMusicDic["MUSIC_ITEM"] = musicUrl as AnyObject?//tmpMusicItem
            }
            
            musicArry.append(tmpMusicDic)
        }
        
        self.mutableMusicArry.addObjects(from: musicArry)
        
//        print("musicArry:\(self.mutableMusicArry)")
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return self.mutableMusicArry.count;
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            self.mainTableView.beginUpdates()
            
            let tmpPath:IndexPath = IndexPath(row: indexPath.row, section: 0)
            self.mainTableView.deleteRows(at: [tmpPath], with: UITableViewRowAnimation.automatic)
            
            let deleteItemDic:Dictionary<String, AnyObject> = self.mutableMusicArry[indexPath.row] as! Dictionary
            
            self.mutableMusicArry.removeObject(at: indexPath.row)
            
            //刪除sandbox資料
            let fileManager = FileManager.default
            do{
                let itemPathUrl:URL = deleteItemDic["MUSIC_ITEM"] as! URL
                
                try fileManager.removeItem(at: itemPathUrl)
            }catch{}
            
            self.mainTableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellID = "Cell"
        
        let cell = mainTableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.tag = indexPath.row
        
        let musicDic:Dictionary<String, AnyObject> = self.mutableMusicArry[indexPath.row] as! Dictionary
        
        let musicName:String = musicDic["MUSIC_TITLE"] as! String
        
        cell.textLabel?.font = UIFont(name: "Arial", size: 12.0)
        cell.textLabel?.numberOfLines = 4
        cell.textLabel?.text = "\(musicName)"
        
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "GoPlay" {
            
            let playVC = segue.destination as! VideoPlayViewController
            let tmpCell = sender as! UITableViewCell
            
            //let playMusicDic:Dictionary<String, AnyObject> = self.mutableMusicArry[tmpCell.tag] as! Dictionary<String, AnyObject>
            
            
            //let musicName:String = playMusicDic["MUSIC_TITLE"] as! String
            //playVC.receiveMusicName = musicName
            playVC.parentName = "folder"
            
//            let musicItem:URL = playMusicDic["MUSIC_ITEM"] as! URL
//            playVC.playItem = musicItem
            playVC.playTrackIdx = tmpCell.tag
            
            
            var tmpnTitleArry:[String] = [String]()
            var tmpMusicArry:[URL] = [URL]()
            
            for idx in 0..<self.mutableMusicArry.count {
                let musicDic:Dictionary<String, AnyObject> = self.mutableMusicArry[idx] as! Dictionary<String, AnyObject>
                
                let itemUrl:URL = musicDic["MUSIC_ITEM"] as! URL
                
                //let musicItem:AVPlayerItem = AVPlayerItem(url: itemUrl as URL)
                tmpMusicArry.append(itemUrl)
                
                let itemTitle:String = musicDic["MUSIC_TITLE"] as! String
                tmpnTitleArry.append(itemTitle)
            }
            playVC.musicArry = tmpMusicArry
            playVC.musicTitleArry = tmpnTitleArry
            
        }
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
