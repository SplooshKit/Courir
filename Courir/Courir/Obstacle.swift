//
//  Obstacle.swift
//  Courir
//
//  Created by Sebastian Quek on 19/3/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

enum ObstacleType {
    case NonFloating, Floating
}

class Obstacle: GameObject {
    static var uniqueId = 0
    
    static let spawnXCoordinate = 64 * unitsPerGameGridCell
    static let spawnYCoordinate = -4 * unitsPerGameGridCell
    static let removalXCoordinate = -16 * unitsPerGameGridCell

    let type: ObstacleType
    let identifier: Int
    let xWidth = 3 * unitsPerGameGridCell
    let yWidth = 21 * unitsPerGameGridCell
    
    weak var observer: Observer?

    var xCoordinate = Obstacle.spawnXCoordinate {
        didSet {
            observer?.didChangeProperty("xCoordinate", from: self)
        }
    }
    
    var yCoordinate = Obstacle.spawnYCoordinate {
        didSet {
            observer?.didChangeProperty("yCoordinate", from: self)
        }
    }
    
    init(type: ObstacleType) {
        self.type = type
        self.identifier = Obstacle.uniqueId
        Obstacle.uniqueId += 1
    }
}