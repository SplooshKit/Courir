//
//  RoomViewController.swift
//  Courir
//
//  Created by Ian Ngiaw on 3/25/16.
//  Copyright © 2016 NUS CS3217. All rights reserved.
//

import UIKit
import SpriteKit
import MultipeerConnectivity

private let cellIdentifier = "host-cell-identifer"

class RoomViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var peersTableView: UITableView!
    
    private(set) var isHost = true
    private var peers = [MCPeerID]()
    private let portal = GameNetworkPortal._instance
    private lazy var seed = Int(arc4random())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peersTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        portal.connectionDelegate = self
        portal.gameStateDelegate = self
        peersTableView.dataSource = self
        
        if isHost {
            portal.beginHosting()
        } else {
            startButton.enabled = false
        }
    }

    @IBAction func startGame(sender: AnyObject) {
        portal.stopHosting()
        portal.stopSearchingForHosts()
        var startData = [String: AnyObject]()
        startData["seed"] = seed
        GameNetworkPortal._instance.send(.GameDidStart, data: startData)
        presentGameScene()
    }

    private func presentGameScene() {
        performSegueWithIdentifier("startGameSegue", sender: self)
    }
    
    func playerIsNotHost() {
        isHost = false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "startGameSegue" {
            let destination = segue.destinationViewController as! GameViewController
            destination.isMultiplayer = true
            destination.peers = peers
            destination.seed = seed
        }
    }
}

extension RoomViewController: UITableViewDataSource {
    func tableView(tableView: UITableView,
                   cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = peersTableView
            .dequeueReusableCellWithIdentifier(cellIdentifier)!
        let peerLabel = UILabel(frame: cell.frame)
        peerLabel.text = peers[indexPath.row].displayName
        cell.addSubview(peerLabel)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peers.count
    }
}

extension RoomViewController: GameNetworkPortalConnectionDelegate {
    func foundHostsChanged(foundHosts: [MCPeerID]) {
        
    }
    
    func playerWantsToJoinRoom(peer: MCPeerID, acceptGuest: (Bool) -> Void) {
        acceptGuest(true)
    }
    
    func playersInRoomChanged(peerIDs: [MCPeerID], host: MCPeerID) {
        peers = peerIDs
        dispatch_async(dispatch_get_main_queue(), { self.peersTableView.reloadData() })
    }
    
    func disconnectedFromRoom() {

    }
    
    func gameStartSignalReceived(data: AnyObject?, peer: MCPeerID) {
        presentGameScene()
    }
}

// MARK: GameNetworkPortalGameStateDelegate
extension RoomViewController: GameNetworkPortalGameStateDelegate {
    func jumpActionReceived(data: AnyObject?, peer: MCPeerID) {
        fatalError("Method jumpActionReceived not implemented")
    }

    func duckActionReceived(data: AnyObject?, peer: MCPeerID) {
        fatalError("Method duckActionReceived not implemented")
    }

    func collideActionReceived(data: AnyObject?, peer: MCPeerID) {
        fatalError("Method collideActionReceived not implemented")
    }

    func gameEndSignalReceived(data: AnyObject?, peer: MCPeerID) {

    }
    
    func gameReadySignalReceived(data: AnyObject?, peer: MCPeerID) {
        
    }
    
    func disconnectedFromGame() {
        
    }
}