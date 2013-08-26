//
//  scViewController.h
//  Soundcloud
//
//  Created by Nicholas Krut on 8/20/13.
//  Copyright (c) 2013 sc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class scAudioPlayer;

@interface scViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, UIActionSheetDelegate>
{
    __strong NSMutableArray *trackResults;
    __strong NSMutableArray *followingResults;
    __strong NSMutableArray *playlistResults;
    
    __weak IBOutlet UISegmentedControl *typeControl;
    __weak IBOutlet UITableView *tableView;
    __weak IBOutlet UIView *playerControls;
    __weak IBOutlet UIButton *pausePlayButton;

    scAudioPlayer *player;
}

- (IBAction)segmentChanged:(id)sender;
- (IBAction)pausePlay:(id)sender;
- (IBAction)lastTrack:(id)sender;
- (IBAction)nextTrack:(id)sender;
- (IBAction)logout:(id)sender;

@end
