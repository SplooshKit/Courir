//
//  LogicEngine.swift
//  Courir
//
//  Created by Ian Ngiaw on 3/20/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import Foundation

protocol LogicEngineDelegate {
    func didCollide()
    func didJump()
    func didDuck()
    func gameDidEnd()
}

class LogicEngine {
    let state: GameState
    let obstacleGenerator: ObstacleGenerator
    var timeStep = 0
    
    init(playerNumber: Int, seed: Int? = nil) {
        obstacleGenerator = ObstacleGenerator(seed: seed)
        let ownPlayer = Player(playerNumber: playerNumber)
        state = GameState(player: ownPlayer)
    }
    
    var score: Int {
        return state.distance
    }
    
    var speed: Int {
        return state.currentSpeed
    }
    
    var gameState: GameState {
        return state
    }
    
    func update() {
        updateObstaclePositions()
        handleCollisions()
        updatePlayerStates()
        generateObstacle()
        updateDistance()
        updateGameSpeed(timeStep)
        timeStep += 1
    }
    
    private func updateObstaclePositions() {
        for obstacle in state.obstacles {
            obstacle.xCoordinate -= state.currentSpeed
        }
        // Remove obstacles that have gone off-screen
        state.obstacles = state.obstacles.filter{$0.xCoordinate + $0.xWidth - 1 >= 0}
    }
    
    private func updateDistance() {
        state.distance += state.currentSpeed
    }
    
    private func updatePlayerStates() {
        for player in state.players {
            switch player.state {
                case let .Jumping(startDistance):
                    if state.distance - startDistance > jumpDistance {
                        player.run()
                    }
                case let .Ducking(startDistance):
                    if state.distance - startDistance > duckDistance {
                        player.run()
                    }
                default:
                    continue
            }
        }
    }
    
    private func handleCollisions() {
        // Use state.currentSpeed to check if there are any obstacles
        // within 1 frame of hitting state.myPlayer. If so then
        // state.myPlayer has been hit
        
        func handleCollisionsWith(obstacles: [Obstacle],
                                  hasCollidedWith: (Obstacle) -> Bool) {
            for obstacle in obstacles {
                if hasCollidedWith(obstacle) {
                    state.myPlayer.run()
                    state.myPlayer.fallBehind()
                }
            }
        }
        
        let obstaclesInNextFrame = state.obstacles.filter {
            $0.xCoordinate < state.myPlayer.xCoordinate + state.currentSpeed
        }
        
        let nonFloatingObstacles = obstaclesInNextFrame.filter {
            $0.type == ObstacleType.NonFloating
        }
        
        let floatingObstacles = obstaclesInNextFrame.filter {
            $0.type == ObstacleType.Floating
        }

        switch state.myPlayer.state {
            case let .Jumping(startDistance):
                handleCollisionsWith(nonFloatingObstacles) { (obstacle) -> Bool in
                    return startDistance + jumpDistance < self.state.distance + obstacle.xCoordinate
                }
            case let .Ducking(startDistance):
                handleCollisionsWith(floatingObstacles) { (obstacle) -> Bool in
                    return startDistance + duckDistance < self.state.distance + obstacle.xCoordinate
                }
            case .Running:
                for _ in obstaclesInNextFrame {
                    state.myPlayer.run()
                    state.myPlayer.fallBehind()
                }
            default:
                return
        }
    }
    
    private func generateObstacle() {
        func readyForNextObstacle() -> Bool {
            return false
        }
        
        if (readyForNextObstacle()) {
            if let obstacle = obstacleGenerator.getNextObstacle() {
                insertObstacle(obstacle)
            }
        }
    }
    
    func updateGameSpeed(timeStep: Int) {
        state.currentSpeed = initialGameSpeed + Int(Double(timeStep) * gameAcceleration)
    }
    
    func insertObstacle(obstacle: Obstacle) {
        state.obstacles.append(obstacle)
    }
    
    func insertPlayer(player: Player) {
        state.players.append(player)
    }
}