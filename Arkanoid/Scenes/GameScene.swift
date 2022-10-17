//
//  GameScene.swift
//  Arkanoid
//
//  Created by Admin on 16.10.2022.
//

import SpriteKit
import GameplayKit

struct PhysicsBodies {
    static let ballBodyMask: UInt32 = 1
    static let brickBodyMask: UInt32 = 2
    static let borderBodyMask: UInt32 = 3
}

final class GameScene: SKScene {

    private lazy var borderBallCollisionCounter = 0
    private lazy var currentWinScore = 0
    
    var ball: SKSpriteNode?
    var platform: SKSpriteNode?
    var score: SKLabelNode?
    var lifesLeft: SKLabelNode?
    var brick: SKSpriteNode?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.physicsWorld.contactDelegate = self
        ball = childNode(withName: "Ball") as? SKSpriteNode
        platform = childNode(withName: "Platform") as? SKSpriteNode
        brick = childNode(withName: "Brick") as? SKSpriteNode
        score = childNode(withName: "Score") as? SKLabelNode
        lifesLeft = childNode(withName: "LifesLeft") as? SKLabelNode

        let dRandom = CGFloat((100..<200).randomElement() ?? 10)
        
        ball?.physicsBody?.applyImpulse(CGVector(dx: 150, dy: dRandom))
        configureBorder()
    }
    
    private func configureBorder() {
        guard let viewSceneFrame = view?.scene?.frame else { return }
        let ballWidth = ball?.size.width ?? .zero
        let updatedViewSceneframe = CGRect(x: viewSceneFrame.minX + ballWidth * 2,
                                           y: viewSceneFrame.minY,
                                           width: viewSceneFrame.width - ballWidth * 4,
                                           height: viewSceneFrame.height)
        let border = SKPhysicsBody(edgeLoopFrom: updatedViewSceneframe)
        border.friction = .zero
        border.restitution = .zero
        border.categoryBitMask = PhysicsBodies.borderBodyMask
        border.collisionBitMask = PhysicsBodies.ballBodyMask
        physicsBody = border
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touches.forEach {
            let touchLocation = $0.location(in: self)
            platform?.position.x = touchLocation.x
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        touches.forEach {
            let touchLocation = $0.location(in: self)
            platform?.position.x = touchLocation.x
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA.node
        let bodyB = contact.bodyB.node
        playPongSound(bodyA: bodyA, bodyB: bodyB)
        handleBallAndBrickCollisions(bodyA: bodyA, bodyB: bodyB)
        handleBallAndBorderCollisions(bodyA: bodyA, bodyB: bodyB)
        animateNodes(bodyA: bodyA, bodyB: bodyB)
        updateLifesLeftCount()
        presentGameWinSceneIfWin()
    }
    
    private func playPongSound(bodyA: SKNode?, bodyB: SKNode?) {
        let pongSoundAction = SKAction.playSoundFileNamed("pongSound", waitForCompletion: false)
        if bodyA == platform {
            bodyA?.run(pongSoundAction)
        } else if bodyB == platform {
            bodyB?.run(pongSoundAction)
        }
    }
    
    private func handleBallAndBrickCollisions(bodyA: SKNode?, bodyB: SKNode?) {
        if bodyA?.physicsBody?.categoryBitMask == PhysicsBodies.ballBodyMask &&
            bodyB?.physicsBody?.categoryBitMask == PhysicsBodies.brickBodyMask {
            updateScore()
        } else if bodyA?.physicsBody?.categoryBitMask == PhysicsBodies.brickBodyMask &&
                    bodyB?.physicsBody?.categoryBitMask == PhysicsBodies.ballBodyMask {
            updateScore()
        }
    }
    
    private func animateNodes(bodyA: SKNode?, bodyB: SKNode?) {
        if bodyA?.physicsBody?.categoryBitMask != PhysicsBodies.borderBodyMask && bodyB?.physicsBody?.categoryBitMask != PhysicsBodies.borderBodyMask {
            animateBallAndPlatformCollisions(nodes: [bodyA, bodyB])
        }
    }
    
    private func animateBallAndPlatformCollisions(nodes: Set<SKNode?>) {
        animatePlatformCollision(nodes: nodes)
        animateBrickCollision(nodes: nodes)
    }
    
    private func animatePlatformCollision(nodes: Set<SKNode?>) {
        if let platform = nodes.first(where: { $0?.name == "Platform" }) {
            let scaleAnimation = SKAction.scale(to: CGSize(width: 90.0,
                                                           height: 30.0), duration: 0.3)
            let backScaleAnimation = SKAction.scale(to: CGSize(width: 80.0,
                                                               height: 20.0), duration: 0.3)
            
            let animations = SKAction.sequence([ scaleAnimation, backScaleAnimation ])
            
            platform?.run(animations)
        }
    }
    
    private func animateBrickCollision(nodes: Set<SKNode?>) {
        if let brick = nodes.first(where: { $0?.name == "Brick" }) {
            let scaleAnimation = SKAction.scale(to: CGSize(width: 80.0,
                                                           height: 25.0), duration: 0.3)
            let backScaleAnimation = SKAction.scale(to: CGSize(width: 70.0,
                                                               height: 15.0), duration: 0.3)
            
            let animations = SKAction.sequence([ scaleAnimation, backScaleAnimation ])
            
            brick?.run(animations, completion: { [weak self] in
                self?.playBubbleSound(brick: brick)
                brick?.removeFromParent()
            })
        }
    }
    
    private func playBubbleSound(brick: SKNode?) {
        SoundManager.shared.play(sound: "bubbleSound", node: brick)
    }
    
    private func handleBallAndBorderCollisions(bodyA: SKNode?, bodyB: SKNode?) {
        if bodyA?.physicsBody?.categoryBitMask == PhysicsBodies.ballBodyMask &&
            bodyB?.physicsBody?.categoryBitMask == PhysicsBodies.borderBodyMask {
            borderBallCollisionCounter += 1
        } else if bodyA?.physicsBody?.categoryBitMask == PhysicsBodies.borderBodyMask &&
                    bodyB?.physicsBody?.categoryBitMask == PhysicsBodies.ballBodyMask {
            borderBallCollisionCounter += 1
        }
        changeBallDirectionIfStucked()
    }
    
    private func changeBallDirectionIfStucked() {
        guard let sceneMiddleY = scene?.frame.midY,
              let sceneMiddleX = scene?.frame.midX,
              let ball = ball else { return }
        if borderBallCollisionCounter % 3 == .zero {
            let dy = ball.frame.origin.y < sceneMiddleY ? 3 : -3
            let dx = ball.frame.origin.x < sceneMiddleX ? 3 : -3
            ball.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
            borderBallCollisionCounter = .zero
        }
    }
    
    private func playBallJumpSound(ball: SKNode?) {
        let playJumpSoundAction = SKAction.playSoundFileNamed("jumpSound",
                                                              waitForCompletion: false)
        ball?.run(playJumpSoundAction)
    }
    
    private func updateScore() {
        if let scoreValue = score?.text {
            let currentScore = scoreValue.compactMap { $0.wholeNumberValue }
            let joinedCurrentScore = currentScore.map { String($0) }.joined()
            
            var updatedScore = Int(String(joinedCurrentScore)) ?? .zero
            updatedScore += 10
            currentWinScore = updatedScore
            score?.text = scoreValue.replacingOccurrences(of: String(joinedCurrentScore),
                                                          with: String(updatedScore))
        }
    }
    
    private func updateLifesLeftCount() {
        guard let ballOriginY = ball?.frame.origin.y,
              let platformOrignY = platform?.frame.origin.y else { return }
        
        if ballOriginY < platformOrignY {
            centerBallAgain()
            if let lifesLeftValue = lifesLeft?.text {
                let currentLifes = lifesLeftValue.compactMap { $0.wholeNumberValue }
                let joinedCurrentLifes = currentLifes.map { String($0) }.joined()
                var updatedLifesLeft = Int(String(joinedCurrentLifes)) ?? .zero
                updatedLifesLeft -= 1
                
                if updatedLifesLeft == 0 {
                    presentGameOverScene()
                }
                
                lifesLeft?.text = lifesLeftValue.replacingOccurrences(
                    of: String(joinedCurrentLifes),
                    with: String(updatedLifesLeft)
                )
            }
        }
    }
    
    private func centerBallAgain() {
        let allBricks = children.filter { $0.name == "Brick" }
        let allBricksFrames = allBricks.compactMap { $0.frame }
        guard let lastBottomBrickFrame = allBricksFrames.last else { return }
        
        let lastBottomBrickOrigin = lastBottomBrickFrame.origin
        let minusBrickHeightOrigin = CGPoint(x: lastBottomBrickOrigin.x,
                                             y: lastBottomBrickOrigin.y - lastBottomBrickFrame.height / 2)
        
        if let ball = ball {
            let centerAction = SKAction.move(to: minusBrickHeightOrigin, duration: 0.5)
            playBallJumpSound(ball: ball)
            ball.run(centerAction)
        }
    }
    
    private func presentGameOverScene() {
        if let gameOverScene = SKScene(fileNamed: "GameOverScene") {
            self.view?.presentScene(gameOverScene, transition: .crossFade(withDuration: 0.5))
        }
    }
    
    private func presentGameWinSceneIfWin() {
        guard let sceneNodes = scene?.children else { return }
        if !sceneNodes.contains(where: { node in
            node.name == "Brick"
        }) {
            if let gameWinScene = SKScene(fileNamed: "GameWinScene") {
                saveWinScore()
                view?.presentScene(gameWinScene, transition: .crossFade(withDuration: 0.5))
            }
        }
    }
    
    private func saveWinScore() {
        StoreManager.shared.save(currentWinScore, forKey: "currentWinScore")
    }
}

