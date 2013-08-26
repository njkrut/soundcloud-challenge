//
//  scAudioCellCell.m
//  Soundcloud
//
//  Created by Nicholas Krut on 8/20/13.
//  Copyright (c) 2013 sc. All rights reserved.
//

#import "scAudioCell.h"

@implementation scAudioCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSString *)reuseIdentifier
{
    return @"AudioCell";
}

@end
