//
//  scAudioCellCell.h
//  Soundcloud
//
//  Created by Nicholas Krut on 8/20/13.
//  Copyright (c) 2013 sc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OHAttributedLabel.h>

@interface scAudioCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UIImageView *userImage;
@property (nonatomic, retain) IBOutlet UIImageView *waveformImage;

@property (nonatomic, retain) IBOutlet UIView *playingIndicator;

@property (nonatomic, retain) IBOutlet UILabel *trackTitle;
@property (nonatomic, retain) IBOutlet UILabel *uploadTime;
@property (nonatomic, retain) IBOutlet OHAttributedLabel *trackLengthAndArtist;

@end
