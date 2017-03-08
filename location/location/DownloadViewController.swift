//
//  DownloadViewController.swift
//  location
//
//  Created by binsonchang on 2016/11/25.
//  Copyright © 2016年 binsonchang. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreMedia
import AVFoundation

class DownloadViewController: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UITabBarDelegate,UITabBarControllerDelegate, URLSessionDownloadDelegate {

    //https://www.youtube.com/watch?v=7WQFI_wiEIk
    let youTubeInmp3API:String = "http://www.youtubeinmp3.com/fetch/?format=JSON&video="
    let youTubeUrl:String = "https://www.youtube.com/watch?v="//"https://www.youtube.com/watch?v=7WQFI_wiEIk"
    
    let videoAPI:String = "https://www.googleapis.com/youtube/v3/videos"
    let searchAPI:String = "https://www.googleapis.com/youtube/v3/search"
    let key:String = "AIzaSyCoofdN-jFTAKU3ZXkL3JnosRAHB93dDSo"
    let part:String = "snippet"
    let type:String = "video"
    
    
    
    //avplayer
    var player:AVPlayer!
    var playerItem:AVPlayerItem!
    var playerLayer:AVPlayerLayer!
    
    
    var searchListArry:Array<Dictionary<String, AnyObject>> = []
    var searchWord: String!
    
    var videoTimeIdArry:Array<Dictionary<String, String>> = []
    
    
    var nextPageToken: String!
    
    var cpyVideoTitle: String!
    
    var documentsPath :String!
    var touringSiteTargetUrl :String!
    
    
    @IBOutlet weak var searchTxtField: UITextField!
    @IBOutlet weak var mainTableView: UITableView!
    
    
    var cpySelectedCell:VideoTableViewCell!
    
    var downloadTask:URLSessionDownloadTask!
    
    lazy var Session :URLSession = {
        
        let configuration = URLSessionConfiguration.default
        let sessiontem = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        return sessiontem
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        downloadVideo(link: "https://koenig-media.raywenderlich.com/uploads/2015/08/halftunes.png")
        
//        downloadVideo(link: testVideoUrl)
        
        
        /*test avplayer*/
//        self.playMusic()
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        
//        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        documentsPath = urls[urls.count-1].absoluteString
        let urlAbsoluteStr:String = NSHomeDirectory() + "/Documents"
        documentsPath = urlAbsoluteStr
        print("xxxxx documentsPath:\(documentsPath)");
    }
    
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        
//        let  height = scrollView.frame.size.height
//        let contentYoffset = scrollView.contentOffset.y
//        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
//        if distanceFromBottom < height {
//            print(" you reached end of the table")
//            
////            self.loadMore()
//        }
//    }
    
    @IBAction func clickGoDownLoadBtn(_ sender: AnyObject) {
        
        let tmpBtn = sender as! UIButton
        let videoId = self.searchListArry[tmpBtn.tag]["id"] as! Dictionary<String, AnyObject>
        let cpyVideoId = videoId["videoId"] as! String
        
        print("===== [GO] btn_tag:\(tmpBtn.tag), videoId:\(cpyVideoId) =====")
        
        //show activity view
        let indexPath: IndexPath = IndexPath(row: tmpBtn.tag, section: 0)
        self.cpySelectedCell = self.mainTableView.cellForRow(at: indexPath) as! VideoTableViewCell
        
        self.cpySelectedCell.activityView.isHidden = false
        
        self.showActivityView(activityView: self.cpySelectedCell.activityView)
        
        
        let combatUrlStr = String(format: "\(self.youTubeInmp3API)\(self.youTubeUrl)\(cpyVideoId)")
        
        self.getVideoDownloadLink(link: combatUrlStr, cellTag: tmpBtn.tag)
        
    }
    
    
    
