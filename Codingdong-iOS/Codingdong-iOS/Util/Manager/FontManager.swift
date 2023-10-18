//
//  FontManager.swift
//  Codingdong-iOS
//
//  Created by BAE on 2023/10/18.
//


import UIKit

/// AX1 가이드라인 준수
enum FontSize: CGFloat {
    
    case largetitle = 44
    case title1 = 38
    case title2 = 34
    case title3 = 31
    // enum rawValue 중첩 불가 이슈로 주석 처리
    //    case headline = 28
    case body = 28
    case callout = 26
    case subhead = 25
    case footnote = 23
    case caption1 = 22
    case caption2 = 20
    
}

/// Pretendard Static Fonts
enum PretendardType: String {
    
    case black = "Pretendard-Black"
    case bold = "Pretendard-Bold"
    case extrabold = "Pretendard-ExtraBold"
    case extralight = "Pretendard-ExtraLight"
    case light = "Pretendard-Light"
    case medium = "Pretendard-Medium"
    case regular = "Pretendard-Regular"
    case semibold = "Pretendard-SemiBold"
    case thin = "Pretendard-Thin"
    
}

/// Pretendard Only
struct FontManager {
    
    static let shared = FontManager()
    
    /// type - pretendard type
    /// size - AX1 font size.
    /// HeadLine 사용시 body 선택 후 semibold 적용시켜야함.
    func pretendard(_ type: PretendardType, _ size: FontSize) -> UIFont! {
        return UIFont(name: type.rawValue, size: size.rawValue)
    }
    
}



