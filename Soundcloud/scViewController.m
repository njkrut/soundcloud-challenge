//
//  scViewController.m
//  Soundcloud
//
//  Created by Nicholas Krut on 8/20/13.
//  Copyright (c) 2013 sc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MBProgressHUD.h>
#import <MediaPlayer/MediaPlayer.h>
#import <OHAttributedLabel.h>
#import <OHASBasicHTMLParser.h>
#import <QuartzCore/QuartzCore.h>

#import "scAppDelegate.h"
#import "scViewController.h"
#import "scAudioCell.h"
#import "scAudioPlayer.h"
#import "scNotConnectedViewController.h"
#import "scPlaylistCell.h"
#import "scPlaylistViewController.h"
#import "SCUI.h"
#import "scUserCell.h"
#import "scUserViewController.h"
#import "UIImageView+Cached.h"

static const int kPlayTrackActionSheet    = 1000;
static const int kViewArtistActionSheet   = 1001;
static const int kViewPlaylistActionSheet = 1002;

@interface scViewController ()

@end

@implementation scViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [playerControls.layer setCornerRadius:15.0f];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    SCAccount *account = [SCSoundCloud account];
    if (account == nil)
    {
        scNotConnectedViewController *vc = [[scNotConnectedViewController alloc] initWithNibName:([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)?@"scNotConnectedViewController_iPhone":@"scNotConnectedViewController_iPad" bundle:[NSBundle mainBundle]];
        [self presentViewController:vc animated:NO completion:nil];
    } else {
        [self segmentChanged:typeControl];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkPlayer:) name:@"TrackChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newTrackPlaying:) name:@"NewTrack" object:nil];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TrackChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NewTrack" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
    @try {
        SCAccount *account = [SCSoundCloud account];
        if (account == nil) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Not Logged In"
                                  message:@"You must login first"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES].dimBackground = YES;
        
        SCRequestResponseHandler handler;
        handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
            NSError *jsonError = nil;
            NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                                 JSONObjectWithData:data
                                                 options:0
                                                 error:&jsonError];
            if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
                if ([[sender titleForSegmentAtIndex:[sender selectedSegmentIndex]] isEqualToString:@"Favorites"])
                {
                    trackResults = [(NSArray *)jsonResponse mutableCopy];
                } else if ([[sender titleForSegmentAtIndex:[sender selectedSegmentIndex]] isEqualToString:@"Followings"])
                    followingResults = [jsonResponse mutableCopy];
                else if ([[sender titleForSegmentAtIndex:[sender selectedSegmentIndex]] isEqualToString:@"Playlists"])
                    playlistResults  = [jsonResponse mutableCopy];
            } else {
                if ([[sender titleForSegmentAtIndex:[sender selectedSegmentIndex]] isEqualToString:@"Favorites"])
                {
                    trackResults = nil;
                } else if ([[sender titleForSegmentAtIndex:[sender selectedSegmentIndex]] isEqualToString:@"Followings"])
                    followingResults = nil;
                else if ([[sender titleForSegmentAtIndex:[sender selectedSegmentIndex]] isEqualToString:@"Playlists"])
                    playlistResults  = nil;
            }
            
            [tableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        };
        
        NSString *resourceURL = [NSString stringWithFormat:@"https://api.soundcloud.com/me/%@.json", [[sender titleForSegmentAtIndex:sender.selectedSegmentIndex] lowercaseString]];
        [SCRequest performMethod:SCRequestMethodGET
                      onResource:[NSURL URLWithString:resourceURL]
                 usingParameters:nil
                     withAccount:account
          sendingProgressHandler:nil
                 responseHandler:handler];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }

}

