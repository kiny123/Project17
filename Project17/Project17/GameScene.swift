//
//  GameScene.swift
//  Project17
//
//  Created by nikita on 21.02.2023.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    
    let possibleEnemies = ["ball", "hammer", "tv"]
    var isGameOver = true
    var gameTimer: Timer?
    
    var gameOverLabel: SKLabelNode?
    var newGameLabel: SKLabelNode?
    
    var timerLoop = 0
    var timerInterval: Double = 1

    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
   
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "player")
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)

        score = 0

        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        
        newGame()
    }
    
    func newGame() {
             guard isGameOver else { return }

             score = 0
             timerLoop = 0
             timerInterval = 1

             physicsWorld.gravity = CGVector(dx: 0, dy: 0)
             physicsWorld.contactDelegate = self
             isGameOver = false

             if let gameOverLabel = gameOverLabel {
                 gameOverLabel.removeFromParent()
             }

             if let newGameLabel = newGameLabel {
                 newGameLabel.removeFromParent()
             }

             for node in children {
                 if node.name == "Enemy" {
                     node.removeFromParent()
                 }
             }

             starfield.isHidden = false

             player.position = CGPoint(x: 100, y: 384)
             addChild(player)

             gameTimer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)

    
         }
 
    override func update(_ currentTime: TimeInterval) {
        for node in children {
                if node.position.x < -300 {
                    node.removeFromParent()
                }
            }

            if !isGameOver {
                score += 1
            }
    }
    
    @objc func createEnemy() {
        timerLoop += 1
        guard let enemy = possibleEnemies.randomElement() else { return }

        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)

        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
        if timerLoop >= 20 {
                timerLoop = 0

        if timerInterval >= 0.2 {
                timerInterval -= 0.1
            }

        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
}
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)

        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }

        player.position = location
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard !isGameOver else { return }

            gameOver()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
             guard let touch = touches.first else { return }

             if !isGameOver {
                 gameOver()
                 return
             }

             let location = touch.location(in: self)

             let objects = nodes(at: location)
             for object in objects {
                 if object.name == "NewGame" {
                     newGame()
                 }
             }
         }
    func gameOver() {

        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
             
        player.removeFromParent()

        isGameOver = true

        gameTimer?.invalidate()

        starfield.isHidden = true

        gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel?.position = CGPoint(x: 512, y: 384)
        gameOverLabel?.zPosition = 1
        gameOverLabel?.fontSize = 48
        gameOverLabel?.horizontalAlignmentMode = .center
        gameOverLabel?.text = "Explosed"
        addChild(gameOverLabel!)

        newGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        newGameLabel?.position = CGPoint(x: 512, y: 324)
        newGameLabel?.zPosition = 1
        newGameLabel?.fontSize = 32
        newGameLabel?.horizontalAlignmentMode = .center
        newGameLabel?.text = "One more time"
        newGameLabel?.name = "NewGame"
        addChild(newGameLabel!)

    }
}
