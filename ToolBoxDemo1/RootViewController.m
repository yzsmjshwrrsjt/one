//
//  RootViewController.m
//  ToolBoxDemo1
//
//  Created by administrator on 12-9-10.
//  Copyright (c) 2012年 administrator. All rights reserved.
//

#import "RootViewController.h"
#import "MyLauncherItem.h"
#import "CustomBadge.h"
#import "LineViewController.h"
#import "PhoneAddressViewController.h"

//sdhfoafd
@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIBarButtonItem * item=[[UIBarButtonItem alloc]init];
        item.title=@"Back";
        self.navigationItem.backBarButtonItem=item;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.title = @"百宝箱";
    
    //Add your view controllers here to be picked up by the launcher; remember to import them above
    [[self appControllers] setObject:[LineViewController class] forKey:@"LineViewController"];
    [[self appControllers] setObject:[PhoneAddressViewController class] forKey:@"PhoneAddressViewController"];
    
    if (![self hasSavedLauncherItems])
    {
        [self.launcherView setPages:[NSMutableArray arrayWithObjects:[NSMutableArray arrayWithObjects:[[MyLauncherItem alloc] initWithTitle:@"跑步助手" iPhoneImage:@"itemImage" iPadImage:@"itemImage" target:@"LineViewController" targetTitle:@"跑步助手" deletable:YES ],
                                                                      [[MyLauncherItem alloc] initWithTitle:@"号码归属地查询" iPhoneImage:@"itemImage" iPadImage:@"itemImage" target:@"PhoneAddressViewController" targetTitle:@"号码归属地查询" deletable:NO],nil],nil]];
        
//        LineViewController *lc =[[LineViewController alloc]initWithNibName:nil bundle:nil];
//        [self.navigationController pushViewController:lc animated:YES];
    }
    // Set badge text for a MyLauncherItem using it's setBadgeText: method
    [(MyLauncherItem *)[[[self.launcherView pages] objectAtIndex:0] objectAtIndex:0]setBadgeText:@"4"];
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
