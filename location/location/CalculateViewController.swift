//
//  CalculateViewController.swift
//  location
//
//  Created by binsonchang on 2016/11/3.
//  Copyright © 2016年 binsonchang. All rights reserved.
//

import UIKit


class CalculateViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var mainTableView: UITableView!
    
    @IBOutlet weak var bgImgHightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgImgWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    var bgImgWidth:CGFloat = 0.0
    var bgImgHight:CGFloat = 0.0
    
    var headerImage:UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = true
        
        initNavView()
        
        initBackgroundImg()
        
        mainTableView.tableHeaderView = headerImageView()
    }
    
    
    func headerImageView() -> UIView {
        
        headerImage = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 414.0, height: 156.0))
        headerImage.backgroundColor = UIColor.clear
        
        let headerImg = UIImageView(frame: CGRect(x: 414/2-35, y: 50.0, width: 70.0, height: 70.0))
        headerImg.center = CGPoint(x: 414/2, y: 70.0)
        headerImg.image = UIImage(named: "header")
        headerImg.layer.masksToBounds = true
        headerImg.layer.cornerRadius = 35;
        headerImg.backgroundColor = UIColor.white
        headerImg.isUserInteractionEnabled = true
        
        headerImage.addSubview(headerImg)
        
        let nameLabel = UILabel(frame: CGRect(x: 147, y: 130.0, width: 105.0, height: 20.0))
        nameLabel.center = CGPoint(x:414.0/2, y:125.0)
        nameLabel.text = "apple"
        nameLabel.isUserInteractionEnabled = true
        nameLabel.textColor = UIColor.white
        nameLabel.textAlignment = NSTextAlignment.center
        
        headerImage.addSubview(nameLabel)
        
     return headerImage
    }
    
    func initNavView() {
        navView.alpha = 0
        
        navView.backgroundColor = UIColor.white
        
        titleLabel.text = "test"
        
        leftBtn.setImage(UIImage(named: "left_"), for: UIControlState.normal)
        rightBtn.setImage(UIImage(named: "Setting"), for: UIControlState.normal)
    }
    
    func showNavView() {
        navView.alpha = 1
        
        leftBtn.setImage(UIImage(named: "left@3x.png"), for: UIControlState.normal)
        rightBtn.setImage(UIImage(named: "Setting_"), for: UIControlState.normal)
    }
   
    func initBackgroundImg() {
        let image = UIImage(named: "back")
        
        backgroundImg.image = image
        backgroundImg.isUserInteractionEnabled = true
        
        bgImgWidth = backgroundImg.frame.size.width
        bgImgHight = backgroundImg.frame.size.height
        
        
    }
    
    @IBAction func clickLeftBtn(_ sender: AnyObject) {
        print("click left btn")
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickRightBtn(_ sender: AnyObject) {
        print("click right btn")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 100;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = "row \(indexPath.row)"
        
        return cell
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let contentOffSetY = scrollView.contentOffset.y
        print("offset_y:\(contentOffSetY)")
        
        if scrollView.contentOffset.y<=170 {
            //往上滾
            navView.alpha = scrollView.contentOffset.y/170
            
            titleLabel.text = "test"
            
            leftBtn.setImage(UIImage(named: "left_"), for: UIControlState.normal)
            rightBtn.setImage(UIImage(named: "Setting"), for: UIControlState.normal)
            
            
        }else{
            //往下滾
            showNavView()
        }
        
        if contentOffSetY<0 {
            var rect:CGRect = headerImage.frame
            rect.size.height = bgImgHight - contentOffSetY
            rect.size.width = bgImgWidth * (bgImgHight - contentOffSetY) / bgImgHight
            bgImgHightConstraint.constant = bgImgWidth * (bgImgHight - contentOffSetY) / bgImgHight
            bgImgWidthConstraint.constant = bgImgWidth * (bgImgHight - contentOffSetY) / bgImgHight
            rect.origin.x = -(rect.size.width-bgImgWidth)/2
            rect.origin.y = 0
            headerImage.frame = rect
        }else{
            var rect:CGRect = headerImage.frame
            rect.size.height = bgImgHight
            bgImgHightConstraint.constant = bgImgHight
            bgImgWidthConstraint.constant = bgImgWidth
            rect.size.width = bgImgWidth
            rect.origin.x = 0
            rect.origin.y = -contentOffSetY
            headerImage.frame = rect
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