- (void)checkPlayer:(NSNotification *)notification
{
    int trackIndex = 0;
    for (NSDictionary *track in trackResults)
    {
        if ([[[track valueForKey:@"id"] stringValue] isEqualToString:[notification.object stringValue]])
        {
            break;
        }
        trackIndex++;
    }
            
    scAudioCell *cell = (scAudioCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:trackIndex inSection:0]];
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
    for (NSDictionary *track in trackResults)
    {
        if ([[[track valueForKey:@"id"] stringValue] isEqualToString:[NSString stringWithFormat:@"%i", player.playingTrackId]])
        {
            break;
        }
        trackIndex++;
    }
    
    scAudioCell *cell = (scAudioCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:trackIndex inSection:0]];
    if ([cell isKindOfClass:[scAudioCell class]])
    {
        [UIView animateWithDuration:.25f animations:^{
            [[cell playingIndicator] setFrame:CGRectMake(0.0f, 0.0f, 0.0f, cell.frame.size.height)];
        }];
    }
    
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
}

# pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[typeControl titleForSegmentAtIndex:[typeControl selectedSegmentIndex]] isEqualToString:@"Favorites"])
        return [trackResults count];
    else if ([[typeControl titleForSegmentAtIndex:[typeControl selectedSegmentIndex]] isEqualToString:@"Followings"])
        return [followingResults count];
    else if ([[typeControl titleForSegmentAtIndex:[typeControl selectedSegmentIndex]] isEqualToString:@"Playlists"])
        return [playlistResults count];
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellData;
    if ([[typeControl titleForSegmentAtIndex:[typeControl selectedSegmentIndex]] isEqualToString:@"Favorites"])
        cellData = [trackResults objectAtIndex:indexPath.row];
    else if ([[typeControl titleForSegmentAtIndex:[typeControl selectedSegmentIndex]] isEqualToString:@"Followings"])
        cellData = [followingResults objectAtIndex:indexPath.row];
    else if ([[typeControl titleForSegmentAtIndex:[typeControl selectedSegmentIndex]] isEqualToString:@"Playlists"])
        cellData = [playlistResults objectAtIndex:indexPath.row];
    
    if (!cellData)
        return nil;
    
    NSString *cellIdentifier;
    if ([[cellData valueForKey:@"kind"] isEqualToString:@"track"])
        cellIdentifier = @"AudioCell";
    else if ([[cellData valueForKey:@"kind"] isEqualToString:@"user"])
        cellIdentifier = @"UserCell";
    else
        cellIdentifier = @"PlaylistCell";
    
    
    UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        if ([cellIdentifier isEqualToString:@"AudioCell"])
            cell = (scAudioCell *)[[[NSBundle mainBundle] loadNibNamed:@"scAudioCell" owner:self options:nil] objectAtIndex:0];
        else if ([cellIdentifier isEqualToString:@"UserCell"])
            cell = (scUserCell *)[[[NSBundle mainBundle] loadNibNamed:@"scUserCell" owner:self options:nil] objectAtIndex:0];
        else if ([cellIdentifier isEqualToString:@"PlaylistCell"])
            cell = (scPlaylistCell *)[[[NSBundle mainBundle] loadNibNamed:@"scPlaylistCell" owner:self options:nil] objectAtIndex:0];
    }
    
    if ([cellIdentifier isEqualToString:@"AudioCell"])
    {
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
    } else if ([cellIdentifier isEqualToString:@"UserCell"]) {
        // Load the user image
        NSURL *UserImageUrl = [NSURL URLWithString:[cellData valueForKey:@"avatar_url"]];
        NSData *data = [NSData dataWithContentsOfURL:UserImageUrl];
        [[(scUserCell *)cell userImage] setImage:[UIImage imageWithData:data]];
        [[(scUserCell *)cell userImage].layer setCornerRadius:5.0f];
        [[(scUserCell *)cell userImage].layer setBorderColor:[UIColor blackColor].CGColor];
        [[(scUserCell *)cell userImage].layer setBorderWidth:2.0f];
        [[(scUserCell *)cell userImage].layer setMasksToBounds:YES];
        
        // Username
        [[(scUserCell *)cell userName] setText:[cellData valueForKey:@"username"]];
        
        // User details
        NSString *userDetails = @"";
        if ([cellData valueForKey:@"city"])
            userDetails = [userDetails stringByAppendingFormat:@"%@, ", [cellData valueForKey:@"city"]];
        if ([cellData valueForKey:@"country"])
            userDetails = [userDetails stringByAppendingFormat:@"%@\n", [cellData valueForKey:@"country"]];
        if ([cellData valueForKey:@"followers_count"])
            userDetails = [userDetails stringByAppendingFormat:@"Followers: %@", [cellData valueForKey:@"followers_count"]];
        if ([cellData valueForKey:@"followings_count"])
            userDetails = [userDetails stringByAppendingFormat:@" Following: %@", [cellData valueForKey:@"followings_count"]];
        if ([cellData valueForKey:@"track_count"])
            userDetails = [userDetails stringByAppendingFormat:@" Tracks: %@", [cellData valueForKey:@"track_count"]];
        [[(scUserCell *)cell userDetails] setText:userDetails];
    } else if ([cellIdentifier isEqualToString:@"PlaylistCell"]) {
        // Load the user image
        NSURL *UserImageUrl = [NSURL URLWithString:[[cellData objectForKey:@"user"] valueForKey:@"avatar_url"]];
        NSData *data = [NSData dataWithContentsOfURL:UserImageUrl];
        [[(scPlaylistCell *)cell playlistImage] setImage:[UIImage imageWithData:data]];
        [[(scPlaylistCell *)cell playlistImage].layer setCornerRadius:5.0f];
        [[(scPlaylistCell *)cell playlistImage].layer setBorderColor:[UIColor blackColor].CGColor];
        [[(scPlaylistCell *)cell playlistImage].layer setBorderWidth:2.0f];
        [[(scPlaylistCell *)cell playlistImage].layer setMasksToBounds:YES];
        
        // Title
        [[(scPlaylistCell *)cell playlistName] setText:[cellData valueForKey:@"title"]];
        
        // Description
        [[(scPlaylistCell *)cell playlistDetails] setText:[NSString stringWithFormat:@"A user created playlist containing %@ track(s).", [cellData valueForKey:@"track_count"]]];
        
        // Convert the created_at to a NSDate
        NSDateFormatter* dtFormatter = [[NSDateFormatter alloc] init];
        [dtFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZZZ"];
        NSDate *uploadDate = [dtFormatter dateFromString:[cellData valueForKey:@"created_at"]];
        [dtFormatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
        [[(scPlaylistCell *)cell playlistCreation] setText:[NSString stringWithFormat:@"Created: %@", [dtFormatter stringFromDate:uploadDate]]];
    }
    
    [cell prepareForReuse];
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (player && ![trackResults isEqual:[player tracks]])
        [player setTracks:trackResults];
    
    if ([[[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier] isEqualToString:@"AudioCell"])
    {
        if (!player)
        {
            UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"How would you like to play this track?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"In-app", @"Soundcloud App", nil];
            [ac setTag:kPlayTrackActionSheet];
            [ac showInView:self.view];
        } else {
            [player playTrack:indexPath.row];
            
            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            [(scAppDelegate *)[[UIApplication sharedApplication] delegate] becomeFirstResponder];
        }
    } else if ([[[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier] isEqualToString:@"UserCell"]) {
        [self getUserAndShowDetails:indexPath.row];
    } else if ([[[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier] isEqualToString:@"PlaylistCell"]) {
        [self getPlaylistAndShowDetails:indexPath.row];
    }
}

# pragma UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kPlayTrackActionSheet)
    {
        if (buttonIndex == 0)
        {
            [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES].dimBackground = YES;
            player = [scAudioPlayer GetSingleton];
            [player setTracks:trackResults];
            [player playTrack:[tableView indexPathForSelectedRow].row];
            [playerControls removeFromSuperview];
            [self.navigationController.view addSubview:playerControls];
            if (playerControls.frame.origin.y > (self.view.frame.size.height - 20.0f))
            {
                [UIView animateWithDuration:.5f animations:^{
                    [playerControls setFrame:CGRectMake(playerControls.frame.origin.x, self.view.frame.size.height - 20.0f, playerControls.frame.size.width, playerControls.frame.size.height)];
                    [pausePlayButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
                }];
            }
            
            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            [(scAppDelegate *)[[UIApplication sharedApplication] delegate] becomeFirstResponder];
        } else if (buttonIndex == 1) {
            NSDictionary *currentTrack = [trackResults objectAtIndex:[tableView indexPathForSelectedRow].row];
            NSURL *soundcloudAppUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"soundcloud://tracks:%i", [[currentTrack valueForKey:@"id"] intValue]]];
            
            if ([[UIApplication sharedApplication] canOpenURL:soundcloudAppUrl])
            {
                [[UIApplication sharedApplication] openURL:soundcloudAppUrl];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[currentTrack valueForKey:@"permalink_url"]]];
            }
        }
    }
}

