//
//  scPlaylistViewController.m
//  Soundcloud
//
//  Created by Nicholas Krut on 8/25/13.
//  Copyright (c) 2013 sc. All rights reserved.
//

#import <MBProgressHUD.h>
#import <OHAttributedLabel.h>
#import <OHASBasicHTMLParser.h>
#import <QuartzCore/QuartzCore.h>

#import "scAppDelegate.h"
#import "scPlaylistViewController.h"
#import "scPlaylistCell.h"
#import "scAudioCell.h"
#import "scAudioPlayer.h"

@interface scPlaylistViewController ()

@end

@implementation scPlaylistViewController

@synthesize playlist, tracks;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkPlayer:) name:@"TrackChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newTrackPlaying:) name:@"NewTrack" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TrackChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NewTrack" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkPlayer:(NSNotification *)notification
{
    int trackIndex = 0;
    for (NSDictionary *track in tracks)
    {
        if ([[[track valueForKey:@"id"] stringValue] isEqualToString:[notification.object stringValue]])
        {
            break;
        }
        trackIndex++;
    }
    
    scAudioCell *cell = (scAudioCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(trackIndex + 1) inSection:0]];
    if ([cell isKindOfClass:[scAudioCell class]])
    {
        [UIView animateWithDuration:.25f animations:^{
            [[cell playingIndicator] setFrame:CGRectMake(0.0f, 0.0f, [player currentCompletePercentage] * cell.frame.size.width, cell.frame.size.height)];
        }];
    }
}

