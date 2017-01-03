//
//  GameScene.swift
//  InfinityWheel
//
//  Created by Alessandro Profenna on 2015-10-14.
//  Copyright (c) 2015 Alessandro Profenna. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var score: Int = 0
    var bestScore: Int = 0
    var obstacles:[SKSpriteNode] = []
    var handleCount: Int = 0
    var visibleHandleCount = 0
    let playableRect: CGRect
    var isTouching = false
    var gameOver = true
    var nextRound = false
    
    let wheelRotateRadiansPerSec: CGFloat = π / 3.5
    let handleSpace: CGFloat = (2 * π / 12)
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // sprites
    let wheel = SKSpriteNode(imageNamed: "wheelArt")
    var player = SKSpriteNode(imageNamed: "player")
    let outerWheel = SKSpriteNode(imageNamed: "outerWheel2")
    let background = SKSpriteNode(imageNamed: "Background")
    let title = SKSpriteNode(imageNamed: "title")
    var leftRect : SKShapeNode
    var rightRect : SKShapeNode
    
    // labels and text
    let scoreTextLabel: SKLabelNode
    let scoreValueLabel: SKLabelNode
    let bestTextLabel: SKLabelNode
    let bestValueLabel: SKLabelNode
    let retryLabel: SKLabelNode
    let playLabel: SKLabelNode
    let helpLabel: SKLabelNode
    let backLabel: SKLabelNode
    let helpInfo1: SKLabelNode
    let helpInfo2: SKLabelNode
    let maxScoreInfo: SKLabelNode
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let maxAspectRatioWidth = size.height / maxAspectRatio
        let playableMargin = (size.width - maxAspectRatioWidth) / 2.0
        playableRect = CGRect(x: playableMargin, y: 0, width: maxAspectRatioWidth, height: size.height)
        leftRect = SKShapeNode(rect: CGRect(x: 0, y: 0, width: playableRect.minX, height: size.height))
        leftRect.fillColor = SKColor.blackColor()
        leftRect.lineWidth = 0
        leftRect.zPosition = 40
        rightRect = SKShapeNode(rect: CGRect(x: playableRect.maxX, y: 0, width: playableRect.minX, height: size.height))
        rightRect.fillColor = SKColor.blackColor()
        rightRect.lineWidth = 0
        rightRect.zPosition = 40
        wheel.position = CGPoint(x: playableRect.minX + playableRect.width / 2.0, y:playableRect.minY)
        wheel.setScale((playableRect.width / wheel.frame.width) * 1.11)
        wheel.zPosition = 10
        outerWheel.position = CGPoint(x: playableRect.minX + playableRect.width / 2.0, y:playableRect.minY)
        outerWheel.xScale = wheel.xScale / 0.42
        outerWheel.yScale = wheel.yScale / 0.42
        outerWheel.zPosition = 20
        player.physicsBody = SKPhysicsBody(circleOfRadius: 12)
        player.physicsBody!.usesPreciseCollisionDetection = true
        player.physicsBody!.categoryBitMask = PhysicsCategory.Player
        player.physicsBody!.collisionBitMask = PhysicsCategory.None
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.contactTestBitMask = PhysicsCategory.Handle
        player.xScale = wheel.xScale
        player.yScale = wheel.yScale
        player.position = CGPoint(x: playableRect.minX + playableRect.width / 2.0, y: playableRect.minY + playableRect.height * 0.60)
        scoreTextLabel = SKLabelNode(fontNamed: "Baskerville Bold")
        scoreTextLabel.text = "SCORE"
        scoreTextLabel.verticalAlignmentMode = .Center
        scoreTextLabel.position = CGPoint(x: size.width / 2 - 200, y: playableRect.height * 0.96)
        scoreTextLabel.zPosition = 21
        scoreValueLabel = SKLabelNode(fontNamed: "Baskerville Bold")
        scoreValueLabel.text = "\(score)"
        scoreValueLabel.verticalAlignmentMode = .Center
        scoreValueLabel.position = CGPoint(x: size.width / 2 - 200, y: playableRect.height * 0.91)
        scoreValueLabel.zPosition = 21
        scoreValueLabel.color = SKColor.whiteColor()
        bestTextLabel = SKLabelNode(fontNamed: "Baskerville Bold")
        bestTextLabel.text = "BEST"
        bestTextLabel.verticalAlignmentMode = .Center
        bestTextLabel.position = CGPoint(x: size.width / 2 + 200, y: playableRect.height * 0.96)
        bestTextLabel.zPosition = 21
        bestValueLabel = SKLabelNode(fontNamed: "Baskerville Bold")
        bestValueLabel.text = "\(bestScore)"
        bestValueLabel.verticalAlignmentMode = .Center
        bestValueLabel.position = CGPoint(x: size.width / 2 + 200, y: playableRect.height * 0.91)
        bestValueLabel.zPosition = 21
        retryLabel = SKLabelNode(fontNamed: "Baskerville Bold")
        retryLabel.text = "RETRY"
        retryLabel.name = "retryLabel"
        retryLabel.verticalAlignmentMode = .Center
        retryLabel.fontColor = SKColor.blackColor()
        retryLabel.fontSize = 40
        playLabel = SKLabelNode(fontNamed: "Baskerville Bold")
        playLabel.text = "START"
        playLabel.name = "playLabel"
        playLabel.verticalAlignmentMode = .Center
        playLabel.fontColor = SKColor.blackColor()
        playLabel.fontSize = 40
        helpLabel = SKLabelNode(fontNamed: "Baskerville Bold")
        helpLabel.text = "HOW TO PLAY"
        helpLabel.name = "helpLabel"
        helpLabel.verticalAlignmentMode = .Center
        helpLabel.fontColor = SKColor.blackColor()
        helpLabel.fontSize = 30
        backLabel = SKLabelNode(fontNamed: "Baskerville Bold")
        backLabel.text = "BACK"
        backLabel.name = "backLabel"
        backLabel.verticalAlignmentMode = .Center
        backLabel.fontColor = SKColor.blackColor()
        backLabel.fontSize = 30
        helpInfo1 = SKLabelNode(fontNamed: "Baskerville")
        helpInfo1.text = "PRESS and HOLD the screen to spin the wheel faster."
        helpInfo1.verticalAlignmentMode = .Center
        helpInfo1.position = CGPoint(x: size.width / 2, y: playableRect.height  / 2 + 140)
        helpInfo1.fontColor = SKColor.blackColor()
        helpInfo1.fontSize = 25
        helpInfo2 = SKLabelNode(fontNamed: "Baskerville")
        helpInfo2.text = "Each obstacle you avoid will win you a point!"
        helpInfo2.verticalAlignmentMode = .Center
        helpInfo2.position = CGPoint(x: size.width / 2, y: playableRect.height  / 2 + 110)
        helpInfo2.fontColor = SKColor.blackColor()
        helpInfo2.fontSize = 25
        maxScoreInfo = SKLabelNode(fontNamed: "Baskerville")
        maxScoreInfo.text = "CONGRATS! You've reached the max score!"
        maxScoreInfo.verticalAlignmentMode = .Center
        maxScoreInfo.position = CGPoint(x: size.width / 2, y: playableRect.height  / 2 + 110)
        maxScoreInfo.fontColor = SKColor.blackColor()
        maxScoreInfo.fontSize = 25
        maxScoreInfo.name = "maxScoreInfo"
        title.position = CGPoint(x: playableRect.minX + playableRect.width / 2.0, y:playableRect.minY + playableRect.height - 80)
        title.xScale = wheel.xScale
        title.yScale = wheel.yScale
        title.zPosition = 40
        
        super.init(size: size)
    }
    
    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor.whiteColor()
        background.position = CGPoint(x: playableRect.minX + playableRect.width / 2.0, y:playableRect.minY + playableRect.height / 2.0)
        background.zPosition = -10
        background.setScale(playableRect.width / background.size.width)
        addChild(background)
        addChild(wheel)
        addChild(outerWheel)
        addChild(title)
        addChild(leftRect)
        addChild(rightRect)
        addChild(playLabel)
        playLabel.position = CGPoint(x: size.width / 2, y: playableRect.height  / 2 + 150)
        let oscillatePlay = SKAction.oscillation(amplitude: 3, timePeriod: 0.9, midPoint: CGPoint(x: playLabel.position.x, y: playLabel.position.y - 37))
        playLabel.runAction(SKAction.repeatActionForever(oscillatePlay))
        
        addChild(helpLabel)
        helpLabel.position = CGPoint(x: size.width / 2, y: playableRect.height  / 2)
        let oscillateHelp = SKAction.oscillation(amplitude: 3, timePeriod: 0.9, midPoint: CGPoint(x: helpLabel.position.x, y: helpLabel.position.y - 37))
        helpLabel.runAction(SKAction.repeatActionForever(oscillateHelp))
        
        while (handleCount < 12) {
            createObstacle()
        }
        if (defaults.valueForKey("bestScore") == nil) {
            defaults.setInteger(bestScore, forKey: "bestScore")
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("pauseInfinityWheelGame:"), name: "PauseInfinityWheelGame", object: nil)
    }
    
    func pauseInfinityWheelGame(notification: NSNotification){
        if (!gameOver) {
            endGame()
        }
    }
    
    func endGame() {
        runAction(SKAction.sequence([SKAction.runBlock({self.background.color = SKColor.redColor()}), SKAction.waitForDuration(0.5), SKAction.runBlock({self.background.color = SKColor.whiteColor()})]))
        player.removeFromParent()
        addChild(retryLabel)
        retryLabel.position = CGPoint(x: size.width / 2, y: playableRect.height  / 2 + 150)
        let oscillate = SKAction.oscillation(amplitude: 3, timePeriod: 0.9, midPoint: CGPoint(x: retryLabel.position.x, y: retryLabel.position.y - 37))
        retryLabel.runAction(SKAction.repeatActionForever(oscillate))
        
        addChild(helpLabel)
        helpLabel.position = CGPoint(x: size.width / 2, y: playableRect.height  / 2)
        let oscillateHelp = SKAction.oscillation(amplitude: 3, timePeriod: 0.9, midPoint: CGPoint(x: helpLabel.position.x, y: helpLabel.position.y - 37))
        helpLabel.runAction(SKAction.repeatActionForever(oscillateHelp))
        
        if(score == 99999999) {
            addChild(maxScoreInfo)
            maxScoreInfo.position = CGPoint(x: size.width / 2, y: (playableRect.height  / 2) - 120)
        }
        
        handleCount = 0;
        visibleHandleCount = 0;
        for handle in obstacles {
            handle.removeFromParent()
        }
        gameOver = true;
        nextRound = true;
        
        if ((defaults.valueForKey("bestScore") as! Int) < bestScore) {
            defaults.setInteger(bestScore, forKey: "bestScore")
        }
    }
    
    func startGame() {
        player.position = CGPoint(x: playableRect.minX + playableRect.width / 2.0, y: playableRect.minY + playableRect.height * 0.60)
        let oscillate = SKAction.oscillation(amplitude: 210, timePeriod: 4, midPoint: CGPoint(x: player.position.x, y: player.position.y - 37))
        player.runAction(SKAction.repeatActionForever(oscillate))
        addChild(player)
        wheel.zRotation = 0;
        outerWheel.zRotation = 0;
        gameOver = false
        for handle in obstacles {
            handleCount++
            handle.zRotation = (-π / 2.0) - (CGFloat(handleCount) * handleSpace)
        }
        score = 0;
        bestScore = defaults.valueForKey("bestScore") as! Int
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let collision: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if (collision == PhysicsCategory.Player | PhysicsCategory.Handle) {
            endGame()
        }
        else if (collision == PhysicsCategory.Player | PhysicsCategory.Contact) {
            scorePoint()
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        }
        else {
            dt = 0
        }
        lastUpdateTime = currentTime
        if (isTouching == true && gameOver == false) {
            for handle in obstacles {
                handle.zRotation += wheelRotateRadiansPerSec * CGFloat(dt)
            }
            wheel.zRotation += wheelRotateRadiansPerSec * CGFloat(dt)
            outerWheel.zRotation += wheelRotateRadiansPerSec * CGFloat(dt)
        }
        else {
            for handle in obstacles {
                handle.zRotation += wheelRotateRadiansPerSec / 8 * CGFloat(dt)
            }
            wheel.zRotation += wheelRotateRadiansPerSec / 8 * CGFloat(dt)
            outerWheel.zRotation += wheelRotateRadiansPerSec / 8 * CGFloat(dt)
        }
        scoreValueLabel.text = "\(score)"
        bestValueLabel.text = "\(bestScore)"
        if(!gameOver) {
            if (score > bestScore) {
                bestScore = score
                let scaleUp = SKAction.scaleBy(1.7, duration: 0.23)
                let scaleDown = scaleUp.reversedAction()
                let fullScale = SKAction.sequence([scaleUp, scaleDown])
                bestValueLabel.runAction(fullScale)
            }
            if (((wheel.zRotation + handleSpace) / handleSpace) > CGFloat(visibleHandleCount) && visibleHandleCount < 12) {
                addChild(obstacles[visibleHandleCount])
                visibleHandleCount++
            }
            player.zRotation -= wheelRotateRadiansPerSec * CGFloat(dt) * 2
            for handle in obstacles {
                let handleRotation = (handle.zRotation + (2 * π)) % (2 * π)
                let changePoint = 3 * π / 2
                if (handleRotation > changePoint && handleRotation < changePoint + 0.1) {
                    handle.childNodeWithName("handleBottom")!.position = CGPoint(x: handle.position.y, y: handle.position.x + CGFloat.random(min:15, max: 630))
                    handle.childNodeWithName("handleTop")!.position = CGPoint(x: handle.childNodeWithName("handleBottom")!.position.x , y: handle.childNodeWithName("handleBottom")!.position.y + 980)
                }
            }
            for handle in obstacles {
                let handleRotation = (handle.zRotation + (2 * π)) % (2 * π)
                let changePoint = CGFloat(0.05)
                if (handleRotation > changePoint && handleRotation < changePoint + π) {
                    (handle.childNodeWithName("handleBottom") as! SKSpriteNode).colorBlendFactor = 0.7
                    (handle.childNodeWithName("handleBottom") as! SKSpriteNode).color = SKColor.grayColor()
                    (handle.childNodeWithName("handleTop") as! SKSpriteNode).colorBlendFactor = 0.7
                    (handle.childNodeWithName("handleTop") as! SKSpriteNode).color = SKColor.grayColor()
                }
                else {
                    (handle.childNodeWithName("handleBottom") as! SKSpriteNode).colorBlendFactor = 0
                    (handle.childNodeWithName("handleTop") as! SKSpriteNode).colorBlendFactor = 0
                }
            }
        }
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct PhysicsCategory {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1
        static let Handle: UInt32 = 0b10
        static let Contact: UInt32 = 0b100
    }
    
    func createObstacle() {
        
        let handle = SKSpriteNode(imageNamed: "handleBody")
        handle.xScale = wheel.xScale
        handle.yScale = wheel.yScale
        handle.position = CGPoint(x: playableRect.minX + playableRect.width / 2.0, y: 0)
        handle.zPosition = -1
        handle.anchorPoint = CGPoint(x: 0.5, y: 0)
        let contact = SKSpriteNode()
        let center = CGPointMake(handle.position.y + handle.size.width + 60, handle.position.x + 900)
        contact.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 50, height: 1100), center: center)
        contact.physicsBody!.usesPreciseCollisionDetection = true
        contact.physicsBody!.collisionBitMask = PhysicsCategory.None
        contact.physicsBody!.categoryBitMask = PhysicsCategory.Contact
        contact.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        contact.physicsBody!.affectedByGravity = false
        handle.addChild(contact)
        obstacles.append(handle)
        handleCount++
        
        let handleBottom = SKSpriteNode(imageNamed: "handleArt")
        handleBottom.name = "handleBottom"
        handleBottom.position = CGPoint(x: handle.position.y, y: handle.position.x + CGFloat.random(min:5, max: 630))
        handleBottom.zPosition = 5
        let center3 = CGPointMake(0, handleBottom.position.x)
        handleBottom.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: handleBottom.frame.width, height: handleBottom.frame.height), center: center3)
        handleBottom.physicsBody!.usesPreciseCollisionDetection = true
        handleBottom.physicsBody!.categoryBitMask = PhysicsCategory.Handle
        handleBottom.physicsBody!.collisionBitMask = PhysicsCategory.None
        handleBottom.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        handleBottom.physicsBody!.affectedByGravity = false
        handle.addChild(handleBottom)
        
        let handleTop = SKSpriteNode(imageNamed: "handleArt")
        handleTop.name = "handleTop"
        handleTop.position = CGPoint(x: handleTop.position.y , y: handleBottom.position.y + 1000)
        handleTop.zPosition = 5
        let center4 = CGPointMake(0, handleTop.position.x)
        handleTop.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: handleBottom.frame.width, height: handleBottom.frame.height), center: center4)
        handleTop.physicsBody!.usesPreciseCollisionDetection = true
        handleTop.physicsBody!.categoryBitMask = PhysicsCategory.Handle
        handleTop.physicsBody!.collisionBitMask = PhysicsCategory.None
        handleTop.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        handleTop.physicsBody!.affectedByGravity = false
        handle.addChild(handleTop)
        
        handle.zRotation = (-π / 2.0) - (CGFloat(handleCount) * handleSpace)
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    func scorePoint() {
        score++
        let scaleUp = SKAction.scaleBy(1.7, duration: 0.23)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence([SKAction.runBlock({self.scoreValueLabel.color = SKColor.greenColor()}), scaleUp, scaleDown, SKAction.runBlock({self.scoreValueLabel.color = SKColor.whiteColor()})])
        scoreValueLabel.runAction(fullScale)
        if (score == 99999999)
        {
            endGame()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isTouching = true
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isTouching = true
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first as UITouch!
        let touchLocation = touch.locationInNode(self)
        let scaleUp = SKAction.scaleBy(1.35, duration: 0.15)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence([scaleUp, scaleDown])
        if(retryLabel.frame.contains(touchLocation) && self.childNodeWithName("retryLabel") != nil)
        {
            retryLabel.runAction(fullScale)
            helpLabel.runAction(fullScale)
            retryLabel.removeFromParent()
            helpLabel.removeFromParent()
            if (self.childNodeWithName("maxScoreInfo") != nil) {
                maxScoreInfo.removeFromParent()
            }
            startGame()
        }
        else if (backLabel.frame.contains(touchLocation) && self.childNodeWithName("backLabel") != nil)
        {
            helpInfo1.removeFromParent()
            helpInfo2.removeFromParent()
            backLabel.removeFromParent()
            if (nextRound == false)
            {
                playLabel.runAction(fullScale)
                addChild(playLabel)
            }
            else if (nextRound == true)
            {
                retryLabel.runAction(fullScale)
                addChild(retryLabel)
            }
            playLabel.position = CGPoint(x: size.width / 2, y: playableRect.height  / 2 + 150)
            let oscillatePlay = SKAction.oscillation(amplitude: 3, timePeriod: 0.9, midPoint: CGPoint(x: playLabel.position.x, y: playLabel.position.y - 37))
            playLabel.runAction(SKAction.repeatActionForever(oscillatePlay))
            helpLabel.runAction(fullScale)
            addChild(helpLabel)
            helpLabel.position = CGPoint(x: size.width / 2, y: playableRect.height  / 2)
            let oscillateHelp = SKAction.oscillation(amplitude: 3, timePeriod: 0.9, midPoint: CGPoint(x: helpLabel.position.x, y: helpLabel.position.y - 37))
            helpLabel.runAction(SKAction.repeatActionForever(oscillateHelp))
            retryLabel.position = CGPoint(x: size.width / 2, y: playableRect.height  / 2 + 150)
            let oscillateRetry = SKAction.oscillation(amplitude: 3, timePeriod: 0.9, midPoint: CGPoint(x: retryLabel.position.x, y: retryLabel.position.y - 37))
            retryLabel.runAction(SKAction.repeatActionForever(oscillateRetry))
        }
        else if (helpLabel.frame.contains(touchLocation) && self.childNodeWithName("helpLabel") != nil)
        {
            helpLabel.removeFromParent()
            if (nextRound == false)
            {
                playLabel.removeFromParent()
            }
            else if (nextRound == true)
            {
                retryLabel.removeFromParent()
            }
            if (self.childNodeWithName("maxScoreInfo") != nil) {
                maxScoreInfo.removeFromParent()
            }
            addChild(helpInfo1)
            addChild(helpInfo2)
            backLabel.runAction(fullScale)
            addChild(backLabel)
            backLabel.position = CGPoint(x: size.width / 2, y: playableRect.height  / 2)
            let oscillateBack = SKAction.oscillation(amplitude: 3, timePeriod: 0.9, midPoint: CGPoint(x: backLabel.position.x, y: backLabel.position.y - 37))
            backLabel.runAction(SKAction.repeatActionForever(oscillateBack))
        }
        else if (playLabel.frame.contains(touchLocation) && self.childNodeWithName("playLabel") != nil)
        {
            playLabel.removeFromParent()
            helpLabel.removeFromParent()
            title.removeFromParent()
            scoreTextLabel.runAction(fullScale)
            addChild(scoreTextLabel)
            addChild(scoreValueLabel)
            bestTextLabel.runAction(fullScale)
            addChild(bestTextLabel)
            addChild(bestValueLabel)
            startGame()
        }
        isTouching = false
    }
    
}
