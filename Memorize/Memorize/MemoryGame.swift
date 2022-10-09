//
//  MemoryGame.swift
//  Memorize
//
//  Created by CareyWYR on 2022/10/9.
//

import Foundation

struct MemoryGame<CardContent> where CardContent: Equatable{
    private(set) var cards: Array<Card>
    
    private var indexOfTheOneAndOnlyFaceUpCard: Int? {
        get { cards.indices.filter({cards[$0].isFaceUp}).oneAndOnly }
        set { cards.indices.forEach { cards[$0].isFaceUp = ($0 == newValue) } }
    }
    
    mutating func choose(_ card: Card) {
        if let chooseIndex = cards.firstIndex(where: {$0.id == card.id}), !cards[chooseIndex].isFaceUp, !cards[chooseIndex].isMatched  {
            if let potentialMatchedIndex = indexOfTheOneAndOnlyFaceUpCard {
                if cards[chooseIndex].content == cards[potentialMatchedIndex].content {
                    cards[chooseIndex].isMatched = true
                    cards[potentialMatchedIndex].isMatched = true
                }
                cards[chooseIndex].isFaceUp = true
            } else {
                indexOfTheOneAndOnlyFaceUpCard = chooseIndex
            }
        }
        print("\(cards)")
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }
    
    func index(of card: Card) -> Int? {
        for index in 0..<cards.count {
            if card.id == cards[index].id {
                return index
            }
        }
        return nil
    }
    
    init(numberOfPairsOfCards: Int, createCardContent: (Int) -> CardContent) {
        cards = []
        // add numberOfPairsOfCards * 2 cards to card Array
        for pairIndex in 0..<numberOfPairsOfCards {
            let content = createCardContent(pairIndex)
            cards.append(Card(content: content, id: pairIndex * 2))
            cards.append(Card(content: content,  id:pairIndex * 2 + 1))
        }
        shuffle()
    }
    
    
    struct Card: Identifiable {
        
        var isFaceUp = false {
            didSet {
                if isFaceUp {
                    startUsingBonusTime()
                } else {
                    stopUsingBonusTime()
                }
            }
        }
        var isMatched = false {
            didSet {
                stopUsingBonusTime()
            }
        }
        let content: CardContent
        
        let id: Int
        
        // MARK: - Bonus Time
        // this could give matching bonus points
        // if the user matches the card
        // before a certaion amount of time passes during which the card is faceup
        
        // can be zero which means "no bouns available" for this card
        var bonusTimeLimit: TimeInterval = 6
        
        // how long this card has ever been face up
        private var faceUpTime: TimeInterval {
            if let lastFaceUpDate = self.lastFaceUpDate {
                return pastFaceUpTime + Date().timeIntervalSince(lastFaceUpDate)
            } else {
                return pastFaceUpTime
            }
        }
        
        // the last time this card was turned face up (and is still face up)
        var lastFaceUpDate: Date?
        
        // the accumulated time this card has been face up in the past
        // (i.e. not including the current time it's been face up if it is currently so)
        var pastFaceUpTime: TimeInterval = 0;
        
        // how much time left before the bonus opportunity runs out
        var bonusTimeRemaing: TimeInterval {
            max(0, bonusTimeLimit - faceUpTime)
        }
        
        // percentage of the bonus time remaining
        var bonusRemaining: Double {
            (bonusTimeLimit > 0 && bonusTimeRemaing > 0) ? bonusTimeRemaing / bonusTimeLimit : 0
        }
        
        // whether the card was matched during the bonus time period
        var hasEarnedBonus: Bool {
            isMatched && bonusTimeRemaing > 0
        }
        
        // whether we are currently face up, unmatched and have not yet used up the bonus window
        var isConsumingBonusTime: Bool {
            isFaceUp && !isMatched && bonusTimeRemaing > 0
        }
        
        // called when the card transitions to face up state
        private mutating func startUsingBonusTime() {
            if isConsumingBonusTime, lastFaceUpDate == nil {
                lastFaceUpDate = Date()
            }
        }
        
        // called when the card goes back face down (or gets matched)
        private mutating func stopUsingBonusTime() {
            pastFaceUpTime = faceUpTime
            self.lastFaceUpDate = nil
        }
        
        
        
    }
}


extension Array {
    var oneAndOnly: Element? {
        if count == 1 {
            return first
        } else {
            return nil
        }
    }
}
