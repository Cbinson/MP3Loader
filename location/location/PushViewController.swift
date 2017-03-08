//
//  PushViewController.swift
//  location
//
//  Created by binsonchang on 2016/11/23.
//  Copyright © 2016年 binsonchang. All rights reserved.
//

import UIKit
import CoreGraphics
import QuartzCore


class PushViewController: UIViewController, CAAnimationDelegate {

    @IBOutlet weak var mainView: UIView!
    
    var mytimer:Timer!
    var timeCnt = 10
    
    var foodData:NSArray = []
    
    var animation:CABasicAnimation!
    var rotate:CGFloat = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.mainView.layer.cornerRadius = mainView.frame.size.width/2
        self.mainView.layer.masksToBounds = true
        
        foodData = ["111","222","333"/*,"444","555","666","777","888","999"*/]
        drawContentView(data: foodData as NSArray)
    }
    
    
    func drawContentView(data food:NSArray) {
        let centerPoint = CGPoint(x:self.mainView.frame.size.width/2, y:self.mainView.frame.size.height/2)
        
        let radius = CGFloat(self.mainView.bounds.size.width/2)
        
        
        var startAngle:CGFloat = 0
        var endAngle:CGFloat = 0
        
        food.enumerateObjects ({ (obj, idx, stop) in
            
            startAngle = endAngle
            endAngle = CGFloat(M_PI*2)/CGFloat(food.count)*CGFloat(idx+2)
            
            print("\n\nidx:\(idx), obj:\(obj), start:\(startAngle), end:\(endAngle)\n\n")
            
            let aPath = UIBezierPath()
            aPath.lineWidth = 5.0
            aPath.lineCapStyle = CGLineCap.round
            aPath.lineJoinStyle = CGLineJoin.round
            
            aPath.move(to: centerPoint)
            aPath.addArc(withCenter: centerPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            aPath.close()
            aPath.stroke()
            
            
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = aPath.cgPath
            shapeLayer.strokeColor = UIColor.red.cgColor
            shapeLayer.lineWidth = 2
            
            let red:CGFloat = CGFloat(arc4random()%255)
            let green:CGFloat = CGFloat(arc4random()%255)
            let blue:CGFloat = CGFloat(arc4random()%255)
            
            shapeLayer.fillColor = UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1).cgColor
            
            
            self.mainView.layer.addSublayer(shapeLayer)
            
            
            let txtrotate:CGFloat = endAngle - (endAngle-startAngle)/2
            let txtLayer = CATextLayer()
            txtLayer.frame = CGRect(x: 0, y: 0, width: self.mainView.bounds.size.width-self.mainView.layer.borderWidth*2-48, height: 25)
            
            //设置锚点，绕中心点旋转
            txtLayer.anchorPoint = CGPoint(x:0.5, y:0.5);
            txtLayer.string = String(format: "\(obj)")
            txtLayer.alignmentMode = "right"
            txtLayer.fontSize = 18
            txtLayer.foregroundColor = UIColor.gray.cgColor
            
            txtLayer.shadowColor = UIColor.yellow.cgColor
            txtLayer.shadowOffset = CGSize(width:5.0, height:2.0);
            txtLayer.shadowRadius = 6;
            txtLayer.shadowOpacity = 0.6;
            
            //layer没有center，用Position
            txtLayer.position = CGPoint(x:self.mainView.bounds.size.width/2, y:self.mainView.bounds.size.width/2)
            //旋转
            txtLayer.transform = CATransform3DMakeRotation(txtrotate,0,0,1);
            
            self.mainView.layer.addSublayer(txtLayer)
        })
        
    }

    
    
    @IBAction func clickStartBtn(_ sender: AnyObject) {
        
//        UIView.beginAnimations(nil, context: nil)
//        UIView.setAnimationDuration(1.0)
//        
//        let rotateTime:CGFloat = CGFloat(arc4random()%360)
//        print("xxxxxxxxx rotateTime:\(rotateTime)")
//        
//        mainView.transform = mainView.transform.rotated(by: CGFloat(rotateTime/*-M_PI/2*/))
//        
//        UIView.commitAnimations()
 
        
        
//        mytimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(PushViewController.viewRotateFunc), userInfo: nil, repeats: true)
        
        
        //test CABasicAnimation
        rotateCirculeView()
    }
    
    func rotateCirculeView() {
        animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.delegate = self
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = 2
        
        rotate = CGFloat(M_PI) * CGFloat(arc4random()%314) / 157
        
        animation.toValue = CGFloat(6 * M_PI) + rotate
        
        self.mainView.layer.add(animation, forKey: "position")
        
    }
    
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print("动画结束")
        
        animation.toValue = CGFloat(6 * M_PI) + rotate
        
    }
    
    
//    func viewRotateFunc() {
//        
//        timeCnt = timeCnt - 1
//        if timeCnt != 0 {
//            //test uiview block
//            UIView.animate(withDuration: 1, animations: {
//                
//                if self.timeCnt == 1 {
//                    self.mainView.transform = self.mainView.transform.rotated(by: CGFloat(arc4random()%360))
//                }else{
//                    self.mainView.transform = self.mainView.transform.rotated(by: CGFloat(M_PI))
//                }
//                
//                
//            }) { (finish) in
//                print("finish");
//                
//            }
//        }else{
//            mytimer.invalidate()
//            timeCnt = 10
//        }
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
