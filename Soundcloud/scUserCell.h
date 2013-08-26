//
//  scUserCell.h
//  Soundcloud
//
//  Created by Nicholas Krut on 8/21/13.
//  Copyright (c) 2013 sc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface scUserCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *userImage;
@property (nonatomic, retain) IBOutlet UILabel *userName;
@property (nonatomic, retain) IBOutlet UILabel *userDetails;

@end
