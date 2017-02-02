//
//  LinedPaperTextView.swift
//  DailyDiary
//
//  Created by redBred LLC on 2/1/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

// Adapted from https://github.com/danielamitay/DALinedTextView

class LinedPaperTextView: UITextView {

    override func draw(_ rect: CGRect) {
        // Drawing code
        
        guard let context = UIGraphicsGetCurrentContext(), let font = self.font else { return }
        
        let lineWidth = 1.0 / UIScreen.main.scale
        context.setLineWidth(lineWidth)
        
        let offset = textContainerInset.top + font.descender + 2
        
        context.beginPath()
        context.setStrokeColor(UIColor.lightGray.cgColor)
        
        let numberOfLines = Int(self.bounds.height / font.lineHeight)
        
        for line in 1...numberOfLines {
            
            let lineY = offset + CGFloat(line*Int(font.lineHeight))
            
            context.move(to: CGPoint(x: bounds.origin.x, y: lineY))
            context.addLine(to: CGPoint(x: bounds.size.width, y: lineY))
        }
        
        context.closePath()
        context.strokePath()
    }

}
