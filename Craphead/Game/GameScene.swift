//
//  GameScene.swift
//  Craphead
//
//  Created by Janis Kreicmanis on 24/03/2020.
//  Copyright © 2020 Janis Kreicmanis. All rights reserved.
//

import SpriteKit
import Darwin


enum CardLevel :CGFloat {
    case board = 10
    case moving = 100
    case enlarged = 200
}

class GameScene: SKScene {
    
    var mainDeck = Deck(ownersName: "MainDeck")   //holds all the cards
    var stackDeck = Deck(ownersName: "stackDeck") //playing deck
    var deadCardDeck = Deck(ownersName: "deadCardDeck") //played cards
    
    var playerDeck = Deck(ownersName: "Player")
    var playerCardsInHand = Deck(ownersName: "PlayerHand")
    
    var computerDeck = Deck(ownersName: "Computer")
    var computerCardsInHand = Deck(ownersName: "ComputerHand")
    
    var playRect = CGRect()
    var playerCardRect = CGRect()
    let gameRules = Rules()
    
    var deadZone = CGPoint()
    
    var waitOnAnimation = false

    
    override func didMove(to view: SKView) {

       newGame()

    }
    
    func restartGame(){
        mainDeck.deleteStack()
        stackDeck.deleteStack()
        deadCardDeck.deleteStack()
        playerDeck.deleteStack()
        playerCardsInHand.deleteStack()
        computerDeck.deleteStack()
        computerCardsInHand.deleteStack()
        
        
        newGame()
        
        stackInfo()
        
        // DO SOME TESTING BECAUSE NODE COUNT GOES UP

    }
        
        
    func newGame()
    {
        createGameplayUI()
        
        addDropZone()
        addHandZone()
        
        dealCards()
        
        addStartingHands()

    }
    
    func addStartingHands(){
        // ADD CARDS TO PLAYER HAND
        for i in 1...3 {
            let playerCard = mainDeck.getCard()
            playerCardsInHand.addCard(card: playerCard)
            let dst = CGPoint(x: self.frame.size.width/2, y: (self.frame.size.height*0.2))
            let path = createCurvedPath(from: playerCard.position, to: dst, varyingBy: 500)
            let squareSpeed = CGFloat(arc4random_uniform(2000)) + 1200
            let moveAction = SKAction.follow(path, asOffset: false, orientToPath: false, speed: CGFloat(squareSpeed))
            playerCard.run(SKAction.group([moveAction]), completion: {self.sortPlayerCards()})
        }
        // ADD CARDS TO CPU HAND
        pickUpCPUcards()

    }
    
    func playerEndTurn(){
        print("NOT IMPLEMENTED")
    }
    
    
    
 
    
    func moveCardToCenter(c: Card){
        var card = c
        if(card.owner == computerCardsInHand.getOwner()){
            card = changeStack(dest_deck: stackDeck, from_deck: computerCardsInHand, card: card)
        }
        let destinationp = CGPoint(x: self.frame.size.width/2,y: self.frame.size.height/2)
        animeteMove(card: card,dest: destinationp)
        addToCentralStack(player_card: card)
    }
    
