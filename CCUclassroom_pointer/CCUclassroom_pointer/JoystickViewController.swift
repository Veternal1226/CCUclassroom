//
//  JoystickViewController.swift
//  CCUclassroom_pointer
//
//  Created by Veternal on 2018/11/22.
//  Copyright © 2018 oslab. All rights reserved.
//

import UIKit

class JoystickViewController: UIViewController,JDPaddleVectorDelegate {
    
    @IBOutlet var IPlabel: UILabel!
    @IBOutlet var controlRegion: UIView!
    
    var IP:String?
    var paddle:JDGamePaddle!
    
    var startposData:CGPoint! = CGPoint.init(x:0,y:0)
    var endposData:CGPoint! = CGPoint.init(x:0,y:0)
    
    var iStream:InputStream?=nil
    var oStream:OutputStream?=nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IPlabel.text=IP
        let _=Stream.getStreamsToHost(withName: IP!, port: 12260, inputStream: &iStream, outputStream: &oStream)
        iStream?.open()
        oStream?.open()
        paddle = JDGamePaddle(forUIView: self.controlRegion, size: controlRegion.frame.size,iStream:iStream!,oStream:oStream!)
        paddle.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func getStartpos(pos:CGPoint) {
        startposData=pos
    }
    func getEndpos(pos:CGPoint){
        endposData=pos
    }
    
    func getVector()->CGVector{
        let vec=CGVector(dx:endposData.x-startposData.x,dy:endposData.y-startposData.y)
        return vec
    }
    
    func TCPsendMes(mes:String){
        var buf=Array(repeating:UInt8(0),count:32)
        let data=mes.data(using: .utf8)!
        data.copyBytes(to:&buf,count:data.count)
        oStream?.write(buf,maxLength: data.count)
    }
}