    @IBAction func clickSearchBtn(_ sender: UIButton) {
        
        /*收鍵盤*/
        self.searchTxtField.resignFirstResponder()
        
        if self.searchWord == nil{
            self.searchWord = self.searchTxtField.text
        }
        
        
        if self.searchListArry.count != 0 {
            self.searchListArry.removeAll()
        }
//        self.videoGetRequest(keyWord: self.searchWord)
        print("search:\(self.searchWord)")
        self.videoGetRequest(keyWord: self.searchWord, nextPageToken: "")
        
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if self.searchTxtField.text != nil
        {
            self.searchTxtField.text = ""
        }
        
       return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        self.searchWord = textField.text
        
        return true
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let rowCnt = self.searchListArry.count
        
        return rowCnt
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cellID = "Cell"
        
        let cell = mainTableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! VideoTableViewCell
        cell.tag = indexPath.row
        cell.downLoadBtn.tag = indexPath.row
        cell.activityView.isHidden = true
        cell.downloadProcessView.progress = 0
        
        if indexPath.row == self.searchListArry.count-4 {
            /*撈下一頁資料*/
            self.videoGetRequest(keyWord: self.searchWord, nextPageToken: self.nextPageToken)
        }else{
            let videoDic: Dictionary = self.searchListArry[indexPath.row]["snippet"] as! Dictionary<String, AnyObject>
//            print("xxxxxx idx:\(indexPath.row), videoTime:\(self.searchListArry[indexPath.row])");
        
            let viedoTitle = videoDic["title"] as! String
            cell.videoTitle.text = viedoTitle
            
            let videoImg = self.searchListArry[indexPath.row]["reviewImg"] as! UIImage
            cell.videoImg.image = videoImg
            
            
            let idDic:Dictionary = self.searchListArry[indexPath.row]["id"] as! Dictionary<String, String>
            let videoId: String = idDic["videoId"]!
            
            let videoDetailDic: Dictionary = self.videoTimeIdArry[indexPath.row]
            let detailVideoId: String = videoDetailDic["VideoId"]!
            
            if videoId == detailVideoId {
                
                
                cell.videoTime.text = videoDetailDic["VideoTime"]
            }
            
        }
        
        
        
        return cell
        
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
//    {
//        let videoId = self.searchListArry[indexPath.row]["id"] as! Dictionary<String, AnyObject>
//        
//        cpyVideoId = videoId["videoId"] as! String
//        
//        print("xxxxxx videoId:\(cpyVideoId!)")
//    }
    
    
    func showActivityView(activityView: UIActivityIndicatorView) {
        DispatchQueue.main.async {
            activityView.startAnimating()
        }
    }
    
    
    func stopActivityView(activityView: UIActivityIndicatorView) {
        DispatchQueue.main.async {
            activityView.stopAnimating()
        }
    }
    
    
    func videoGetRequest(keyWord str:String, nextPageToken pageToken:String) {
        
        
        var combatStr:String!
        if pageToken == "" {
            combatStr = String(format: "\(searchAPI)?part=\(part)&q=\(str)&maxResults=25&type=\(type)&key=\(key)")
        }else{
            combatStr = String(format: "\(searchAPI)?pageToken=\(pageToken)&part=\(part)&q=\(str)&maxResults=25&type=\(type)&key=\(key)")
        }
        
        combatStr = combatStr.addingPercentEscapes(using: String.Encoding.utf8)!
        let searchUrl:URL = URL(string: combatStr)! as URL
        
        
        self.downloadSearchResult(searchUrl: searchUrl)
        
        
        
    }
    
    
    
    
    func downloadSearchResult(searchUrl urlStr:URL) {
        let sessionConfig = URLSessionConfiguration.default
        var request = URLRequest(url: urlStr)
        request.httpMethod = "Get"
        
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error == nil
            {
                if let responseStateCode = response as? HTTPURLResponse
                {
                    if responseStateCode.statusCode == 200
                    {
//                        print("[xxxxxx] response:\(response)\n===========\n[xxxxxx]data:\(data)")
                        do{
                            
                            let searchResultDic = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, AnyObject>
                            
                            //copy nextPageToken
                            self.nextPageToken = searchResultDic["nextPageToken"] as! String!
                            
                            
                            let items: AnyObject! = searchResultDic["items"] as AnyObject!
                            let itemArry:Array = items as! Array<AnyObject>
                            
                            
                            
                            for dic in itemArry
                            {
                                var videoDic:Dictionary = dic as! Dictionary<String, AnyObject>
                                
                                /*get videoId*/
                                let idDic:Dictionary = videoDic["id"] as! Dictionary<String, AnyObject>
//                                print("===== [videoId:\(idDic["videoId"])] =====")
                                let combatStr:String = String(format: "\(self.videoAPI)?id=\(idDic["videoId"]!)&part=contentDetails&key=\(self.key)")
                                let videoviewUrl:URL = URL(string: combatStr)!
                                self.getVideoDeatilData(videoUrl: videoviewUrl)
                                
                                /*先把預覽圖轉成UIImage,避免畫面滾動lag*/
                                let snippetDic: Dictionary = videoDic["snippet"] as! Dictionary<String, AnyObject>
                                let thumbnailsDic: Dictionary = snippetDic["thumbnails"] as! Dictionary<String, AnyObject>
                                let defaultThumbnailsDic: Dictionary = thumbnailsDic["default"] as! Dictionary<String, AnyObject>
                                let videoUrl:URL = URL(string: defaultThumbnailsDic["url"] as! String)!
                               
                                let videoImgData = try? Data(contentsOf:videoUrl)
                                var viedoImg:UIImage = UIImage(named: "no-image")!
                                if videoImgData != nil {
                                    viedoImg = UIImage(data: videoImgData!)!
                                }
                                videoDic["reviewImg"] = viedoImg
                                
                                
                                
                                self.searchListArry.append(videoDic)
                            }
                            
                            //get video time
//                            let videoStr = String(format: "\(self.videoAPI)?id=\()")
                            
//                            print("[xxx] searchListArry:\(self.searchListArry)]")
                            let searchCnt = self.searchListArry.count
                            if searchCnt != 0 {
                                
                                DispatchQueue.main.async {
                                    self.mainTableView.reloadData()
                                }
                            }
                            
                        }catch{
                            print("JSON parse error")
                        }
                    }
                }
            }
        })
        task.resume()
    }
    
    func getVideoDeatilData(videoUrl urlStr:URL) {
        let sessionConfig = URLSessionConfiguration.default
        var request = URLRequest(url: urlStr)
        request.httpMethod = "Get"
        
        
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error == nil {
                if let responseStateCode = response as? HTTPURLResponse
                {
                    if responseStateCode.statusCode == 200
                    {
                        do{
                            let searchResultDic = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, AnyObject>
                            let idArry:Array = searchResultDic["items"] as! Array<AnyObject>
                            
                            
                            var combatTimeFormat:String!
                            
                            for tmpDic in idArry {
                                var detailDic:Dictionary = tmpDic as! Dictionary<String, AnyObject>
                                let videoId: String = detailDic["id"] as! String
                                
                                
                                var contentDic:Dictionary = detailDic["contentDetails"] as! Dictionary<String, AnyObject>
                                let videoTime: String = contentDic["duration"]! as! String
                                
                                var hStr:String!
                                var mStr:String!
                                var sStr:String!
                                if videoTime.hasPrefix("PT") {
                                    var currentStr: String = videoTime.substring(from: "PT".endIndex)
//                                    print("xxxxx currentStr:\(currentStr)");
                                    
                                    
                                    if currentStr.characters.contains("H") {
                                        hStr = currentStr.substring(to: currentStr.characters.index(of: "H")!) 
                                        
//                                        print("hStr2:\(hStr)"); //10
                                        currentStr = currentStr.substring(from: currentStr.characters.index(of: "H")!) 
                                        currentStr = currentStr.substring(from: "H".endIndex) 
                                        //print("hTest2:\(currentStr)") //36M30S
                                        
                                        if currentStr.characters.contains("M") {
                                            mStr = currentStr.substring(to: currentStr.characters.index(of: "M")!)
                                            
//                                            print("mStr2:\(mStr)"); //36
                                            currentStr = currentStr.substring(from: currentStr.characters.index(of: "M")!)
                                            currentStr = currentStr.substring(from: "M".endIndex)
                                            
                                            //print("mTest2:\(currentStr)") //30S
                                            sStr = currentStr.substring(to: currentStr.characters.index(of: "S")!)
                                            
//                                            print("sStr2:\(sStr)"); //30
                                            
                                            combatTimeFormat = String(format: "\(hStr!):\(mStr!):\(sStr!)")
                                        }else{
                                            sStr = currentStr.substring(to: currentStr.characters.index(of: "S")!)
                                            
//                                            print("sStr2:\(sStr)"); //30
                                            
                                            combatTimeFormat = String(format: "\(hStr!):00:\(sStr!)")
                                        }
                                        
                                    }else{
                                        
                                        if currentStr.characters.contains("M") {
                                            mStr = currentStr.substring(to: currentStr.characters.index(of: "M")!) 
                                            
                                            currentStr = currentStr.substring(from: currentStr.characters.index(of: "M")!)
                                            currentStr = currentStr.substring(from: "M".endIndex)
                                            
                                            if currentStr != "" {
                                                sStr = currentStr.substring(to: currentStr.characters.index(of: "S")!)
                                            }else{
                                                sStr = "00"
                                            }
                                            
                                            
                                            combatTimeFormat = String(format: "\(mStr!):\(sStr!)")
                                        }else{
                                            sStr = currentStr.substring(to: currentStr.characters.index(of: "S")!) 
                                            
                                            combatTimeFormat = String(format: "00:\(sStr!)")
                                        }
                                        
                                    }
                                    
                                }
                                
//                                print("===== [video Time:\(contentDic["duration"])] =====")
                                
//                                print("===== [videoId:\(self.currentVideoId)] =====");
                                var videoDetailsDict = Dictionary<String, String>()
                                videoDetailsDict["VideoId"] = videoId
                                videoDetailsDict["VideoTime"] = combatTimeFormat//videoTime
                                
                                self.videoTimeIdArry.append(videoDetailsDict)
                            }
                            
                        }catch{
                            print("===== parse video detail Error =====")
                        }
                        
                    }
                }
            }
        })
        task.resume()
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendVideoId"
        {
            //get WebViewController controller
            let webVC = segue.destination as! WebViewController

            let tmpCell = sender as! VideoTableViewCell
            let videoId = self.searchListArry[tmpCell.tag]["id"] as! Dictionary<String, AnyObject>
            
            let cpyVideoId = videoId["videoId"] as! String
//            print("[segue] cpyVideoId:\(cpyVideoId!)");
            
            webVC.videoId = cpyVideoId
        }
    }
    

    func getVideoDownloadLink(link url:String, cellTag tag:Int) {
        
        let customAllowedSet =  NSCharacterSet(charactersIn:"`#%^{}\"[]|\\<> ").inverted
        
        let mp3URL: URL = URL(string: url)!
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: mp3URL)
        request.httpMethod = "POST"
        
        
        let task = session.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                
                do{
                    let responseJSON =  try  JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary;
                    
                    let title:String = responseJSON["title"] as! String
                    self.cpyVideoTitle = title as String
                    
                    var link:String = responseJSON["link"] as! String
                    link = link.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!
                    
                    let downLoadUrl:URL = URL(string: link)!
                    
                    self.downLoadVideoMp3(link: downLoadUrl, cellTag: tag)
                    
                }catch {
                    print("Error with Json: \(error)")
                }

            }
            
        }
        task.resume()

    }
    
    
    
    func downLoadVideoMp3(link url:URL, cellTag tag:Int) {
//        let sessionConfig = URLSessionConfiguration.default
//        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let request = URLRequest(url: url)
        //request.httpMethod = "GET"
        
        self.downloadTask = self.Session.downloadTask(with: request)//downloadTaskWithURL(episodeURL)
        self.downloadTask.resume()
        
//        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
//            
//            if error == nil {
//                if let response = response as? HTTPURLResponse {
//                    if response.statusCode == 200
//                    {
//                        if data != nil
//                        {
//                            
//                            let downloadData = try! Data(contentsOf: url)
//                            do{
////                                let fileName:String = String("\(self.cpyVideoTitle!).mp3")
//                                let fileName:String = String("\(self.cpyVideoTitle!)")
//                                var documentUrl:URL = URL(string: self.documentsPath)!
////                                let saveLocalPath:URL = documentUrl.appendingPathComponent(fileName)
//                                documentUrl = documentUrl.appendingPathComponent(fileName)
//                                documentUrl = documentUrl.appendingPathExtension("mp3")
//                                let saveLocalPath:URL = documentUrl
//                                
//                                try downloadData.write(to: saveLocalPath)
//                                
//                                print("xxxxxxxx saveLocalPath:\(saveLocalPath)");
//                                
//                                let indexPath: IndexPath = IndexPath(row: tag, section: 0)
//                                let cell:VideoTableViewCell = self.mainTableView.cellForRow(at: indexPath) as! VideoTableViewCell
//                                cell.activityView.isHidden = true
//                                
//                                self.stopActivityView(activityView: cell.activityView)
//                                
//                            }catch {
//                                print("save error");
//                                let indexPath: IndexPath = IndexPath(row: tag, section: 0)
//                                let cell:VideoTableViewCell = self.mainTableView.cellForRow(at: indexPath) as! VideoTableViewCell
//                                cell.activityView.isHidden = true
//                                
//                                self.stopActivityView(activityView: cell.activityView)
//                            }
//                            
//                        }
//                    }
//                }
//            }else{
//                print("[task] error:\(error?.localizedDescription)")
//            }
//        })
//        task.resume()
        
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    {
        print("xxxxx 下載完成 xxxxx")
//        print(location.path)
        
        self.stopActivityView(activityView: self.cpySelectedCell.activityView)
        self.cpySelectedCell.activityView.isHidden = false
        
        var  filePath:NSString = self.documentsPath as NSString//NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! as NSString
        filePath = filePath.appendingPathComponent("\(self.cpyVideoTitle as String).mp3") as NSString
        
//        print("self_docPath:\(self.documentsPath)")
//        print("filePath:\(filePath)")
        
        let fileMan = FileManager.default
        do{
            try fileMan.copyItem(atPath: location.path, toPath: filePath as String)
        }catch{}
        
//        self.Session.finishTasksAndInvalidate()
//        self.Session.invalidateAndCancel()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64)
    {
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        //get download process velue
        let processValue:Float = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        
        if processValue < 0 {
            self.stopActivityView(activityView: self.cpySelectedCell.activityView)
        }else{
            DispatchQueue.main.async {
                self.cpySelectedCell.downloadProcessView.progress = processValue
            }
        }
        
        print("下载进度：\(processValue)")
    }
    
    
//    func downloadSync(link url:String) {
//        let downloadUrl:URL = URL(string: url)!
//        
//        let sessionConfig = URLSessionConfiguration.default
//        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
//        var request = URLRequest(url: downloadUrl)
//        request.httpMethod = "GET"
//        
//        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
//            if error == nil {
//                if let response = response as? HTTPURLResponse {
//                    if response.statusCode == 200
//                    {
//                        do{
//                            let responseJSON =  try  JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary;
//                            
////                            let urlString:String = responseJSON["link"] as! String
//                            
//                            
//                        }
//                            
//                        catch let JSONError as NSError {
//                            print("json Error:\(JSONError)")
//                        }
//                    }
//                }
//            }
//        })
//        task.resume()
//    }
    
    
//    func playMusic() {
//        let filePath = Bundle.main.path(forResource: "Happy Forever Alone Day (Forever Alone Song)", ofType: "mp3")
//        
//        print("xxxxxxxxx filePath:\(filePath!)")
//        //        let tmpStr = filePath!
//        
//        let fileURL:URL = URL(fileURLWithPath: filePath!)
//        
//        //        let movieAsset:AVAsset = AVURLAsset(url: fileURL, options: nil)
//        
//        self.playerItem = AVPlayerItem(url:fileURL)//AVPlayerItem(asset: movieAsset)
//        self.player = AVPlayer(playerItem: self.playerItem)
//        self.playerLayer = AVPlayerLayer(player:self.player)
//        self.playerLayer.frame = self.view.bounds
//        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
//        self.view.layer.addSublayer(self.playerLayer)
//        
//        self.player.play()
//    }
    
    
    
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
