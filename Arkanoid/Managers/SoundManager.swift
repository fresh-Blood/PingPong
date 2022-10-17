//
//  SoundManager.swift
//  Arkanoid
//
//  Created by Admin on 17.10.2022.
//

import Foundation
import SpriteKit

struct SoundManager {
    static let shared = SoundManager()
    
    func play(sound name: String, node: SKNode?) {
        let playSoundAction = SKAction.playSoundFileNamed(name, waitForCompletion: false)
        node?.run(playSoundAction)
    }
}