- (void)newTrackPlaying:(NSNotification *)notification
{
    int trackIndex = 0;
    for (NSDictionary *track in tracks)
    {
        if ([[[track valueForKey:@"id"] stringValue] isEqualToString:[NSString stringWithFormat:@"%i", player.playingTrackId]])
        {
            break;
        }
        trackIndex++;
    }
    
    scAudioCell *cell = (scAudioCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(trackIndex + 1) inSection:0]];
    if ([cell isKindOfClass:[scAudioCell class]])
    {
        [UIView animateWithDuration:.25f animations:^{
            [[cell playingIndicator] setFrame:CGRectMake(0.0f, 0.0f, 0.0f, cell.frame.size.height)];
        }];
    }
    
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [tracks count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0)
    {
        cell = (scPlaylistCell *)[[[NSBundle mainBundle] loadNibNamed:@"scPlaylistCell" owner:self options:nil] objectAtIndex:0];
    } else {
        cell = (scAudioCell *)[[[NSBundle mainBundle] loadNibNamed:@"scAudioCell" owner:self options:nil] objectAtIndex:0];
    }
    
    if ([cell.reuseIdentifier isEqualToString:@"AudioCell"])
    {
        NSDictionary *cellData = [tracks objectAtIndex:indexPath.row - 1];
        [[(scAudioCell *)cell trackTitle] setText:[cellData valueForKey:@"title"]];
        
        // Calculate the number of minutes and seconds of the track
        float minutes = (([[cellData valueForKey:@"duration"] floatValue] / 1000) / 60);
        float seconds = (minutes - (int)minutes) * 60;
        
        [[(scAudioCell *)cell trackLengthAndArtist] setAttributedText:[OHASBasicHTMLParser attributedStringByProcessingMarkupInString:[NSString stringWithFormat:@"%@ - %i:%i\n%@", [[cellData valueForKey:@"user"] valueForKey:@"username"], (int)minutes, (int)seconds, [cellData valueForKey:@"description"]]]];
        
        // Load the user image
        NSURL *UserImageUrl = [NSURL URLWithString:[[cellData valueForKey:@"user"] valueForKey:@"avatar_url"]];
        NSData *data = [NSData dataWithContentsOfURL:UserImageUrl];
        [[(scAudioCell *)cell userImage] setImage:[UIImage imageWithData:data]];
        [[(scAudioCell *)cell userImage].layer setCornerRadius:5.0f];
        [[(scAudioCell *)cell userImage].layer setBorderColor:[UIColor blackColor].CGColor];
        [[(scAudioCell *)cell userImage].layer setBorderWidth:2.0f];
        [[(scAudioCell *)cell userImage].layer setMasksToBounds:YES];
        
        // Load the waveform image
        NSURL *waveformUrl     = [NSURL URLWithString:[cellData valueForKey:@"waveform_url"]];
        NSData *waveformData   = [NSData dataWithContentsOfURL:waveformUrl];
        
        UIImage *firstImage    = [UIImage imageWithData:waveformData];
        CGRect cropRect        = CGRectMake(0.0f, 0.0f, firstImage.size.width, firstImage.size.height / 2);
        UIImage *waveformImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([firstImage CGImage], cropRect)];
        
        [[(scAudioCell *)cell waveformImage] setImage:waveformImage];
        [[(scAudioCell *)cell waveformImage] setBackgroundColor:UIColorFromRGB(0xff3300)];
        [[(scAudioCell *)cell waveformImage] setAlpha:.5f];
        //[[(scAudioCell *)cell waveformImage] setOve
        
        // Convert the created_at to a NSDate
        NSDateFormatter* dtFormatter = [[NSDateFormatter alloc] init];
        [dtFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZZZ"];
        NSDate *uploadDate = [dtFormatter dateFromString:[cellData valueForKey:@"created_at"]];
        [dtFormatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
        [[(scAudioCell *)cell uploadTime] setText:[NSString stringWithFormat:@"Uploaded: %@", [dtFormatter stringFromDate:uploadDate]]];
    } else if ([cell.reuseIdentifier isEqualToString:@"PlaylistCell"]) {
        // Load the user image
        NSURL *UserImageUrl = [NSURL URLWithString:[[playlist objectForKey:@"user"] valueForKey:@"avatar_url"]];
        NSData *data = [NSData dataWithContentsOfURL:UserImageUrl];
        [[(scPlaylistCell *)cell playlistImage] setImage:[UIImage imageWithData:data]];
        [[(scPlaylistCell *)cell playlistImage].layer setCornerRadius:5.0f];
        [[(scPlaylistCell *)cell playlistImage].layer setBorderColor:[UIColor blackColor].CGColor];
        [[(scPlaylistCell *)cell playlistImage].layer setBorderWidth:2.0f];
        [[(scPlaylistCell *)cell playlistImage].layer setMasksToBounds:YES];
        
        // Title
        [[(scPlaylistCell *)cell playlistName] setText:[playlist valueForKey:@"title"]];
        
        // Description
        [[(scPlaylistCell *)cell playlistDetails] setText:[NSString stringWithFormat:@"A user created playlist containing %@ track(s).", [playlist valueForKey:@"track_count"]]];
        
        // Convert the created_at to a NSDate
        NSDateFormatter* dtFormatter = [[NSDateFormatter alloc] init];
        [dtFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZZZ"];
        NSDate *uploadDate = [dtFormatter dateFromString:[playlist valueForKey:@"created_at"]];
        [dtFormatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
        [[(scPlaylistCell *)cell playlistCreation] setText:[NSString stringWithFormat:@"Created: %@", [dtFormatter stringFromDate:uploadDate]]];
    }
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier] isEqualToString:@"AudioCell"])
    {
        if (!player)
        {
            UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"How would you like to play this track?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"In-app", @"Soundcloud App", nil];
            [ac showInView:self.view];
        } else {
            [player playTrack:indexPath.row - 1];
            
            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            [(scAppDelegate *)[[UIApplication sharedApplication] delegate] becomeFirstResponder];
        }
    }
}

# pragma UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        player = [scAudioPlayer GetSingleton];
        [player setTracks:tracks];
        [player playTrack:([self.tableView indexPathForSelectedRow].row - 1)];
        
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [(scAppDelegate *)[[UIApplication sharedApplication] delegate] becomeFirstResponder];
    } else if (buttonIndex == 1) {
        NSDictionary *currentTrack = [tracks objectAtIndex:([self.tableView indexPathForSelectedRow].row - 1)];
        NSURL *soundcloudAppUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"soundcloud://tracks:%i", [[currentTrack valueForKey:@"id"] intValue]]];
        
        if ([[UIApplication sharedApplication] canOpenURL:soundcloudAppUrl])
        {
            [[UIApplication sharedApplication] openURL:soundcloudAppUrl];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[currentTrack valueForKey:@"permalink_url"]]];
        }
    }
}

@end
