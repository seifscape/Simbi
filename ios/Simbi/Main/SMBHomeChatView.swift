//
//  SMBHomeChatView.swift
//  Simbi
//
//  Created by flynn on 9/22/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


let kNumChatBalls = 5


struct SMBChatBallPositions {
    let chatBallView: SMBChatBallView
    let shownPosition: CGPoint
    let hiddenPosition: CGPoint
}


class SMBHomeChatView: UIView, SMBChatBallDelegate {
    
    let chatBallViews: [SMBChatBallPositions]
    
    required init?(coder aDecoder: NSCoder) { fatalError("Init with NSCoder is not supported") }
    
    override init(frame: CGRect) {
        
        // Create ChatBallViews with shown and hidden positions
        
        let size: CGFloat = 66
        let pad:  CGFloat = 88
        
        chatBallViews = [
            // Bottom left
            SMBChatBallPositions(chatBallView: SMBChatBallView(frame: CGRectMake(0, 0, size, size)),
                shownPosition:  CGPointMake(  frame.width/5, frame.height-pad),
                hiddenPosition: CGPointMake(  frame.width/6, frame.height+pad) ),
            // Bottom right
            SMBChatBallPositions(chatBallView: SMBChatBallView(frame: CGRectMake(0, 0, size, size)),
                shownPosition:  CGPointMake(  frame.width/2, frame.height-pad+22),
                hiddenPosition: CGPointMake(  frame.width/2, frame.height+pad+22) ),
            // Bottom center
            SMBChatBallPositions(chatBallView: SMBChatBallView(frame: CGRectMake(0, 0, size, size)),
                shownPosition:  CGPointMake(4*frame.width/5, frame.height-pad),
                hiddenPosition: CGPointMake(5*frame.width/6, frame.height+pad) ),
            // Top left
            SMBChatBallPositions(chatBallView: SMBChatBallView(frame: CGRectMake(0, 0, size, size)),
                shownPosition:  CGPointMake(  frame.width/3,  pad),
                hiddenPosition: CGPointMake(  frame.width/4, -pad) ),
            // Top right
            SMBChatBallPositions(chatBallView: SMBChatBallView(frame: CGRectMake(0, 0, size, size)),
                shownPosition:  CGPointMake(2*frame.width/3,  pad),
                hiddenPosition: CGPointMake(3*frame.width/4, -pad) )
        ]
        
        // Initialize and add to view
        
        super.init(frame: frame)
        
        for chatBallPosition in chatBallViews {
            chatBallPosition.chatBallView.center = chatBallPosition.shownPosition
            chatBallPosition.chatBallView.delegate = self
            self.addSubview(chatBallPosition.chatBallView)
        }
    }
    
    
    // MARK: - SMBChatBallDelegate
    
    func chatBallShouldShow(chatBall: SMBChatBallView) {
        
        
    }
    
    
    func chatBallShouldHide(chatBall: SMBChatBallView) {
        
    }
    
    
    func chatBallDidSelect(chatBall: SMBChatBallView) {
        
    }
}
