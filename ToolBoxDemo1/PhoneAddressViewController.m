//
//  ViewController.m
//  SOAP Test
//
//  Created by administrator on 12-9-4.
//  Copyright (c) 2012年 administrator. All rights reserved.
//

#import "PhoneAddressViewController.h"

@interface PhoneAddressViewController ()

@end

@implementation PhoneAddressViewController
@synthesize phoneNumber;
@synthesize webData;
@synthesize soapResults;
@synthesize xmlParser;
@synthesize elementFound;
@synthesize matchingElement;
@synthesize conn;
@synthesize aPhone,aLable,mobileNo,iphoneNo;
- (void)viewDidLoad
{
    [super viewDidLoad];
    aPhone=[[NSString alloc]init];
    aLable=[[NSString alloc]init];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"phone"]];
}

- (void)viewDidUnload
{
    [self setPhoneNumber:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)doQuery:(id)sender
{
    NSString *number = phoneNumber.text;
    
    // 设置我们之后解析XML时用的关键字，与响应报文中Body标签之间的getMobileCodeInfoResult标签对应
    matchingElement = @"getMobileCodeInfoResult";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString *soapMsg = [NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                         "<soap12:Envelope "
                         "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                         "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                         "xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">"
                         "<soap12:Body>"
                         "<getMobileCodeInfo xmlns=\"http://WebXml.com.cn/\">"
                         "<mobileCode>%@</mobileCode>"
                         "<userID>%@</userID>"
                         "</getMobileCodeInfo>"
                         "</soap12:Body>"
                         "</soap12:Envelope>", number, @""];
    // 将这个XML字符串打印出来
    NSLog(@"%@",soapMsg);
    // 创建URL，内容是前面的请求报文报文中第二行主机地址加上第一行URL字段
    NSURL *url = [NSURL URLWithString:@"http://webservice.webxml.com.cn/WebServices/MobileCodeWS.asmx"];
    // 根据上面的URL创建一个请求
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d",[soapMsg length]];
    // 添加请求的详细信息，与请求报文前半部分的各字段对应
    [req addValue:@"application/soap+xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    // 设置请求行方法为POST，与请求报文第一行对应
    [req setHTTPMethod:@"POST"];
    //将SOAP消息加到请求中
    [req setHTTPBody:[soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    //创建连接
    conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if (conn) {
        webData = [NSMutableData data];
    }
}

#pragma mark -
#pragma mark URL Connection Data Delegate Methods
// 刚开始接受响应时调用
-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [webData setLength:0];
}

// 每接收到一部分数据就追加到webData中
-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
}
// 出现错误时
-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    conn = nil;
    webData = nil;
}
//完成接收数据时调用
-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *theXML = [[NSString alloc] initWithBytes:[webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
    //打印出得到的XML
    NSLog(@"%@",theXML);
    //使用NSXMLParser解析出我们想要的结果
    xmlParser = [[NSXMLParser alloc] initWithData:webData];
    [xmlParser setDelegate:self];
    [xmlParser setShouldResolveExternalEntities:YES];
    [xmlParser parse];
}

#pragma mark -
#pragma mark XML Parser Delegate Methods
//开始解析一个元素名
-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:matchingElement]) {
        if (!soapResults) {
            soapResults = [[NSMutableString alloc] init];
        }
        elementFound = YES;
    }
}

//追加找到的元素值，一个元素值可能要分几次追加
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (elementFound) {
        [soapResults appendString:string];
    }
}

// 结束解析这个元素名
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:matchingElement]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"手机号码信息" message:[NSString stringWithFormat:@"%@",soapResults] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        elementFound = FALSE;
        //强制放弃解析
        [xmlParser abortParsing];
    }
}

//解析整个文件结束后
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    if (soapResults) {
        soapResults = nil;
    }
}

// 出错时，例如强制结束解析
- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if (soapResults) {
        soapResults = nil;
    }
}

//显示通讯录
- (IBAction)showPicker:(id)sender
{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    [self presentModalViewController:picker animated:YES];
    
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    //获取联系人电话
    ABMutableMultiValueRef phoneMulti= ABRecordCopyValue(person, kABPersonPhoneProperty);
    NSMutableArray *iphones = [[NSMutableArray alloc] init];
    NSMutableArray *mobiles = [[NSMutableArray alloc] init];
    for (int i = 0; i<ABMultiValueGetCount(phoneMulti); i++) {
        aPhone = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phoneMulti, i);
    
        aLable = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phoneMulti, i);
      //  NSLog(@"PhoneLable:%@Phone#:%@",aLable,aPhone);
        
        //iphoneNo = [NSMutableString stringWithString:aPhone];
        if ([aLable isEqualToString:@"_$!<Mobile>!$_"]) {
            [mobiles addObject:aPhone];
        }
        if ([aLable isEqualToString:@"iPhone"]){
            [iphones addObject:aPhone];
        }
        
    }
    //phone.text = @"";
    if ([iphones count]>0) {
        iphoneNo = [NSMutableString stringWithString:[iphones objectAtIndex:0] ];
        NSLog(@"%@",iphoneNo);
    }
    if ([mobiles count]>0) {
        mobileNo = [NSMutableString stringWithString:[mobiles objectAtIndex:0]];
        NSLog(@"mobileNo:%@",mobileNo);
    }
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
//    NSLog(@"%d %d", property, identifier);
//    if ([aLable isEqualToString:@"_$!<Mobile>!$_"]) {
//        //mobileNo = [NSMutableString stringWithString:aPhone];
//        [mobileNo deleteCharactersInRange:NSMakeRange(1,2)];
//        [mobileNo deleteCharactersInRange:NSMakeRange(4,2)];
//        [mobileNo deleteCharactersInRange:NSMakeRange(7,1)];
//        NSLog(@"%@",mobileNo);
//        phoneNumber.text = mobileNo;
//    }else
//    {
//        
//        NSLog(@"%@",iphoneNo);
//        
//        [iphoneNo deleteCharactersInRange:NSMakeRange(1,2)];
//        [iphoneNo deleteCharactersInRange:NSMakeRange(4,2)];
//        [iphoneNo deleteCharactersInRange:NSMakeRange(7,1)];
//        phoneNumber.text = iphoneNo;
//    }
    NSLog(@"%d %d", property, identifier);
    if (identifier == 0 || identifier == 2) {
       [mobileNo deleteCharactersInRange:NSMakeRange(1,2)];
       [mobileNo deleteCharactersInRange:NSMakeRange(4,2)];
       [mobileNo deleteCharactersInRange:NSMakeRange(7,1)];
       NSLog(@"mobile: %@", mobileNo);
        phoneNumber.text = mobileNo;
    } else if (identifier == 1){
        [iphoneNo deleteCharactersInRange:NSMakeRange(1,2)];
        [iphoneNo deleteCharactersInRange:NSMakeRange(4,2)];
        [iphoneNo deleteCharactersInRange:NSMakeRange(7,1)];
        NSLog(@"iphone: %@", iphoneNo);
        phoneNumber.text = iphoneNo;
    }
    
    [self doQuery:phoneNumber.text];
    return YES;
}
@end













