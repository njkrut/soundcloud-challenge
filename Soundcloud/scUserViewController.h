//
//  scUserViewController.h
//  Soundcloud
//
//  Created by Nicholas Krut on 8/22/13.
//  Copyright (c) 2013 sc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class scAudioPlayer;

@interface scUserViewController : UITableViewController <UIActionSheetDelegate>
{
    scAudioPlayer *player;
}

@property (nonatomic, retain) NSMutableDictionary *user;
@property (nonatomic, retain) NSMutableArray *tracks;

@end
