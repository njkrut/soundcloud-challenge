//
//  scAudioPlayer.m
//  Soundcloud
//
//  Created by Nicholas Krut on 8/22/13.
//  Copyright (c) 2013 sc. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "scAudioPlayer.h"
#import "SCUI.h"

@implementation scAudioPlayer

@synthesize tracks, playingTrackId, isPlaying;

+ (scAudioPlayer*) GetSingleton
{
    static scAudioPlayer *shared = nil;
    static dispatch_once_t done = 0;
    dispatch_once(&done, ^{
        shared = [[scAudioPlayer alloc] init];
    });
    return shared;
}

- (id)init
{
    self = [super init];
    lastPlayedIndex = -1;

    [self startTimer];
    
    return self;
}

- (void)playerAdjust:(id)sender
{
    if (lastPlayedIndex == -1)
        return;
    
    NSDictionary *cellData   = [tracks objectAtIndex:lastPlayedIndex];
    
    isPlaying      = player.isPlaying;
    playingTrackId = [[cellData valueForKey:@"id"] intValue];
    
    NSURL *UserImageUrl     = [NSURL URLWithString:[[cellData valueForKey:@"user"] valueForKey:@"avatar_url"]];
    NSData *data            = [NSData dataWithContentsOfURL:UserImageUrl];
    NSDictionary *mediaInfo = @{MPMediaItemPropertyAlbumTitle : [cellData valueForKey:@"title"],
                                MPMediaItemPropertyArtist : [[cellData valueForKey:@"user"] valueForKey:@"username"],
                                MPMediaItemPropertyArtwork : [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageWithData:data]],
                                MPNowPlayingInfoPropertyElapsedPlaybackTime : [NSNumber numberWithInt:player.currentTime],
                                MPMediaItemPropertyPlaybackDuration         : [NSNumber numberWithFloat:([[cellData valueForKey:@"duration"] floatValue] / 1000)]};
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
    
    if ((player.currentTime + .5) >= ([[cellData valueForKey:@"duration"] floatValue] / 1000))
        [self nextTrack];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TrackChanged" object:[cellData valueForKey:@"id"]];
}

- (CGFloat)currentCompletePercentage
{
    NSDictionary *cellData   = [tracks objectAtIndex:lastPlayedIndex];
    float percentageComplete = (player.currentTime / ([[cellData valueForKey:@"duration"] floatValue] / 1000));
    return percentageComplete;
}

- (void)startTimer
{
    playerTimer     = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                       target:self
                                                     selector:@selector(playerAdjust:)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)stopTimer
{
    [playerTimer invalidate];
}

- (void)playTrack:(int)trackIndex;
{
    [self stopTimer];
    NSDictionary *cellData = [tracks objectAtIndex:trackIndex];
    
    if (playingTrackId == [[cellData valueForKey:@"id"] intValue])
    {
        [self playPause];
        
        return;
    } else {
        [player stop];
    }
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:[cellData valueForKey:@"stream_url"]]
             usingParameters:nil
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                 NSError *playerError;
                 player = [[AVAudioPlayer alloc] initWithData:data error:&playerError];
                 [player prepareToPlay];
                 [self playPause];
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"NewTrack" object:[cellData valueForKey:@"id"]];
                 [self performSelector:@selector(startTimer) withObject:nil afterDelay:1.0f];
             }];
    
    lastPlayedIndex = trackIndex;
}

- (void)playPause
{
    if (player)
    {
        if (player.isPlaying)
            [player pause];
        else
            [player play];
    } else {
        [self playTrack:0];
    }
}

- (void)stop
{
    [player stop];
}

- (void)nextTrack
{
    if (lastPlayedIndex + 1 > tracks.count - 1)
    {
        [self playTrack:0];
    } else {
        [self playTrack:(lastPlayedIndex+1)];
    }
}

- (void)lastTrack
{
    if (lastPlayedIndex - 1 < 0)
    {
        [self playTrack:(tracks.count - 1)];
    } else {
        [self playTrack:(lastPlayedIndex-1)];
    }
}


@end
