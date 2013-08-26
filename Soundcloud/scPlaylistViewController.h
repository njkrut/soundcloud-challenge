//
//  scPlaylistViewController.h
//  Soundcloud
//
//  Created by Nicholas Krut on 8/25/13.
//  Copyright (c) 2013 sc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class scAudioPlayer;

@interface scPlaylistViewController : UITableViewController <UIActionSheetDelegate>
{
    scAudioPlayer *player;
}

@property (nonatomic, retain) NSMutableDictionary *playlist;
@property (nonatomic, retain) NSMutableArray *tracks;

@end
