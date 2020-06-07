//
//  UiActions.swift
//  Craphead
//
//  Created by Janis Kreicmanis on 11/05/2020.
//  Copyright © 2020 Janis Kreicmanis. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {
    
    func createGameplayUI()
    {
        //CPU MOVE BUTTON
        let cpuMoveBtn = UIButton(frame: CGRect(x: self.frame.size.width/2-50, y: self.frame.size.height-100, width: 100, height: 50))
        cpuMoveBtn.backgroundColor = .green
        cpuMoveBtn.setTitle("CPU MOVE", for: .normal)
        cpuMoveBtn.addTarget(self, action: #selector(makeCpuMoveBtn), for: .touchUpInside)
        self.view!.addSubview(cpuMoveBtn)
        
        //RESTART GAME BUTTON
        let restartBtn = UIButton(frame: CGRect(x: 25, y: self.frame.size.height-100, width: 100, height: 50))
        restartBtn.backgroundColor = .systemBlue
        restartBtn.setTitle("RESET", for: .normal)
        restartBtn.addTarget(self, action: #selector(restartGameBtn), for: .touchUpInside)
        self.view!.addSubview(restartBtn)
        
        
        //END TURN BUTTON
        let endTurnBtn = UIButton(frame: CGRect(x: self.frame.size.width-125, y: self.frame.size.height-100, width: 100, height: 50))
        endTurnBtn.backgroundColor = .red
        endTurnBtn.setTitle("RESET", for: .normal)
        endTurnBtn.addTarget(self, action: #selector(endTurnBtnAction), for: .touchUpInside)
        self.view!.addSubview(endTurnBtn)
        
        //WHOS MOVE LABEL
        
    }
    
    @objc func makeCpuMoveBtn(sender: UIButton!) {
        computerMakeMove()
    }
    
    @objc func restartGameBtn(sender: UIButton!) {
        restartGame()
    }
    
    @objc func endTurnBtnAction(sender: UIButton!) {
        playerEndTurn()
    }
    
}