    func pickUpCPUcards()
    {
        if(!mainDeck.empty()){
            while computerCardsInHand.size() < 3 && !mainDeck.empty() {
                let cpuCard = mainDeck.getCard()
                computerCardsInHand.addCard(card: cpuCard)
                let dst = CGPoint(x: self.frame.size.width/2, y: (self.frame.size.height*0.8))
                let path = createCurvedPath(from: cpuCard.position, to: dst, varyingBy: 500)
                let squareSpeed = CGFloat(arc4random_uniform(2000)) + 1200
                let moveAction = SKAction.follow(path, asOffset: false, orientToPath: false, speed: CGFloat(squareSpeed))
                cpuCard.run(SKAction.group([moveAction]), completion: {self.sortComputerCards()})
            }
        }
        
    }

    
    func changeStack(dest_deck: Deck, from_deck: Deck, card: Card)->Card
    {
        for (index, c) in from_deck.cards.enumerated() {
            if c.name() == card.name() {
                let t_card = from_deck.cards.remove(at: index)
                dest_deck.addCard(card: t_card)
                return t_card
            }
        }
        return card
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if let card = atPoint(location) as? Card {
                card.originPosition = card.position
                
                if !card.movable {
                    return
                }
                card.zPosition = CardLevel.moving.rawValue
                if touch.tapCount  == 2{
                    card.flip()
                    return
                }
                
                if card.enlarged { return }
                //        let wiggleIn = SKAction.scaleX(to: 1.0, duration: 0.2)
                //        let wiggleOut = SKAction.scaleX(to: 1.2, duration: 0.2)
                //        let wiggle = SKAction.sequence([wiggleIn, wiggleOut])
                //
                //        card.run(SKAction.repeatForever(wiggle), withKey: "wiggle")
                
                let rotR = SKAction.rotate(byAngle: 0.15, duration: 0.2)
                let rotL = SKAction.rotate(byAngle: -0.15, duration: 0.2)
                let cycle = SKAction.sequence([rotR, rotL, rotL, rotR])
                let wiggle = SKAction.repeatForever(cycle)
                //card.run(wiggle, withKey: "wiggle")
                
                card.removeAction(forKey: "drop")
                card.run(SKAction.scale(to: 1.3, duration: 0.25), withKey: "pickup")
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if let card = atPoint(location) as? Card {
                if card.enlarged { return }
                if !card.movable {
                    return
                }
                card.position = location
                
                
                
                var yesno = "AREA: "
                if(playRect.contains(location)){
                    yesno="DROP: "
                }
                if(playerCardRect.contains(location)){
                    yesno="PLYR: "
                }
                
                // print(yesno+"Point x: \(Int(location.x)) y : \(Int(location.y))  Rect x:\(playRect.origin.x), y:\(playRect.origin.y), w:\(playRect.origin.x+playRect.width), h:\(playRect.origin.y+playRect.height)")
                
            }
        }
    }
    
