//
//  Protocol.h
//  Gavitarium2
//
//  Created by Robert Neagu on 5/30/11.
//  Copyright 2011 TotalSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Protocols

@protocol ModalViewDelegate <NSObject>

-(void) closeModalWindow;

@end

@protocol NetworkSendDelegate <NSObject>

-(void) sendAction:(int) action Argument: (int) arg PosX: (float) px PosY: (float) py Reliable: (bool) reliable;

@end

@protocol NetworkReceiveDelegate <NSObject>

-(void) receivedAction;

@end

#pragma mark - Constants

//Network communication

#define G2_TOUCH_ADD        1
#define G2_TOUCH_MOVE       2
#define G2_TOUCH_DELETE     3
#define G2_LIKE             4
#define G2_COLOR_SYNC       5
#define G2_PAUSE            6
#define G2_RESUME           7
#define G2_PLAY_TRACK       8
#define G2_STOP_TRACK       9
#define G2_PART_COUNT       10
#define G2_PART_SIZE        11
#define G2_PART_TAIL        12
#define G2_PART_SPEED       13
#define G2_COLOR_RED        14
#define G2_COLOR_GREEN      15
#define G2_COLOR_BLUE       16
#define G2_COLOR_ALPHA      17
#define G2_COLOR_CYCLE      18
#define G2_REPEAT_TRACK     19
#define G2_PREVENT_SLEEP    20
#define G2_SCREEN_SHOT      21
#define G2_SCREEN_CLEAR     22
#define G2_RESOLUTION       23