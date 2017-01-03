//
//  MyUtils.swift
//  InfinityWheel
//
//  Created by Alessandro Profenna on 2015-10-14.
//  Copyright © 2015 Alessandro Profenna. All rights reserved.
//

import Foundation
import CoreGraphics
import SpriteKit

let π = CGFloat(M_PI)

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random())/Float(UInt32.max))
    }
    static func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
}

extension SKAction {
    static func oscillation(amplitude a: CGFloat, timePeriod t: CGFloat, midPoint: CGPoint) -> SKAction {
        let action = SKAction.customActionWithDuration(Double(t)) { node, currentTime in
            let displacement = a * sin(2 * π * currentTime / t)
            node.position.y = midPoint.y + displacement
        }
        return action
    }
}