    func returnCard(card: Card){
        animeteMove(card: card,dest: card.originPosition)
        card.position = card.originPosition;
        dropCard(card: card)
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if var card = atPoint(location) as? Card {
                print("Current card owner: \(card.owner)")
                if(playerCardRect.contains(location)){
                    dropCard(card: card)
                    
                    if(card.owner != playerCardsInHand.getOwner()){
                        card = changeStack(dest_deck: playerCardsInHand, from_deck: mainDeck, card: card)
                        //playerCardsInHand.addCard(card: card)
                    }
                    print("AFTER drop card owner: \(card.owner)")
                    
                    sortPlayerCards()
                    print("Card droped at player zone")
                    stackInfo()
                    
                    return
                }
                
                if(playRect.contains(location)){
                    if(canMakeThisMove(player_card: card)){
                        print("Yes, CAN MAKE MOVE")
                        if(card.owner == playerCardsInHand.getOwner()){
                            card = changeStack(dest_deck: stackDeck, from_deck: playerCardsInHand, card: card)
                        }
                        
                        addToCentralStack(player_card: card)
                        
                        if(isStackDead()){
                            while !stackDeck.empty() {
                                moveToDeadZone(card: stackDeck.getCard())
                                
                            }
                        }
                        
                        sortPlayerCards()
                        return
                    }
                    
                }
                returnCard(card: card)
                sortPlayerCards()
                
            }
        }
    }
    
    func isStackDead() -> Bool
    {
        if(stackDeck.getCardRef().dmg() == 10){
            return true;
        }
        if(stackDeck.size() >= 4)
        {
            let lastVal = stackDeck.getCardRef().dmg()
            let stackSize = stackDeck.size()
            print("Size of stackDeck: \(stackDeck.size())")
            if (stackDeck.cards[stackSize-1].dmg() == lastVal &&
                stackDeck.cards[stackSize-2].dmg() == lastVal &&
                stackDeck.cards[stackSize-3].dmg() == lastVal &&
                stackDeck.cards[stackSize-4].dmg() == lastVal ){
                return true
            }
        }
        return false
    }
    
    func addHandZone(){
        let centralPoint = CGPoint(x: self.size.width/2,y: self.size.height/8)
        playerCardRect = CGRect(origin: centralPoint, size: CGSize(width: self.size.width, height: self.size.height/4) )
        let texture = SKTexture(imageNamed: "red_back")
        let stuff = SKSpriteNode(texture: texture, color: .blue, size: playerCardRect.size)
        stuff.position = playerCardRect.origin
        //addChild(stuff)
        playerCardRect.origin = CGPoint(x: playerCardRect.origin.x-(playerCardRect.width/2),
                                        y: playerCardRect.origin.y-(playerCardRect.height/2))
        
    }
    
    func addDropZone(){
        let centralPoint = CGPoint(x: self.size.width/2,y: self.size.height/2)
        let part = self.size.width/4
        playRect = CGRect(origin: centralPoint, size: CGSize(width: part, height: part) )
        let texture = SKTexture(imageNamed: "fffff")
        let stuff = SKSpriteNode(texture: texture, color: .blue, size: playRect.size)
        stuff.position = playRect.origin
        addChild(stuff)
        playRect.origin = CGPoint(x: playRect.origin.x-(playRect.width/2),
                                  y: playRect.origin.y-(playRect.height/2))
    }
    
    func addToCentralStack(player_card: Card){
        
        if !player_card.enlarged {
            player_card.zPosition = CardLevel.board.rawValue
            
            //            player_card.removeAction(forKey: "wiggle")
            //            player_card.run(SKAction.rotate(toAngle: 0, duration: 0.2), withKey:"rotate")
            
            player_card.removeAction(forKey: "pickup")
            player_card.run(SKAction.scale(to: 1.0, duration: 0.25), withKey: "drop")
            
            player_card.removeFromParent()
            addChild(player_card)
        }
        
        
        player_card.movable = false
        player_card.removeFromParent()
        addChild(player_card)
    }
    
    func canMakeThisMove(player_card: Card)->Bool{
        print("Player: \(player_card.dmg()) vs Center: \( stackDeck.getCardRef().dmg())")
        if(!stackDeck.empty()){
            let topCard = stackDeck.getCardRef()
            print("Top Card name: \(topCard.name())")
            return gameRules.putOnTable(player_card: player_card,on_top_card: topCard)
        }
        print("stackDeck.empty()")
        return true
    }
    
    
    func dropCard(card: Card){
        if card.enlarged { return }
        card.zPosition = CardLevel.board.rawValue
        
        //        card.removeAction(forKey: "wiggle")
        //        card.run(SKAction.rotate(toAngle: 0, duration: 0.2), withKey:"rotate")
        
        card.removeAction(forKey: "pickup")
        card.run(SKAction.scale(to: 1.0, duration: 0.25), withKey: "drop")
        
        card.removeFromParent()
        addChild(card)
    }
    
    func moveToDeadZone(card: Card){
        card.position = deadZone
        //card.zRotation = .pi / 2
        card.movable = false
        card.flip()
        card.owner = "dead"
        deadCardDeck.addCard(card: card)
    }
    
    
}
























//GOOD FUNCTIONS
extension GameScene {
    
    
    
    func sortComputerCards()
    {
        if(computerCardsInHand.empty()){
            return
        }
        
        //computerCardsInHand.cards.sort(by: { $0.dmg() < $1.dmg() })
        computerCardsInHand.cards.sort(by: {
            ( $1.dmg() == 2 || $1.dmg() == 3 || $1.dmg() == 7 || $1.dmg() == 10) || $0.dmg() < $1.dmg()
        })
        
        let startPoint = CGPoint(x: self.frame.size.width/2, y: (self.frame.size.height*1.35))
        let lineLenght = self.frame.size.height/2;
        
        var degressArr:[Double] = []
        
        let cardsInHand = computerCardsInHand.size()
        
        for deg in 180...360 {
            let end_p = getEndPoint(start: startPoint, lenght: Float(lineLenght), radians: Float(deg2rad(Double(deg))))
            if self.frame.contains(end_p) {
                degressArr.append(Double(deg))
            }
        }
        degressArr.sort()
        let minAngle = degressArr.first!+5
        let maxAngle = degressArr.last!-5
        let angleDiff = maxAngle-minAngle
        
        let cardPartSize = angleDiff/Double(cardsInHand+1);
        
        for c in 1...cardsInHand {
            let newCardAngleDegPos = (Double(c)*cardPartSize)+minAngle
            let newCardAngleDegRot = maxAngle-(Double((cardsInHand-c)+1)*cardPartSize)
            
            var end_p = getEndPoint(start: startPoint, lenght: Float(lineLenght), radians: Float(deg2rad(Double(newCardAngleDegPos))))
            computerCardsInHand.cards[c-1].position = CGPoint(x: 0, y:0)
            computerCardsInHand.cards[c-1].position = end_p
            computerCardsInHand.cards[c-1].zRotation = deg2rad(newCardAngleDegRot-90)
            computerCardsInHand.cards[c-1].removeFromParent()
            addChild(computerCardsInHand.cards[c-1])
        }
        
    }
    
    
    
