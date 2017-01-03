//
//  GameViewController.swift
//  InfinityWheel
//
//  Created by Alessandro Profenna on 2015-10-14.
//  Copyright (c) 2015 Alessandro Profenna. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size:CGSize(width: 768, height: 1024))
        let skView = self.view as! SKView
        //skView.showsFPS = true
        //skView.showsPhysics = true
        //skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}