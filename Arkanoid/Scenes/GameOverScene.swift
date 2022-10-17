//
//  GameOverScene.swift
//  Arkanoid
//
//  Created by Admin on 16.10.2022.
//

import SpriteKit
import GameplayKit


final class GameOverScene: SKScene {
    
    private let gameOverSoundsNames: Set<String> = [
        "gameOverSound",
        "hoho"
    ]
    
    var randomGameOverSoundName: String {
        gameOverSoundsNames.randomElement() ?? ""
    }
    
    var gameOverLabel: SKLabelNode?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        gameOverLabel = scene?.childNode(withName: "GameOver") as? SKLabelNode
        SoundManager.shared.play(sound: randomGameOverSoundName, node: gameOverLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let firstTouch = touches.first {
            let touchedNode = atPoint(firstTouch.location(in: self))
            
            if touchedNode.name == "Restart" {
                if let scene = SKScene(fileNamed: "GameScene") {
                    scene.scaleMode = .aspectFill
                    view?.presentScene(scene)
                }
            }
        }
        
    }
}