    func sortPlayerCards()
    {
        if(playerCardsInHand.empty()){
            return
        }
        
        playerCardsInHand.cards.sort(by: { $0.dmg() > $1.dmg() })
        
        let startPoint = CGPoint(x: self.frame.size.width/2, y: (self.frame.size.height*1.25))
        let lineLenght = self.frame.size.height/2;
        
        var degressArr:[Double] = []
        
        let cardsInHand = playerCardsInHand.size()
        
        for deg in 180...360 {
            var end_p = getEndPoint(start: startPoint, lenght: Float(lineLenght), radians: Float(deg2rad(Double(deg))))
            if self.frame.contains(end_p) {
                //  drawCurvedLine(end_point: end_p,start_point: startPoint)
                // print("\(degressArr.count). good end_p: \(end_p) and deg: \(deg)")
                end_p.y = self.frame.size.height-end_p.y
                degressArr.append(Double(deg))
            }
        }
        degressArr.sort()
        let minAngle = degressArr.first!+5
        let maxAngle = degressArr.last!-5
        let angleDiff = maxAngle-minAngle
        
        let cardPartSize = angleDiff/Double(cardsInHand+1);
        
        //        print("minAngle \(minAngle)")
        //        print("maxAngle \(maxAngle)")
        //        print("cardPartSize \(cardPartSize)")
        
        
        for c in 1...cardsInHand {
            
            let newCardAngleDegPos = (Double(c)*cardPartSize)+minAngle
            let newCardAngleDegRot = maxAngle-(Double(c)*cardPartSize)
            
            //print("currnet angle \(newCardAngleDegPos)")
            
            
            var end_p = getEndPoint(start: startPoint, lenght: Float(lineLenght), radians: Float(deg2rad(Double(newCardAngleDegPos))))
            end_p.y = self.frame.size.height-end_p.y
            playerCardsInHand.cards[c-1].position = CGPoint(x: 0, y:0)
            
            playerCardsInHand.cards[c-1].position = end_p
            
            //print("CARD ROATION BEFORE: \(playerCardsInHand.cards[c-1].zRotation)")
            playerCardsInHand.cards[c-1].zRotation = deg2rad(newCardAngleDegRot-90)
            // print("CARD ROATION After: \(playerCardsInHand.cards[c-1].zRotation)")
            
            // addChild(playerCardsInHand.cards[c-1])
            
            playerCardsInHand.cards[c-1].removeFromParent()
            addChild(playerCardsInHand.cards[c-1])
        }
        
    }
    
    
    
    func drawCurvedLine(end_point: CGPoint, start_point: CGPoint)
    {
        let path = UIBezierPath()
        path.move(to: start_point)
        path.addLine(to: end_point)
        
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.orange.cgColor
        layer.path = path.cgPath
        
        self.view!.layer.addSublayer(layer)
    }
    
