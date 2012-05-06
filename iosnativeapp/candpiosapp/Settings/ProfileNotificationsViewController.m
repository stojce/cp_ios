//
//  ProfileNotificationsViewController.m
//  candpiosapp
//
//  Created by Stojce Slavkovski on 05.5.12.
//  Copyright (c) 2012 Coffee and Power Inc. All rights reserved.
//

#import "ProfileNotificationsViewController.h"
#import "ActionSheetDatePicker.h"

#define kInVenueText @"in venue"
#define kInCityText @"in city"

@interface ProfileNotificationsViewController () <UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIButton *venueButton;
@property (weak, nonatomic) IBOutlet UISwitch *checkedInOnlySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *quietTimeSwitch;
@property (weak, nonatomic) IBOutlet UIView *anyoneChatView;
@property (weak, nonatomic) IBOutlet UIButton *quietFromButton;
@property (weak, nonatomic) IBOutlet UIButton *quietToButton;
@property (weak, nonatomic) IBOutlet UISwitch *contactsOnlyChatSwitch;

- (IBAction)selectVenueCity:(UIButton *)sender;
- (IBAction)quietFromClicked:(UIButton *)sender;
- (IBAction)quietToClicked:(UIButton *)sender;
- (IBAction)quietTimeValueChanged:(UISwitch *)sender;


@property NSDate *quietTimeFromDate;
@property NSDate *quietTimeToDate;

@end

@implementation ProfileNotificationsViewController

@synthesize venueButton = _venueButton;
@synthesize checkedInOnlySwitch = _checkedInOnlySwitch;
@synthesize quietTimeSwitch = _quietTimeSwitch;
@synthesize anyoneChatView = anyoneChatView;
@synthesize quietFromButton = _quietFromButton;
@synthesize quietToButton = _quietToButton;
@synthesize contactsOnlyChatSwitch = _contactsOnlyChatSwitch;
@synthesize quietTimeFromDate = _quietTimeFromDate;
@synthesize quietTimeToDate = _quietTimeToDate;

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self venueButton].titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    [self loadNotificationSettings];
}

