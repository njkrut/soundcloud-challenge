//
//  scPlaylistCell.h
//  Soundcloud
//
//  Created by Nicholas Krut on 8/21/13.
//  Copyright (c) 2013 sc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface scPlaylistCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *playlistImage;
@property (nonatomic, retain) IBOutlet IBOutlet UILabel *playlistName;
@property (nonatomic, retain) IBOutlet IBOutlet UILabel *playlistDetails;
@property (nonatomic, retain) IBOutlet IBOutlet UILabel *playlistCreation;


@end