    func getEndPoint(start: CGPoint, lenght: Float, radians: Float)->CGPoint{
        let  deltaX = lenght * cos(radians)
        let  deltaY = lenght * sin(radians)
        let endX = Float(start.x) + deltaX;
        let endy = Float(start.y) + deltaY;
        return CGPoint(x: Double(endX), y: Double(endy))
    }
    
    
    func dealCards(){
        //Full up main deck
        for s in 1...4 {
            for v in 2...14 {
                let card = Card(cardValue: v, suit: s)
                mainDeck.addCard(card: card)
            }
        }
        mainDeck.shuffle() ///shuffles deck
        
        
        for c in mainDeck.cards {
            c.position = CGPoint(x: c.size.width/1.5,y:self.size.height/2)
            addChild(c)
            //c.flip()
        }
        
        
        deadZone = CGPoint(x: self.size.width, y: self.size.height/2 )
        
        return
        let width4rth = Int(self.size.width/4)
        //Deal Cards
        ///Player hidden cards
        for s in 1...3 {
            let playerCard = mainDeck.getCard()
            playerDeck.addCard(card: playerCard)
            let destinationp = CGPoint(x: Int(width4rth*s),y: Int(playerCard.size.height*1.5))
            animeteMove(card: playerCard,dest: destinationp)
            playerCard.position = destinationp
            playerCard.originPosition = destinationp
            playerCard.flip()
            playerCard.movable = false
            playerCard.removeFromParent()
            addChild(playerCard)
            
            let computerCard = mainDeck.getCard()
            computerDeck.addCard(card: computerCard)
            let destinationc = CGPoint(x: Int(width4rth*s),y: Int(computerCard.size.height*5.75))
            animeteMove(card: computerCard,dest: destinationc)
            computerCard.position = destinationc
            computerCard.originPosition = destinationc
            computerCard.flip()
            computerCard.movable = false
            computerCard.removeFromParent()
            addChild(computerCard)
        }
        
        //cards on top
        for s in 1...3 {
            let playerCard = mainDeck.getCard()
            playerDeck.addCard(card: playerCard)
            let destinationp = CGPoint(x: Int(width4rth*s),y: Int(playerCard.size.height*1.5))
            animeteMove(card: playerCard,dest: destinationp)
            playerCard.position = destinationp
            playerCard.originPosition = destinationp
            playerCard.movable = false
            playerCard.removeFromParent()
            addChild(playerCard)
            
            let computerCard = mainDeck.getCard()
            computerDeck.addCard(card: computerCard)
            let destinationc = CGPoint(x: Int(width4rth*s),y: Int(computerCard.size.height*5.75))
            animeteMove(card: computerCard,dest: destinationc)
            computerCard.position = destinationc
            computerCard.originPosition = destinationc
            computerCard.movable = false
            computerCard.removeFromParent()
            addChild(computerCard)
        }
        
        
    }
    func animeteMove(card: Card, dest: CGPoint ){
        
        let path = createCurvedPath(from: card.position, to: dest, varyingBy: 500)
       // let squareSpeed = CGFloat(arc4random_uniform(2000)) + 1200
        let squareSpeed = 500
        let moveAction = SKAction.follow(path, asOffset: false, orientToPath: false, speed: CGFloat(squareSpeed))
        //let rotateAction = SKAction.rotate(byAngle: 2 * CGFloat.pi, duration: TimeInterval(squareSpeed))
        card.run(SKAction.group([moveAction]))

    }
    
    
    func createCurvedPath(from start: CGPoint, to destination: CGPoint, varyingBy offset: UInt32) -> CGMutablePath {
        let pathToMove = CGMutablePath()
        pathToMove.move(to: start)
        pathToMove.addLine(to: destination)
        //            let controlPoint = CGPoint(x: CGFloat(arc4random_uniform(offset)) - CGFloat(offset/2),
        //                                       y: CGFloat(arc4random_uniform(offset)) - CGFloat(offset/2))
        //            pathToMove.addQuadCurve(to: destination, control: controlPoint)
        return pathToMove
    }
    
    func deg2rad(_ number: Double) -> CGFloat {
        return CGFloat(number * .pi / 180)
    }
    
    func stackInfo(){
        print("stackDeck   \(stackDeck.size())")
        print("mainDeck    \(mainDeck.size())")
        print("playerDeck  \(playerDeck.size())")
        
        print("CardsInHand \(playerCardsInHand.size())")
        print("computerDec \(computerDeck.size())")
        print("deadCardDeck\(deadCardDeck.size())")
        print("computerCardsInHand\(computerCardsInHand.size())")

        print("TOTAL: \(stackDeck.size()+mainDeck.size()+playerDeck.size()+playerCardsInHand.size()+computerDeck.size()+deadCardDeck.size()+computerCardsInHand.size())")
        
    }
}
