//
//  ViewController.h
//  SOAP Test
//
//  Created by administrator on 12-9-4.
//  Copyright (c) 2012年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface PhoneAddressViewController : UIViewController<NSXMLParserDelegate,NSURLConnectionDelegate,ABPeoplePickerNavigationControllerDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (strong, nonatomic) NSMutableData *webData;
@property (strong, nonatomic) NSMutableString *soapResults;
@property (strong, nonatomic) NSXMLParser *xmlParser;
@property (nonatomic) BOOL elementFound;
@property (strong, nonatomic) NSString *matchingElement;
@property (strong, nonatomic) NSURLConnection *conn;
@property (nonatomic,copy) NSString *aPhone;
@property (nonatomic,copy) NSString *aLable;
@property (nonatomic,copy) NSMutableString *mobileNo;
@property (nonatomic,copy) NSMutableString *iphoneNo;

- (IBAction)doQuery:(id)sender;
- (IBAction)showPicker:(id)sender;

@end
