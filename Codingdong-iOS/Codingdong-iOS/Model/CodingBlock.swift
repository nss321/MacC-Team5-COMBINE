//
//  Codingblock.swift
//  Codingdong-iOS
//
//  Created by Joy on 10/21/23.

import UIKit

struct CodingBlock {
    var value: String
    var isShowing: Bool
    var bgColor: UIColor
    var isAccessible: Bool
}

var answerBlocks: [CodingBlock] = [
    CodingBlock(value: "If you", isShowing: false, bgColor: .secondary1, isAccessible: true),
    CodingBlock(value: "give me the rice cake", isShowing: false, bgColor: .secondary2, isAccessible: true),
    CodingBlock(value: "I won't eat you.", isShowing: false, bgColor: .secondary2, isAccessible: true),
    CodingBlock(value: "If else", isShowing: false, bgColor: .secondary1, isAccessible: true),
    CodingBlock(value: "I'll eat you.", isShowing: false, bgColor: .secondary2, isAccessible: true)
]

var selectBlocks: [CodingBlock] = [
    CodingBlock(value: "I'll eat you.", isShowing: true, bgColor: .secondary2, isAccessible: true),
    CodingBlock(value: "If else", isShowing: true, bgColor: .secondary1, isAccessible: true),
    CodingBlock(value: "I won't eat you.", isShowing: true, bgColor: .secondary2, isAccessible: true),
    CodingBlock(value: "If you", isShowing: true, bgColor: .secondary1, isAccessible: true),
    CodingBlock(value: "give me the rice cake", isShowing: true, bgColor: .secondary2, isAccessible: true)
]