- (void)viewDidUnload
{
    [self setVenueButton:nil];
    [self setCheckedInOnlySwitch:nil];
    [self setQuietTimeSwitch:nil];
    [self setAnyoneChatView:nil];
    [self setQuietFromButton:nil];
    [self setQuietToButton:nil];
    [self setContactsOnlyChatSwitch:nil];
    [self setQuietTimeFromDate:nil];
    [self setQuietTimeToDate:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self saveNotificationSettings];
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Api calls
- (void)loadNotificationSettings
{
    [CPapi getNotificationSettingsWithCompletition:^(NSDictionary *json, NSError *err) {
        BOOL error = [[json objectForKey:@"error"] boolValue];
        if (error) {
            NSString *message = @"There was a problem getting your data!\nPlease logout and login again.";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                                message:message
                                                               delegate:self 
                                                      cancelButtonTitle:@"OK" 
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"HH:mm:ss"];
            [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
            
            NSDictionary *dict = [json objectForKey:@"payload"];

            NSString *venue = (NSString *)[dict objectForKey:@"push_distance"];
            [self setVenue:[venue isEqualToString:@"venue"]];

            NSString *checkInOnly = (NSString *)[dict objectForKey:@"checked_in_only"];
            [[self checkedInOnlySwitch] setOn:[checkInOnly isEqualToString:@"1"]];

            NSString *quietTime = (NSString *)[dict objectForKey:@"quiet_time"];
            [[self quietTimeSwitch] setOn:[quietTime isEqualToString:@"1"]];
            [self setQuietTime:self.quietTimeSwitch.on];
            
            NSString *quietTimeFrom = (NSString *)[dict objectForKey:@"quiet_time_from"];
            if ([quietTimeFrom isKindOfClass:[NSNull class]]) {
                quietTimeFrom = @"07:00:00";
            }
            
            @try {
                self.quietTimeFromDate = [dateFormat dateFromString:quietTimeFrom];
            }
            @catch (NSException* ex) {
                self.quietTimeFromDate = [dateFormat dateFromString:@"7:00"];
            }
            
            [[self quietFromButton] setTitle:[self setTimeText:self.quietTimeFromDate]
                                    forState:UIControlStateNormal];

            
            NSString *quietTimeTo = (NSString *)[dict objectForKey:@"quiet_time_to"];
            if ([quietTimeTo isKindOfClass:[NSNull class]]) {
                quietTimeTo = @"19:00:00";
            }
            
            @try {
                self.quietTimeToDate = [dateFormat dateFromString:quietTimeTo];
            }
            @catch (NSException* ex) {
                self.quietTimeToDate = [dateFormat dateFromString:@"19:00"];
            }
            
            [[self quietToButton] setTitle:[self setTimeText:self.quietTimeToDate]
                                  forState:UIControlStateNormal];

            NSString *contactsOnlyChat = (NSString *)[dict objectForKey:@"contacts_only_chat"];
            [[self contactsOnlyChatSwitch] setOn:[contactsOnlyChat isEqualToString:@"0"]];
        }
    }];
}

- (void)saveNotificationSettings
{
    BOOL notifyInVenue = [self.venueButton.currentTitle isEqualToString:kInVenueText];
    NSString *distance = notifyInVenue ? @"venue" : @"city";
    
    [CPapi setNotificationSettingsForDistance:distance
                                 andCheckedId:self.checkedInOnlySwitch.on
                                    quietTime:self.quietTimeSwitch.on
                                quietTimeFrom:[self quietTimeFromDate]
                                  quietTimeTo:[self quietTimeToDate]
                      timezoneOffsetInSeconds:[[NSTimeZone defaultTimeZone] secondsFromGMT]
                         chatFromContactsOnly:!self.contactsOnlyChatSwitch.on];
}

#pragma mark - UI Events

- (IBAction)quietFromClicked:(UITextField *)sender 
{
    [ActionSheetDatePicker showPickerWithTitle:@"Select Quiet Time From"
                                datePickerMode:UIDatePickerModeTime
                                  selectedDate:[self quietTimeFromDate]
                                        target:self
                                        action:@selector(timeWasSelected:element:)
                                        origin:sender];
}

- (IBAction)quietToClicked:(UIButton *)sender
{
    [ActionSheetDatePicker showPickerWithTitle:@"Select Quiet Time To"
                                datePickerMode:UIDatePickerModeTime
                                  selectedDate:[self quietTimeToDate]
                                        target:self
                                        action:@selector(timeWasSelected:element:)
                                        origin:sender];
}

- (void)timeWasSelected:(NSDate *)selectedTime element:(id)element
{
    UIButton *button = (UIButton *)element;
    [button setTitle:[self setTimeText:selectedTime] forState:UIControlStateNormal];
    if (button.tag == 1) {
        self.quietTimeFromDate = selectedTime;
    } else {
        self.quietTimeToDate = selectedTime;
    }
}

- (IBAction)quietTimeValueChanged:(UISwitch *)sender
{
    [self setQuietTime:sender.on];
}

- (IBAction)selectVenueCity:(UIButton *)sender 
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Show me new check-ins from:"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"City", @"Venue", nil
                                  ];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self setVenue:buttonIndex == 1];
}

- (void)setVenue:(BOOL)inVenue
{
    [[self venueButton] setTitle: inVenue ? kInVenueText : kInCityText
                        forState:UIControlStateNormal];
}

- (void)setQuietTime:(BOOL)quietTime
{   
    [UIView animateWithDuration:0.3 animations:^ {
        self.anyoneChatView.frame = CGRectMake(self.anyoneChatView.frame.origin.x, 
                                               quietTime ? 218 : 175,
                                               self.anyoneChatView.frame.size.width,
                                               self.anyoneChatView.frame.size.height);
    }];
}

- (NSString *)setTimeText:(NSDate *)timeValue
{
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm";
    timeFormatter.timeStyle = NSDateFormatterShortStyle;
    NSString *dateString = [timeFormatter stringFromDate: timeValue];
    
    return dateString;
}


#pragma mark - Alert View Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self dismissModalViewControllerAnimated:YES];
}

@end