//
//  MemorizeApp.swift
//  Memorize
//
//  Created by CareyWYR on 2022/10/9.
//

import SwiftUI

@main
struct MemorizeApp: App {
    private let game = EmojiMemoryGame()
    var body: some Scene {
        WindowGroup {
            EmojiMemoryGameView(game : game)
        }
    }
}
