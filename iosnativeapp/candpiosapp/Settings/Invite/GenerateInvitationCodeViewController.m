//
//  GenerateInvitationCodeViewController.m
//  candpiosapp
//
//  Created by Tomáš Horáček on 4/5/12.
//  Copyright (c) 2012 Coffee and Power Inc. All rights reserved.
//

#import "GenerateInvitationCodeViewController.h"
#import "PushModalViewControllerFromLeftSegue.h"

@interface GenerateInvitationCodeViewController ()

@property (nonatomic, weak) IBOutlet UILabel *codeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *codeLabelBackground;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;

- (IBAction)gearPressed:(id)sender;

#pragma mark -
#pragma mark private

- (void)showCode:(NSString *)code;
- (void)loadCode;

@end

#pragma mark -

@implementation GenerateInvitationCodeViewController

@synthesize codeLabel = _codeLabel;
@synthesize codeLabelBackground = _codeLabelBackground;
@synthesize doneButton = _doneButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [CPUIHelper changeFontForLabel:self.codeLabel toLeagueGothicOfSize:86];
    [CPUIHelper makeButtonCPButton:self.doneButton withCPButtonColor:CPButtonTurquoise];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadCode];
}

#pragma mark -
#pragma mark actions

- (IBAction)gearPressed:(id)sender {
    [self dismissPushModalViewControllerFromLeftSegue];
}

#pragma mark -
#pragma mark private

- (void)showCode:(NSString *)code {
    self.codeLabel.text = code;
    
    self.codeLabel.alpha = 0;
    self.codeLabel.hidden = NO;
    
    [UIView beginAnimations:nil context:nil];
    
    self.codeLabel.alpha = 1;
    
    [UIView commitAnimations];
}

- (void)loadCode {
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    CLLocation *location = [CPAppDelegate locationManager].location;
    
    [CPapi getInvitationCodeForLocation:location
                   withCompletionsBlock:^(NSDictionary *json, NSError *error) {
        BOOL respError = [[json objectForKey:@"error"] boolValue];
        
        if (!error && !respError) {
            [SVProgressHUD dismiss];
            NSDictionary *jsonDict = [json objectForKey:@"payload"];
            [self showCode:[jsonDict objectForKey:@"code"]];
        } else {
            [SVProgressHUD dismissWithError:[json objectForKey:@"payload"]
                                 afterDelay:kDefaultDimissDelay];
        }
    }];
}

@end
