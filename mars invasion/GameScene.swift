//
//  GameScene.swift
//  mars invasion
//
//  Created by graduation on 7/31/18.
//  Copyright © 2018 Tarko Games. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let astronaut = SKSpriteNode()
    let gun = SKSpriteNode()
    let astronautL = SKTexture(imageNamed: "astronautL.png")
    let astronautR = SKTexture(imageNamed: "astronautR.png")
    let gunL = SKTexture(imageNamed: "gunL.png")
    let gunR = SKTexture(imageNamed: "gunR.png")
    
    var actionAR = SKAction()
    var actionAL = SKAction()
    var actionGR = SKAction()
    var actionGL = SKAction()
    var actionS = SKAction()
    
    let bullet = SKSpriteNode()
    let bulletNumber = 0
    
    let alien = SKSpriteNode(imageNamed: "alien.png")
    var alienNumber = 1
    let alienTexture = SKTexture(imageNamed: "alien.png")
    let saucerTexture = SKTexture(imageNamed: "saucer.png")
    
    var direction = "right"
    
    lazy var analogJoystick: AnalogJoystick = {
        let js = AnalogJoystick(diameter: 100, colors: (UIColor(red:0.70, green:0.70, blue:0.70, alpha:0.75), UIColor(red:0.33, green:0.33, blue:0.33, alpha:0.75)))
        js.position = CGPoint(x: self.frame.width/2 - js.radius - 20, y: 0)
        js.zPosition = 3.0
        return js
    }()
    
    let astronautCategory: UInt32 = 0x1 << 0
    let bulletCategory: UInt32 = 0x1 << 1
    let alienCategory: UInt32 = 0x1 << 2
    let wallsCategory: UInt32 = 0x1 << 3

  
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx:0, dy:-6)


        actionAL = SKAction.setTexture(astronautL, resize: true)
        actionAR = SKAction.setTexture(astronautR, resize: true)
        actionGL = SKAction.setTexture(gunL, resize: true)
        actionGR = SKAction.setTexture(gunR, resize: true)
        actionS = SKAction.setTexture(saucerTexture, resize: true)

        astronaut.run(actionAR)
        astronaut.position = CGPoint(x: 0, y: -90)
        astronaut.name = "astronaut"
        astronaut.physicsBody = SKPhysicsBody(texture: astronautR,
                                          size: astronautR.size())
        setAstronautPhysics()
        
        gun.run(actionGR)
        gun.position = CGPoint(x: 0, y: -90)
        gun.anchorPoint = CGPoint(x: 0.25, y: 0.5)

        self.addChild(astronaut)
        self.addChild(gun)
        self.gun.zPosition = 2.0
        self.astronaut.zPosition = 1.0
        
        setupJoystick()
        
        let wait = SKAction.wait(forDuration: 2, withRange: 2)
        let spawn = SKAction.run {
            self.createAlien()
        }
        
        let spawning = SKAction.sequence([wait,spawn])
        self.run(SKAction.repeatForever(spawning))
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 0.2
        border.categoryBitMask = wallsCategory
        border.collisionBitMask = astronautCategory
        self.physicsBody = border
        
        let bottomLeftCorner = CGPoint(x: -self.frame.width/2, y: -140)
        let bottomRightCorner =  CGPoint(x: self.frame.width/2, y: -140)
        let bottomBorder = SKPhysicsBody(edgeFrom: bottomLeftCorner, to: bottomRightCorner)
        let bottomBorderNode = SKNode()
        bottomBorderNode.physicsBody = bottomBorder
        bottomBorderNode.physicsBody?.friction = 1.5
        bottomBorderNode.physicsBody?.restitution = 0
        bottomBorderNode.physicsBody?.categoryBitMask =  5
        bottomBorderNode.physicsBody?.categoryBitMask = wallsCategory
        bottomBorderNode.physicsBody?.collisionBitMask = astronautCategory

       self.addChild(bottomBorderNode)
    }
    
    func setupJoystick(){
        addChild(analogJoystick)
        analogJoystick.trackingHandler = { [unowned self] data in
        self.gun.zRotation = data.angular+1.6
        }
    }
    
    func flipL(){
        astronaut.run(actionAL)
        gun.run(actionGL)
        gun.anchorPoint = CGPoint(x: 0.75, y: 0.5)
        print("L")
        print(gun.zRotation)
        analogJoystick.trackingHandler = { [unowned self] data in
            self.gun.zRotation = data.angular+4.7
        }
        astronaut.physicsBody = SKPhysicsBody(texture: astronautL,
                                              size: CGSize(width: astronaut.size.width,
                                                           height: astronaut.size.height))
        setAstronautPhysics()
    }
    
    func flipR(){
        astronaut.run(actionAR)
        gun.run(actionGR)
        gun.anchorPoint = CGPoint(x: 0.25, y: 0.5)
        print("R")
        print(gun.zRotation)
        analogJoystick.trackingHandler = { [unowned self] data in
            self.gun.zRotation = data.angular+1.6
            
        }
        astronaut.physicsBody = SKPhysicsBody(texture: astronautR,
                                              size: CGSize(width: astronaut.size.width,
                                                           height: astronaut.size.height))
        setAstronautPhysics()
    }
    
    func setAstronautPhysics(){
        astronaut.physicsBody?.isDynamic = true
        astronaut.physicsBody?.allowsRotation = false
        astronaut.physicsBody?.affectedByGravity = true
        astronaut.physicsBody?.linearDamping = 0.1
        astronaut.physicsBody?.categoryBitMask =  astronautCategory
        astronaut.physicsBody?.contactTestBitMask =  alienCategory
        astronaut.physicsBody?.collisionBitMask =  alienCategory | wallsCategory
    }
    
    func createAlien(){
        let alien = SKSpriteNode(imageNamed: "alien.png")

        let number1 = Int(arc4random_uniform(2))
        let number2 = Int(arc4random_uniform(2))
        if number1 == 0{
            alien.run(actionS)
            if number2 == 0{
                alien.position = CGPoint(x: self.frame.width/2 + 126, y: 85)
            }
            else {
                alien.position = CGPoint(x: -self.frame.width/2 - 126, y: 85)
            }
            alien.physicsBody = SKPhysicsBody(texture: saucerTexture,
                                              size: CGSize(width: alien.size.width,
                                                           height: alien.size.height))
            let moveX = SKAction.moveTo(x: astronaut.position.x, duration: 5)
            let moveY = SKAction.moveTo(y: astronaut.position.y, duration: 5)
            alien.run(moveX)
            alien.run(moveY)
        }
        else if number1 == 1{
            if number2 == 0{
                alien.position = CGPoint(x: self.frame.width/2 + 96, y: -85)
            }
            else {
                alien.position = CGPoint(x: -self.frame.width/2 - 96, y: -85)
            }
            alien.physicsBody = SKPhysicsBody(texture: alienTexture,
                                               size: CGSize(width: alien.size.width,
                                                            height: alien.size.height))
            
            let move = SKAction.moveTo(x: astronaut.position.x, duration: 3)
            alien.run(move)
        }
        alien.name = "alien"+String(alienNumber)
        alien.zPosition = 1.0
        alien.physicsBody?.isDynamic = true
        alien.physicsBody?.allowsRotation = false
        alien.physicsBody?.affectedByGravity = false
        alien.physicsBody?.categoryBitMask =  alienCategory
        alien.physicsBody?.contactTestBitMask =  bulletCategory | astronautCategory
        alien.physicsBody?.collisionBitMask =  bulletCategory | astronautCategory
        self.addChild(alien)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let bodyA = contact.bodyA.node!
        let bodyB = contact.bodyB.node!
        if contact.bodyA.categoryBitMask == bulletCategory || contact.bodyB.categoryBitMask == bulletCategory{
            bodyA.removeFromParent()
            bodyB.removeFromParent()
            print("bullet hit")
        }
        if (contact.bodyA.node?.name == "astronaut" || contact.bodyB.node?.name == "astronaut") &&
            (contact.bodyA.categoryBitMask == alienCategory || contact.bodyB.categoryBitMask == alienCategory){
            astronaut.removeFromParent()
            gun.removeFromParent()
            print("astronaut contact")
            
        }
        print("A:")
        print(String(describing: contact.bodyA.node?.name))
        print("B:")
        print(String(describing: contact.bodyB.node?.name))
        

    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let bullet = SKSpriteNode()
        bullet.size = CGSize(width: 15, height: 5)
        bullet.position = CGPoint(x: gun.position.x, y: gun.position.y)
        bullet.color = SKColor.black
        bullet.name = "bullet"+String(bulletNumber)
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.allowsRotation = false
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.angularDamping = 0
        bullet.physicsBody?.linearDamping = 0
        bullet.zPosition = 4.0
        bullet.zRotation = gun.zRotation
        bullet.physicsBody?.categoryBitMask =  bulletCategory
        bullet.physicsBody?.contactTestBitMask =  alienCategory
        bullet.physicsBody?.collisionBitMask =  alienCategory
        self.addChild(bullet)
        if direction == "right"{
        bullet.run(SKAction.moveTo(x: bullet.position.x + cos(bullet.zRotation) * 1000, duration: 2))
        bullet.run(SKAction.moveTo(y:bullet.position.y + sin(bullet.zRotation) * 1000, duration: 2))
            astronaut.physicsBody?.applyForce(CGVector(dx: -cos(gun.zRotation)*1500,
                                                       dy: -sin(gun.zRotation)*1500))
        }
        else{
            bullet.run(SKAction.moveTo(x: bullet.position.x + -cos(bullet.zRotation) * 1000, duration: 2))
            bullet.run(SKAction.moveTo(y:bullet.position.y + -sin(bullet.zRotation) * 1000, duration: 2))
            astronaut.physicsBody?.applyForce(CGVector(dx: cos(gun.zRotation)*1500,
                                                       dy: sin(gun.zRotation)*1500))
        }
       
        print(gun.zRotation)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
   
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if self.gun.zRotation > 1.7 && self.gun.zRotation < 4.7 && direction == "right"{
           flipL()
            direction = "left"
            //gun.zRotation = gun.zRotation+3.1
        }
        else if self.gun.zRotation > 1.5 && self.gun.zRotation < 4.7  && direction == "left" {
            flipR()
            direction = "right"
        }
        gun.position.x = astronaut.position.x
        gun.position.y = astronaut.position.y

    }
}
