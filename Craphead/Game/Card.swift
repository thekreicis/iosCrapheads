

import SpriteKit

enum CardType: Int {
    case TWO = 2,
    THREE = 3,
    FOUR = 4,
    FIVE = 5,
    SIX = 6,
    SEVEN = 7,
    EIGHT = 8,
    NINE = 9,
    TEN = 10,
    JACK = 11,
    QUEEN = 12,
    KING = 13,
    ACE = 14,
    NONE = 0
}

class Card : SKSpriteNode {
    let cardType :CardType
    let frontTexture :SKTexture
    let backTexture :SKTexture
    var movable = true
    var faceUp = true
    var enlarged = false
    var savedPosition = CGPoint.zero
    var originPosition = CGPoint.zero
    
    var owner = "deck"
    private var card_suit = 0
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(cardValue: Int, suit: Int) {
        self.cardType = CardType.init(rawValue: cardValue) ?? CardType.NONE
        self.card_suit = suit
        
        backTexture = SKTexture(imageNamed: "green_back")
        
        let suitStrings:[String] = ["None", "D","S","H","C"]
        let valueStrings:[String] = ["None","","2","3","4","5","6","7","8","9","10","J","Q","K","A"]
        let name = valueStrings[cardType.rawValue]+suitStrings[suit]
        frontTexture = SKTexture(imageNamed: name)
        
        super.init(texture: frontTexture, color: .clear, size: CGSize(width: frontTexture.size().width/8,height: frontTexture.size().height/8)) //8
    }
    
    func cardSize() -> CGSize {
        return self.size
    }
    
    func name() -> String {
        let suitStrings:[String] = ["None", "D","S","H","C"]
        let valueStrings:[String] = ["None","","2","3","4","5","6","7","8","9","10","J","Q","K","A"]
        return valueStrings[self.cardType.rawValue]+suitStrings[self.card_suit]
    }
    
    func flip() {
        let firstHalfFlip = SKAction.scaleX(to: 0.0, duration: 0.4)
        let secondHalfFlip = SKAction.scaleX(to: 1.0, duration: 0.4)
        
        setScale(1.0)
        
        if faceUp {
            run(firstHalfFlip, completion: {
                self.texture = self.backTexture
                
                self.run(secondHalfFlip)
            })
        } else {
            run(firstHalfFlip, completion: {
                self.texture = self.frontTexture
                
                self.run(secondHalfFlip)
            })
        }
        faceUp = !faceUp
    }
    
    func dmg()->Int{
        return cardType.rawValue
    }
    //  func enlarge() {
    //    if enlarged {
    //      enlarged = false
    //      zPosition = CardLevel.board.rawValue
    //      position = savedPosition
    //      removeAllActions()
    //      setScale(1.0)
    //      zRotation = 0
    //    } else {
    //      enlarged = true
    //      savedPosition = position
    //      zPosition = CardLevel.enlarged.rawValue
    //
    //      if let parent = parent {
    //        position = CGPoint(x: parent.frame.midX, y: parent.frame.midY)
    //      }
    //
    //      removeAllActions()
    //      setScale(5.0)
    //      zRotation = 0
    //    }
    //  }
    
    func enlarge() {
        return
        if enlarged {
            let slide = SKAction.move(to: savedPosition, duration:0.3)
            let scaleDown = SKAction.scale(to: 1.0, duration:0.3)
            run(SKAction.group([slide, scaleDown]), completion: {
                self.enlarged = false
                self.zPosition = CardLevel.board.rawValue
            })
        } else {
            enlarged = true
            savedPosition = position
            
            
            
            zPosition = CardLevel.enlarged.rawValue
            
            if let parent = parent {
                removeAllActions()
                zRotation = 0
                let newPosition = CGPoint(x: parent.frame.midX, y: parent.frame.midY)
                let slide = SKAction.move(to: newPosition, duration:0.3)
                let scaleUp = SKAction.scale(to: 5.0, duration:0.3)
                run(SKAction.group([slide, scaleUp]))
            }
        }
    }
}

class Deck {
    init (ownersName: String){
        self.owner = ownersName
    }

    func deleteStack()  {
        for i in self.cards {
            i.removeFromParent()
        }
        self.cards.removeAll()
    }
    
    func addCard(card: Card){
        card.owner = self.owner
        self.cards.append(card)
    }
    
    func getCard() -> Card{
        return cards.popLast() ??  Card(cardValue: 0, suit: 0)
    }
    
    func empty() -> Bool {
        return cards.isEmpty
    }
    
    func size() -> Int {
        return cards.count
    }
    
    func getOwner() -> String {
        return self.owner
    }
    
    func shuffle(){
        self.cards.shuffle()
    }
    func getCardRef() -> Card {
        return cards.last ?? Card(cardValue: 0, suit: 0)
    }
    
    var cards = [Card]()
    
    private var owner = ""
}



class Rules {
    
    func isSuperCard(card: Card)->Bool {
        if (card.dmg() == TWO ||
            card.dmg() == THREE ||
            card.dmg() == TEN ||
            card.dmg() == SEVEN ){
            return true;
            
        }
        return false
    }
    
    func putOnTable(player_card: Card, on_top_card: Card) ->Bool
    {
        print("PLY DMG: \(player_card.dmg()) vs TOP_CARD DMG \(on_top_card.dmg())")
        
        let player_has_super_card = isSuperCard(card: player_card);
        if(player_has_super_card == true){
            return true
        }
                
        if(on_top_card.dmg() == TWO){
            return true
        }

        
        if(on_top_card.dmg() == SEVEN){
            if(player_has_super_card || (player_card.dmg() <= 7 && player_card.dmg() > 0) ){
                return true
            }
            return false
        }

        
        if(player_card.dmg() >= on_top_card.dmg()){
            return true
        }
        return false
    }
    
    let NONE = 0
    let TWO = 2
    let THREE = 3
    let FOUR = 4
    let FIVE = 5
    let SIX = 6
    let SEVEN = 7
    let EIGHT = 8
    let NINE = 9
    let TEN = 10
    let JACK = 11
    let QUEEN = 12
    let KING = 13
    let ACE = 14
}

