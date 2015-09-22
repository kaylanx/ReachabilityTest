//
//  ViewController.m
//  ReachabilityTest
//
//  Created by Andy Kayley on 19/09/2015.
//  Copyright © 2015 Rentalcars.com. All rights reserved.
//

#import "ViewController.h"

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <SystemConfiguration/SystemConfiguration.h>


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *hostNameTextField;
@property (nonatomic, assign) SCNetworkReachabilityRef networkReachabilityRef;

@property (atomic, assign) NSInteger calledCount;

- (void)reachabilityCompleted;

@end

static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment) {
    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n----------------------------------\n\n\n",
          (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          comment
          );
}


static void AKReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    ViewController* viewController = (__bridge ViewController *)info;
    viewController.calledCount ++;
    
    NSString *comment = [NSString stringWithFormat:@"Called %ld time(s)",(long)viewController.calledCount];
    
    PrintReachabilityFlags(flags, [comment UTF8String]);
}

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.calledCount = 0;
    NSString *hostName = @"www.rentalcars.com";
    
    self.hostNameTextField.text = hostName;
    
    [self doReachabilityWithAppleAPIForHostName:hostName];
}

- (void) reachabilityCompleted {
    SCNetworkReachabilitySetCallback(self.networkReachabilityRef, NULL, NULL);
}

- (IBAction)appleClicked:(id)sender {
    self.calledCount = 0;
    SCNetworkReachabilitySetCallback(self.networkReachabilityRef, NULL, NULL);
    [self doReachabilityWithAppleAPIForHostName:self.hostNameTextField.text];
}

- (void) doReachabilityWithAppleAPIForHostName:(NSString*) hostName {
    self.networkReachabilityRef = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    
    SCNetworkReachabilityContext context = {0, NULL, NULL, NULL, NULL};
    
    context.info = (__bridge void *)self;
    
    if (!SCNetworkReachabilitySetCallback(self.networkReachabilityRef, AKReachabilityCallback, &context)) {
        NSLog(@"SCNetworkReachabilitySetCallback() failed: %s", SCErrorString(SCError()));
    }
    
    if (!SCNetworkReachabilitySetDispatchQueue(self.networkReachabilityRef, dispatch_queue_create("com.rentalcars.reachability", NULL))) {
        NSLog(@"SCNetworkReachabilitySetDispatchQueue() failed: %s", SCErrorString(SCError()));
        SCNetworkReachabilitySetCallback(self.networkReachabilityRef, NULL, NULL);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
