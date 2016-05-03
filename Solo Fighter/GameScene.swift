//
//  GameScene.swift
//  Solo Fighter
//
//  Created by Isaiah Weaver  on 4/24/16.
//  Copyright (c) 2016 Mobile Shah. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    
    let player = SKSpriteNode(imageNamed: "playerShip")
    let bulletSound = SKAction.playSoundFileNamed("laserSound.mp3", waitForCompletion: false)
   
    var audioPlayer: AVAudioPlayer?
    
   //functions are for randomly generating enemyShips
    
    func random()-> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        
    }
    
    func random(min min:CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    //This is to limit the game area size, need the ship not to leave the screen
    
    let gameArea: CGRect
    
    override init(size: CGSize){
        
        let maxAspectRation: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRation
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMoveToView(view: SKView) {
        
        
        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
       
        
        
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        player.zPosition = 2
        self.addChild(player)
  
        // first attempt for background music
        
        let backgroundMusic = SKAudioNode(fileNamed: "Imperfect Lock.m4a")
        backgroundMusic.autoplayLooped = true
        self.addChild(backgroundMusic)
        /* This code below starts a SIGABART error. I don't know why.
        backgroundMusic.runAction(SKAction.play()) */
        startNewLevel()
        playBGMusic()

        
        
    }
    func playBGMusic() {
        
        // Storing the location of the mp3 into the url constant
        let url = NSBundle.mainBundle().URLForResource("Imperfect Lock", withExtension: "m4a")
        var error: NSError?
        
        do {
            
            // Storing the url of the mp3 into the audio player
            try audioPlayer = AVAudioPlayer(contentsOfURL: url!)
            audioPlayer?.numberOfLoops = -1 // Will play for a infinite amount
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
        } catch let error1 as NSError {
            
            error = error1
        }
        
        if error != nil {
            
            print("We have a problem \(error.debugDescription)")
        }
    }
    
    
    func startNewLevel(){
        
        let spawn = SKAction.runBlock(spawnEnemy)
        let waitToSpawn = SKAction.waitForDuration(1)
        let spawnSequence = SKAction.sequence([spawn,waitToSpawn])
        let spawnForever = SKAction.repeatActionForever(spawnSequence)
        self.runAction(spawnForever)
        
        
    }

    func fireBullet (){
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveToY(self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.runAction(bulletSequence)
        
    }
    
    func spawnEnemy(){
        
        let randomXStart = random(min:CGRectGetMinX(gameArea), max:CGRectGetMaxX(gameArea))
        let randomXEnd = random(min:CGRectGetMinX(gameArea), max:CGRectGetMaxX(gameArea))
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        self.addChild(enemy)
        
        let moveEnemy = SKAction.moveTo(endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        enemy.runAction(enemySequence)
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy,dx)
        enemy.zRotation = amountToRotate
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        fireBullet()
        
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.locationInNode(self)
            let previousPointOfTouch = touch.previousLocationInNode(self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            player.position.x += amountDragged
            
            if player.position.x > CGRectGetMaxX(gameArea) - player.size.width/2{
                player.position.x = CGRectGetMaxX(gameArea) - player.size.width/2
            }
            if player.position.x < CGRectGetMinX(gameArea) + player.size.width/2{
                player.position.x = CGRectGetMinX(gameArea) + player.size.width/2
            }
            
            
        }
    }
}
