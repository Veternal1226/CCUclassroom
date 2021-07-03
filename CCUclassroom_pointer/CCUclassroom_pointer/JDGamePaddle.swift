//
//  JDGamePaddle.swift
//  JDGamePaddle
//
//  Created by Veternal on 2018/11/22.
//  Copyright © 2018年 Veternal. All rights reserved.
//

import Foundation
import SpriteKit
//import SwiftSocket

class JDGamePaddle
{
    var rootuiview:UIView?
    var rootskview:SKView?
    var size:CGSize?
    var iStream:InputStream?=nil
    var oStream:OutputStream?=nil
    var paddle:JDPaddle!
    var delegate:JDPaddleVectorDelegate?
    {
        didSet{
            paddle.delegate = delegate
        }
    }
    
    init(forUIView view:UIView,size:CGSize,iStream:InputStream,oStream:OutputStream) {
        rootuiview = view
        
        let x:CGFloat = 0
        let y:CGFloat = 0
        let skframe:CGRect = CGRect(x: x, y: y, width: size.width, height: size.height)
        rootskview = SKView(frame: skframe)
        rootskview?.isUserInteractionEnabled = true
        self.iStream=iStream
        self.oStream=oStream
        paddle = JDPaddle(size: size,iStream:iStream,oStream:oStream)
    
        let scene:SKScene = SKScene(size: size)
        scene.backgroundColor = UIColor.lightGray
        scene.isUserInteractionEnabled = true
        scene.addChild(paddle)
        rootskview?.presentScene(scene)
        rootuiview!.addSubview(rootskview!)
        
        
    }
    
}


protocol JDPaddleVectorDelegate {
    func getStartpos(pos:CGPoint)
    func getEndpos(pos:CGPoint)
    func getVector()->CGVector
}

class JDPaddle:SKSpriteNode
{
    let MovingPing:SKShapeNode?
    let PaddleBorder:SKShapeNode?
    let Paddle:SKShapeNode?
    let Laser:SKShapeNode?
    let PADDLERANGE=100
    var touching:Bool =  false
    var delegate:JDPaddleVectorDelegate?
    var PaddleOrigin=CGPoint.zero

    var iStream:InputStream?=nil
    var oStream:OutputStream?=nil
   
    init(size:CGSize,iStream:InputStream,oStream:OutputStream) {
        
        let paddleSize:CGSize = CGSize(width: size.width , height: size.height)
        MovingPing = SKShapeNode(circleOfRadius: 10)
        MovingPing?.fillColor = UIColor.black
        
        PaddleBorder = SKShapeNode(rectOf:paddleSize)
        PaddleBorder?.fillColor = UIColor.clear
        PaddleBorder?.strokeColor = UIColor.black
        
        Paddle = SKShapeNode(rectOf:CGSize(width:PADDLERANGE,height:PADDLERANGE))
        Paddle?.fillColor = UIColor.clear
        Paddle?.strokeColor = UIColor.black
        
        Laser = SKShapeNode(circleOfRadius: 10)
        Laser?.fillColor = UIColor.red
        
        super.init(texture: nil, color: UIColor.clear, size: paddleSize)
        self.zPosition = 1
        self.isUserInteractionEnabled = true
        self.position = CGPoint(x: size.width * 0.5 , y: size.height * 0.5 )
        self.addChild(PaddleBorder!)
        self.iStream=iStream
        self.oStream=oStream
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        touching = true
        let position = touch.location(in: self)
        PaddleOrigin=position
        if((PaddleBorder!.contains(position)))
        {
            MovingPing?.position = touch.location(in: self)
            Paddle?.position = touch.location(in: self)
        }
        self.addChild(Paddle!)
        self.addChild(MovingPing!)
        self.addChild(Laser!)
        if(delegate != nil)
        {
            delegate?.getStartpos(pos:position)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let position = touch.location(in: self)
        
        if((PaddleBorder!.contains(position)))
        {
            MovingPing?.position = position
            let projectPos_x=(position.x-PaddleOrigin.x)/CGFloat(PADDLERANGE)
            let projectPos_y=(position.y-PaddleOrigin.y)/CGFloat(PADDLERANGE)
            Laser?.position=CGPoint(x:(position.x-PaddleOrigin.x)*size.width/CGFloat(PADDLERANGE),y:(position.y-PaddleOrigin.y)*size.height/CGFloat(PADDLERANGE))
            delegate?.getEndpos(pos:position)
            TCPsendMes(mes:"M " + String(Float(projectPos_x)) + " " +  String(Float(projectPos_y)*(-1)) + "X")//y-axis upsidedown
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touching = false
        self.MovingPing?.position = PaddleBorder!.position
        MovingPing!.removeFromParent()
        Paddle!.removeFromParent()
        Laser!.removeFromParent()
        let judge=delegate?.getVector()
        if(judge != nil){
            judger(vec:judge!)
        }
    }
    
    func judger(vec:CGVector){
        if(vec.dx>50){
            print("right")
            TCPsendMes(mes:"DX")
        }
        else if(vec.dx<(-50)){
            print("left")
            TCPsendMes(mes:"UX")
        }
        else{
            if(vec.dy>50){
                print("up")
                TCPsendMes(mes:"PX")
            }
            else if(vec.dy<(-50)){
                print("down")
                TCPsendMes(mes:"LX")
            }
            
        }
    }
    
    func movingpaddleSmoothly(position:CGPoint)
    {
        let centerPoint = Paddle!.position
        let radius = CGFloat(PADDLERANGE)
        var distance:CGFloat = 0
        let diffx:CGFloat = (centerPoint.x - position.x) * (centerPoint.x - position.x)
        let diffy:CGFloat = (centerPoint.y - position.y) * (centerPoint.y - position.y)
        distance = sqrt(diffx + diffy)
        let ratio:CGFloat = radius/distance
        let newPostition:CGPoint = CGPoint(x: position.x * ratio, y: position.y * ratio)
        MovingPing?.position = newPostition
        
    }
    
    func TCPsendMes(mes:String){
        var buf=Array(repeating:UInt8(0),count:32)
        let data=mes.data(using: .utf8)!
        data.copyBytes(to:&buf,count:data.count)
        oStream?.write(buf,maxLength: data.count)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



