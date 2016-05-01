//
//  ViewController.m
//  signaturetrollthing
//
//  Created by Kevin Fang on 4/30/16.
//  Copyright © 2016 Kevin Fang. All rights reserved.
//

#import "ViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <Twitter/Twitter.h>
#import <Firebase/Firebase.h>
#import <BALoadingView/BALoadingView.h>

@interface ViewController (){
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    BOOL mouseSwiped;
    NSMutableData *data;
    BALoadingView * bg;
}
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *welcome;
@property (weak, nonatomic) IBOutlet UIImageView *tempImage;
@property (weak, nonatomic) IBOutlet UIImageView *realImage;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) NSString *imageString;
@end

@implementation ViewController

NSString *responseText;

- (IBAction)clear:(id)sender {
    self.realImage.image = nil;
}
- (IBAction)done:(id)sender {
    NSString *imageString = [self encodeToBase64String:_realImage.image];
    
    Firebase *myRootRef = [[[Firebase alloc] initWithUrl:@"https://signatureauthentication.firebaseIO.com"] childByAppendingPath:@"image"];
    [myRootRef setValue:[NSString stringWithFormat:@"%@",imageString]];
    //    _realImage.image = [self decodeBase64ToImage:imageString];
    
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"Do some work");
        NSString *post = [NSString stringWithFormat:@""];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"http://32e96d9f.ngrok.io/login"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [conn start];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You're done"
//                                                        message:@"Nice signature"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"Same"
//                                              otherButtonTitles:nil];
//        [alert show];
    });
    
    int size = 150;
    bg = [[BALoadingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - size/2, self.view.frame.size.height/2 - size/2,size, size)];
    [bg initialize];
    [bg startAnimation:BACircleAnimationFullCircle];
    bg.alpha = 0.0f;
    [UIView animateWithDuration:0.4 animations:^() {
        bg.alpha = 1.0f;
    }];
    
//    bg.frame =
    [self.view addSubview:bg];
    
    _clearButton.hidden = YES;
    _doneButton.hidden = YES;
    _welcome.hidden = NO;
    _welcome.alpha = 0;
    _nameLabel.hidden = NO;
    _nameLabel.alpha = 0;
    
    _welcome.frame = CGRectMake(_welcome.frame.origin.x, _welcome.frame.origin.y, self.view.frame.size.width, _welcome.frame.size.height);
    
    _nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y, self.view.frame.size.width, _nameLabel.frame.size.height);


    
    self.realImage.image = nil;
}

- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImageJPEGRepresentation(image,5) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    
}


- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

- (void) viewWillAppear{
    
}
- (void)viewDidLoad
{
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    brush = 10.0;
    opacity = 1.0;
    _welcome.hidden = YES;
    _nameLabel.hidden = YES;
    data = [[NSMutableData alloc]init];
    
    [super viewDidLoad];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [data setLength:0];
    NSHTTPURLResponse *resp= (NSHTTPURLResponse *) response;
    NSLog(@"got responce with status @push %d",[resp statusCode]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d
{
    [data appendData:d];
    NSLog(@"recieved data @push %@", data);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    responseText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"didfinishLoading%@",responseText);
    _nameLabel.text = responseText;
    
    [UIView animateWithDuration:0.2 animations:^() {
        bg.alpha = 0.0f;
    }];
    
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    
        [UIView animateWithDuration:0.4 animations:^() {
//            _nameLabel.alpha = 1.0f;
            _welcome.alpha = 1.0f;
        }];
        
    });
    
    delayInSeconds = 0.4;
    popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:0.4 animations:^() {
            _nameLabel.alpha = 1.0f;
//            _welcome.alpha = 1.0f;
        }];
        
    });
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.tempImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.tempImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.tempImage setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(!mouseSwiped) {
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.tempImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.tempImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIGraphicsBeginImageContext(self.realImage.frame.size);
    [self.realImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.tempImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    self.realImage.image = UIGraphicsGetImageFromCurrentImageContext();
    self.tempImage.image = nil;
    UIGraphicsEndImageContext();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
