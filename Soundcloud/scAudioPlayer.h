//
//  scAudioPlayer.h
//  Soundcloud
//
//  Created by Nicholas Krut on 8/22/13.
//  Copyright (c) 2013 sc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface scAudioPlayer : UIResponder
{
    AVAudioPlayer *player;
    NSTimer *playerTimer;
    int lastPlayedIndex;
}

@property (nonatomic, retain) NSArray *tracks;
@property (nonatomic, assign) int playingTrackId;
@property (nonatomic, assign) BOOL isPlaying;

+ (scAudioPlayer*) GetSingleton;

- (CGFloat)currentCompletePercentage;
- (void)startTimer;
- (void)stopTimer;
- (void)playTrack:(int)trackIndex;
- (void)playPause;
- (void)stop;
- (void)nextTrack;
- (void)lastTrack;

@end