# pragma mark -

- (void)getUserAndShowDetails:(int)row
{
    NSDictionary *cellData = [followingResults objectAtIndex:row];
    SCAccount *account = [SCSoundCloud account];
    if (account == nil) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Not Logged In"
                              message:@"You must login first"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].dimBackground = YES;
    
    SCRequestResponseHandler handler;
    handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                             JSONObjectWithData:data
                                             options:0
                                             error:&jsonError];
        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
            scUserViewController *vc = [[scUserViewController alloc] initWithNibName:@"scUserViewController" bundle:[NSBundle mainBundle]];
            [vc setTracks:[jsonResponse mutableCopy]];
            [vc setUser:[cellData mutableCopy]];
            [vc.tableView reloadData];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    };
    
    NSString *resourceURL = [NSString stringWithFormat:@"https://api.soundcloud.com/users/%@/tracks.json", [cellData valueForKey:@"id"]];
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:handler];
}

- (void)getPlaylistAndShowDetails:(int)row
{
    NSDictionary *cellData = [playlistResults objectAtIndex:row];
    
    scPlaylistViewController *vc = [[scPlaylistViewController alloc] initWithNibName:@"scPlaylistViewController" bundle:[NSBundle mainBundle]];
    [vc setTracks:[[cellData objectForKey:@"tracks"] mutableCopy]];
    [vc setPlaylist:[cellData mutableCopy]];
    [[vc tableView] reloadData];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)pausePlay:(id)sender
{
    if (player)
    {
        [player playPause];
        if (player.isPlaying)
            [pausePlayButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        else
            [pausePlayButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)lastTrack:(id)sender
{
    int trackIndex = 0;
    for (NSDictionary *track in trackResults)
    {
        if ([[[track valueForKey:@"id"] stringValue] isEqualToString:[NSString stringWithFormat:@"%i", player.playingTrackId]])
        {
            break;
        }
        trackIndex++;
    }
    
    if (player)
        [player lastTrack];
    
    scAudioCell *cell = (scAudioCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:trackIndex inSection:0]];
    if ([cell isKindOfClass:[scAudioCell class]])
    {
        [UIView animateWithDuration:.25f animations:^{
            [[cell playingIndicator] setFrame:CGRectMake(0.0f, 0.0f, 0, cell.frame.size.height)];
        }];
    }

}

- (IBAction)nextTrack:(id)sender
{
    int trackIndex = 0;
    for (NSDictionary *track in trackResults)
    {
        if ([[[track valueForKey:@"id"] stringValue] isEqualToString:[NSString stringWithFormat:@"%i", player.playingTrackId]])
        {
            break;
        }
        trackIndex++;
    }
    
    if (player)
        [player nextTrack];
    
    scAudioCell *cell = (scAudioCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:trackIndex inSection:0]];
    if ([cell isKindOfClass:[scAudioCell class]])
    {
        [UIView animateWithDuration:.25f animations:^{
            [[cell playingIndicator] setFrame:CGRectMake(0.0f, 0.0f, 0, cell.frame.size.height)];
        }];
    }
}

- (IBAction)logout:(id)sender
{
    if (player)
    {
        [player stop];
        player = nil;
    }
    
    [SCSoundCloud removeAccess];
    SCAccount *account = [SCSoundCloud account];
    if (account == nil)
    {
        scNotConnectedViewController *vc = [[scNotConnectedViewController alloc] initWithNibName:([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)?@"scNotConnectedViewController_iPhone":@"scNotConnectedViewController_iPad" bundle:[NSBundle mainBundle]];
        [self presentViewController:vc animated:NO completion:nil];
    }
}

@end
