//
//  Bot.swift
//  Craphead
//
//  Created by Janis Kreicmanis on 11/05/2020.
//  Copyright © 2020 Janis Kreicmanis. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {
    
    func computerMakeMove()
    {
        //sort cards
        computerCardsInHand.cards.sort(by: {
            ( $1.dmg() == 2 || $1.dmg() == 3 || $1.dmg() == 7 || $1.dmg() == 10) || $0.dmg() < $1.dmg()
        })
        
        for (idx, c) in computerCardsInHand.cards.enumerated() {
            print("\(idx). \(c.name())  dmg:\(c.dmg())")
        }
        
        
        for card in computerCardsInHand.cards {
            if(canMakeThisMove(player_card: card)){
                moveCardToCenterBot(c: card)
                return
            }
        }
        
        // Player cannot make move os he pick up all stack cards
        while !stackDeck.empty() {
            let cpuCard = stackDeck.getCard()
            computerCardsInHand.addCard(card: cpuCard)
            let dst = CGPoint(x: self.frame.size.width/2, y: (self.frame.size.height*0.8))
            let path = createCurvedPath(from: cpuCard.position, to: dst, varyingBy: 500)
            let squareSpeed = CGFloat(arc4random_uniform(2000)) + 1200
            let moveAction = SKAction.follow(path, asOffset: false, orientToPath: false, speed: CGFloat(squareSpeed))
            cpuCard.run(SKAction.group([moveAction]), completion: {self.sortComputerCards()})
        }
        return
        
        
        
        var currentCardDmg = 3
        if (currentCardDmg == 3){
            // tris uz dead
            //parejas playerim
            
            //            while !stackDeck.empty() {
            //
            //             let playerCard = mainDeck.getCard()
            //
            //
            //             playerCardsInHand.addCard(card: playerCard)
            //             let dst = CGPoint(x: self.frame.size.width/2, y: (self.frame.size.height*0.2))
            //             let path = createCurvedPath(from: playerCard.position, to: dst, varyingBy: 500)
            //             let squareSpeed = CGFloat(arc4random_uniform(2000)) + 1200
            //             let moveAction = SKAction.follow(path, asOffset: false, orientToPath: false, speed: CGFloat(squareSpeed))
            //             playerCard.run(SKAction.group([moveAction]), completion: {self.sortPlayerCards()})
            //            }
            //
            
        }else if (currentCardDmg == 10){
            print("NONONONN 10")
            
            while !stackDeck.empty() {
                moveToDeadZone(card: stackDeck.getCard())
            }
            //pickUpCPUcards()
            //computerMakeMove()
            return
        }
        
        //        if(isStackDead()){
        //            while !stackDeck.empty() {
        //                moveToDeadZone(card: stackDeck.getCard())
        //            }
        //            pickUpCPUcards()
        //            computerMakeMove()
        //            return
        //        }
        
        ///  pickUpCPUcards()
        
        
        
    }
    
    func findSameDmgCard(dmgCard: Card){
        
        for card in computerCardsInHand.cards {
            if(dmgCard.dmg() == card.dmg()){
                moveCardToCenterBot(c: card)
            }
        }
        
        if (dmgCard.dmg() == 3){
            playerPickUpMiddleStack()
            return
            
        }else if (dmgCard.dmg() == 10){
            while !stackDeck.empty() {
                moveToDeadZone(card: stackDeck.getCard())
            }
            pickUpCPUcards()
            computerMakeMove()
            return
        }
        
        //        if(isStackDead()){
        //            while !stackDeck.empty() {
        //                moveToDeadZone(card: stackDeck.getCard())
        //            }
        //            pickUpCPUcards()
        //            computerMakeMove()
        //            return
        //        }
        
        
        pickUpCPUcards()
        
        
    }
    
    func playerPickUpMiddleStack()
    {
        while !stackDeck.empty() {
           let card = stackDeck.getCard()
           if(card.dmg() == 3){
               moveToDeadZone(card: card)
           }else{
               card.movable = true
               playerCardsInHand.addCard(card: card)
               let dst = CGPoint(x: self.frame.size.width/2, y: (self.frame.size.height*0.2))
               let path = createCurvedPath(from: card.position, to: dst, varyingBy: 500)
               let squareSpeed = 400
               let moveAction = SKAction.follow(path, asOffset: false, orientToPath: false, speed: CGFloat(squareSpeed))
               card.run(SKAction.group([moveAction]), completion: {
                if(self.stackDeck.empty()){
                    self.sortPlayerCards();self.pickUpCPUcards();self.computerMakeMove()
                }else{
                    self.sortPlayerCards(); self.playerPickUpMiddleStack();
                }})
           }
       }
        

    }
    
    func moveCardToCenterBot(c: Card){
        var card = c
        card = changeStack(dest_deck: stackDeck, from_deck: computerCardsInHand, card: card)
        let dest = CGPoint(x: self.frame.size.width/2,y: self.frame.size.height/2)
        let path = createCurvedPath(from: card.position, to: dest, varyingBy: 500)
        let squareSpeed = 500
        let moveAction = SKAction.follow(path, asOffset: false, orientToPath: false, speed: CGFloat(squareSpeed))
        card.run(SKAction.group([moveAction]),completion: { self.findSameDmgCard(dmgCard: card)})
        addToCentralStack(player_card: card)
    }
}
