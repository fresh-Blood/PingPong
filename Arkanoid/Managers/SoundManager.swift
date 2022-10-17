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
    
    private let soundQueue = OperationQueue()
    
    init() {
        soundQueue.maxConcurrentOperationCount = 1
    }
    
    func play(sound name: String, node: SKNode?) {
        let playSoundAction = SKAction.playSoundFileNamed(name, waitForCompletion: false)
        let operation = BlockOperation {
            node?.run(playSoundAction)
        }
        soundQueue.addOperations([operation], waitUntilFinished: true)
    }
}
