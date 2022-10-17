//
//  GameWinScene.swift
//  Arkanoid
//
//  Created by Admin on 16.10.2022.
//

import SpriteKit
import GameplayKit


final class GameWinScene: SKScene {
    
    private let winSoundsNames: Set<String> = [
        "gameWinSound",
        "yahallo",
        "nya",
        "osoi"
    ]
    
    var randomWinSoundName: String {
        winSoundsNames.randomElement() ?? ""
    }
    
    var gameWinLabel: SKLabelNode?
    var winScore: SKLabelNode?
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        gameWinLabel = scene?.childNode(withName: "Win") as? SKLabelNode
        SoundManager.shared.play(sound: randomWinSoundName, node: gameWinLabel)
        winScore = scene?.childNode(withName: "WinScore") as? SKLabelNode
        winScore?.text = "Score: \(String(getCurrentWinScore() ?? .zero))" 
    }
    
    private func getCurrentWinScore() -> Int? {
        StoreManager.shared.getValue(forKey: "currentWinScore") as? Int
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let firstTouch = touches.first {
            let touchedNode = atPoint(firstTouch.location(in: self))
            
            if touchedNode.name == "NewGame" {
                if let scene = SKScene(fileNamed: "GameScene") {
                    scene.scaleMode = .aspectFill
                    view?.presentScene(scene)
                }
            }
        }
        
    }
}


