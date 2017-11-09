#import "Ourhdr.h"
#import <IOMobileFrameBuffer.h>
#import <QuartzCore/QuartzCore.h>
//#import <IOKit/IOKit.h>
#import <IOSurface/IOSurface.h>
#import <IOSurface/IOSurfaceAccelerator.h>

extern "C" IOReturn IOSurfaceLock(IOSurfaceRef buffer, uint32_t options, uint32_t *seed);
extern "C" IOReturn IOSurfaceUnlock(IOSurfaceRef buffer, uint32_t options, uint32_t *seed);
extern "C" size_t IOSurfaceGetWidth(IOSurfaceRef buffer);
extern "C" size_t IOSurfaceGetHeight(IOSurfaceRef buffer);
extern "C" IOSurfaceRef IOSurfaceCreate(CFDictionaryRef properties);
extern "C" void *IOSurfaceGetBaseAddress(IOSurfaceRef buffer);
extern "C" size_t IOSurfaceGetBytesPerRow(IOSurfaceRef buffer);

extern const CFStringRef kIOSurfaceAllocSize;
extern const CFStringRef kIOSurfaceWidth;
extern const CFStringRef kIOSurfaceHeight;
extern const CFStringRef kIOSurfaceIsGlobal;
extern const CFStringRef kIOSurfaceBytesPerRow;
extern const CFStringRef kIOSurfaceBytesPerElement;
extern const CFStringRef kIOSurfacePixelFormat;

@interface SBScreenShotter : NSObject
+ (id)sharedInstance;
- (void)saveScreenshot:(_Bool)arg1;
@end

/*enum
{
    kIOSurfaceLockReadOnly  =0x00000001,
    kIOSurfaceLockAvoidSync =0x00000002
};
*/
%hook SpringBoard

int r=0;//模拟点击的pathindex

-(void)applicationDidFinishLaunching:(id)application 
{
    NSLog(@"*************** in spring board ***********");
    %orig;

    
        //创建偏好文件
    NSDictionary *preference = [[NSDictionary alloc]initWithObjectsAndKeys:@"normal",@"mode", nil];
    [preference writeToFile:PATH_PREFERENCE atomically:YES];
    

//
//    //launchdapp_app
    
    CPDistributedMessagingCenter *Launchdapp_center = [CPDistributedMessagingCenter centerNamed:@"launchdapp_app"];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f){
        //7.0+
        rocketbootstrap_distributedmessagingcenter_apply(Launchdapp_center);
    }
    [Launchdapp_center runServerOnCurrentThread];
    [Launchdapp_center registerForMessageName:@"launchdapp_app" target:self selector:@selector(LaunchdAppCallBack:userInfo:)];
    NSLog(@"后台启动程序服务器开启");
    

    //截屏服务器
    
    CPDistributedMessagingCenter *ScreenShot_center_app = [CPDistributedMessagingCenter centerNamed:@"ScreenShot-app"] ;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f){
        //7.0+
        rocketbootstrap_distributedmessagingcenter_apply(ScreenShot_center_app);
    }
    [ScreenShot_center_app runServerOnCurrentThread];
    [ScreenShot_center_app registerForMessageName:@"ScreenShot-app" target:self selector:@selector(canGetScreenCallback_app:userInfo:)];
    NSLog(@"截屏服务器开启");




    CPDistributedMessagingCenter *Launchdapp_center2 = [CPDistributedMessagingCenter centerNamed:@"launchdapp_app2"];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f){
        //7.0+
        rocketbootstrap_distributedmessagingcenter_apply(Launchdapp_center2);
    }
    [Launchdapp_center2 runServerOnCurrentThread];
    [Launchdapp_center2 registerForMessageName:@"launchdapp_app2" target:self selector:@selector(LaunchdAppCallBack2:userInfo:)];
    NSLog(@"后台启动程序服务器开启");


    //simulatetouch
    CPDistributedMessagingCenter *simulatetouch_center = [CPDistributedMessagingCenter centerNamed:@"simulatetouch"];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f){
        //7.0+
        rocketbootstrap_distributedmessagingcenter_apply(simulatetouch_center);
    }
    [simulatetouch_center runServerOnCurrentThread];
    [simulatetouch_center registerForMessageName:@"simulatetouchDown" target:self selector:@selector(simulateTouch:userInfo:)];
    [simulatetouch_center registerForMessageName:@"simulatetouchUp" target:self selector:@selector(simulateTouch:userInfo:)];
    [simulatetouch_center registerForMessageName:@"simulateSwipe" target:self selector:@selector(simulateTouch:userInfo:)];
    NSLog(@"模拟点击服务器开启");


}

%new
- (void)canGetScreenCallback_app:(NSString *)name userInfo:(NSDictionary *)userInfo{

   // SBScreenShotter *shotter =[%c(SBScreenShotter) sharedInstance];
   // [shotter saveScreenshot:YES];
    
    NSString *imagefilename = [[NSString alloc]initWithString:[userInfo objectForKey:@"filename"]];
   NSLog(@"截图路径%@",imagefilename); 

    IOMobileFramebufferConnection connect;
    kern_return_t result;
    CoreSurfaceBufferRef screenSurface = NULL;
    io_service_t framebufferService = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleH1CLCD"));
    if(!framebufferService)
        framebufferService = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleM2CLCD"));
    if(!framebufferService)
        framebufferService = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleCLCD"));

    result = IOMobileFramebufferOpen(framebufferService, mach_task_self(), 0, &connect);
    result = IOMobileFramebufferGetLayerDefaultSurface(connect, 0, &screenSurface);

    uint32_t aseed;
    IOSurfaceLock((IOSurfaceRef)screenSurface, 0x00000001, &aseed);
    size_t width = IOSurfaceGetWidth((IOSurfaceRef)screenSurface);

    size_t height = IOSurfaceGetHeight((IOSurfaceRef)screenSurface);
    CFMutableDictionaryRef dict;
    size_t pitch = width*4, size = width*height*4;

    int bPE=4;

    char pixelFormat[4] = {'A','R','G','B'};
    dict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(dict, kIOSurfaceIsGlobal, kCFBooleanTrue);
    CFDictionarySetValue(dict, kIOSurfaceBytesPerRow, CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &pitch));
    CFDictionarySetValue(dict, kIOSurfaceBytesPerElement, CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bPE));
    CFDictionarySetValue(dict, kIOSurfaceWidth, CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &width));
    CFDictionarySetValue(dict, kIOSurfaceHeight, CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &height));
    CFDictionarySetValue(dict, kIOSurfacePixelFormat, CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, pixelFormat));
    CFDictionarySetValue(dict, kIOSurfaceAllocSize, CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &size));

    IOSurfaceRef destSurf = IOSurfaceCreate(dict);
    IOSurfaceAcceleratorRef outAcc;
    IOSurfaceAcceleratorCreate(NULL, 0, &outAcc);

    IOSurfaceAcceleratorTransferSurface(outAcc, (IOSurfaceRef)screenSurface, destSurf, dict, NULL);
    IOSurfaceUnlock((IOSurfaceRef)screenSurface, kIOSurfaceLockReadOnly, &aseed);
    CFRelease(outAcc);

    CGDataProviderRef provider =  CGDataProviderCreateWithData(NULL,  IOSurfaceGetBaseAddress(destSurf), (width * height * 4), NULL);

    CGImageRef cgImage = CGImageCreate(width, height, 8,8*4, IOSurfaceGetBytesPerRow(destSurf), CGColorSpaceCreateDeviceRGB(), kCGImageAlphaNoneSkipFirst |kCGBitmapByteOrder32Little, provider, NULL, YES, kCGRenderingIntentDefault);

    UIImage *image = [UIImage imageWithCGImage:cgImage];

    

     NSLog(@"截图  图像%@",image);
       if (![UIImagePNGRepresentation(image) writeToFile:imagefilename atomically:YES]) {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"截图失败" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }

    NSLog(@"***** in tweak 截屏完成 *****");        
}




%new

- (void)LaunchdAppCallBack:(NSString *)name userInfo:(NSDictionary *)userInfo{
    NSString *appBundle = [userInfo objectForKey:@"Bundle"];
    NSString *suspend = [userInfo objectForKey:@"suspend"];
    NSLog(@"lw:appbundle %@",appBundle);
    NSLog(@"lw:appbundle %@",suspend);
    if([suspend isEqualToString:@"1"]){
    [self launchApplicationWithIdentifier:appBundle suspended:YES];
    }
    else{
    
    [self launchApplicationWithIdentifier:appBundle suspended:NO];
    }
    
    
    
}


%new

- (void)LaunchdAppCallBack2:(NSString *)name userInfo:(NSDictionary *)userInfo{
    NSString *appBundle = [userInfo objectForKey:@"Bundle"];
    [self launchApplicationWithIdentifier:appBundle suspended:NO];
    
    
    
}


%new
- (void)simulateTouch:(NSString *)type userInfo:(NSDictionary *)userInfo
{
    NSLog(@"*************Touch type = %@***********",type);
    if([type isEqualToString:[NSString stringWithFormat:@"simulatetouchDown"]])
    {
        NSString *xPoint = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"xPoint"]];
        NSString *yPoint = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"yPoint"]];
        float x = [xPoint floatValue];
        float y = [yPoint floatValue];
        CGPoint touchPoint = CGPointMake(x, y);
        r = [SimulateTouch simulateTouch:0 atPoint:touchPoint withType:STTouchDown];
        if (r == 0)
        {
            NSLog(@"iOSREError: Simutale touch down failed at (%f, %f).\n",x,y);
        }
        NSLog(@"xPoint = %@ ,yPoint = %@",xPoint,yPoint);

    }else if([type isEqualToString:[NSString stringWithFormat:@"simulatetouchUp"]])
    {
        NSString *xPoint = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"xPoint"]];
        NSString *yPoint = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"yPoint"]];
        float x = [xPoint floatValue];
        float y = [yPoint floatValue];
        CGPoint touchPoint = CGPointMake(x, y);
        int m = [SimulateTouch simulateTouch:r atPoint:touchPoint withType:STTouchUp];
        if (m == 0)
        {
            NSLog(@"iOSREError: Simutale touch up failed at (%f, %f).\n",x,y);
        }
        NSLog(@"xPoint = %@ ,yPoint = %@",xPoint,yPoint);

    }else if([type isEqualToString:[NSString stringWithFormat:@"simulateSwipe"]])
    {
        NSString *xPoint_from = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"xPoint_from"]];
        NSString *yPoint_from = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"yPoint_from"]];
        NSString *xPoint_to = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"xPoint_to"]];
        NSString *yPoint_to = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"yPoint_to"]];
        NSString *durationString = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"duration"]];
        float x_from = [xPoint_from floatValue];
        float y_from = [yPoint_from floatValue];
        float x_to = [xPoint_to floatValue];
        float y_to = [yPoint_to floatValue];
        double duration = [durationString doubleValue];
        CGPoint swipePoint_to = CGPointMake(x_to, y_to);
        CGPoint swipePoint_from = CGPointMake(x_from, y_from);
        int m = [SimulateTouch simulateSwipeFromPoint:swipePoint_from toPoint:swipePoint_to duration:duration];
        if (m == 0)
        {
            NSLog(@"iOSREError: Simutale swipe failed from (%f, %f) to (%f,%f) duration is %f.\n",x_from,y_from,x_to,y_to,duration);
        }
        NSLog(@"xPoint_from = %@ ,yPoint_from = %@ ,xPoint_to =%@ ,yPoint_to = %@ ,duration = %@ ",xPoint_from,yPoint_from,xPoint_to,yPoint_to,durationString);
        NSLog(@"xPoint_from = %f ,yPoint_from = %f ,xPoint_to =%f ,yPoint_to = %f ,duration = %f ",x_from,y_from,x_to,y_to,duration);

    }


}



%end
/*
%hook SBSMSClass0Alert
+(void)registerForAlerts
{
    NSLog(@"cancel Alert");

}
%end

%hook SBAlertItemsController

-(void)activateAlertItem:(id)item
{
    if([[[[NSDictionary alloc]initWithContentsOfFile:PATH_PREFERENCE] objectForKey:@"mode"] isEqual: @"test"])
    {
        NSLog(@" -----  ------  弹出框隐藏------ -----");
    }
    else
    {
        %orig;
    }
 }
%end

*/


/*
%hook SBScreenShotter

-(void)saveScreenshot:(BOOL)screenshot{

   
	if([[[NSDictionary dictionaryWithContentsOfFile:PATH_PREFERENCE] objectForKey:@"ISAPPTEST"] isEqual: @"YES"]||[[[NSDictionary dictionaryWithContentsOfFile:PATH_PREFERENCE] objectForKey:@"ISBROWSERTEST"] isEqual: @"YES"])
    {
        //%orig;
    	NSString *PicName = [[NSDictionary dictionaryWithContentsOfFile:PATH_PREFERENCE] objectForKey:@"SCREENSHOT_NAME"];
          
    
    //存图片

        //iOS8截图保存
      //  UIGraphicsBeginImageContext(self.view.bounds.size);
      //   [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
       //  UIImage *snapShotImage = UIGraphicsGetImageFromCurrentImageContext();
         //UIGraphicsEndImageContext();

        // UIImage *image = snapShotImage;
         
        IOMobileFramebufferConnection connect;
    kern_return_t result;
    CoreSurfaceBufferRef screenSurface = NULL;
    io_service_t framebufferService = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleH1CLCD"));
    if(!framebufferService)
        framebufferService = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleM2CLCD"));
    if(!framebufferService)
        framebufferService = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleCLCD"));

    result = IOMobileFramebufferOpen(framebufferService, mach_task_self(), 0, &connect);
    result = IOMobileFramebufferGetLayerDefaultSurface(connect, 0, &screenSurface);

    uint32_t aseed;
    IOSurfaceLock((IOSurfaceRef)screenSurface, 0x00000001, &aseed);
    size_t width = IOSurfaceGetWidth((IOSurfaceRef)screenSurface);

    size_t height = IOSurfaceGetHeight((IOSurfaceRef)screenSurface);
    CFMutableDictionaryRef dict;
    size_t pitch = width*4, size = width*height*4;

    int bPE=4;

    char pixelFormat[4] = {'A','R','G','B'};
    dict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(dict, kIOSurfaceIsGlobal, kCFBooleanTrue);
    CFDictionarySetValue(dict, kIOSurfaceBytesPerRow, CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &pitch));
    CFDictionarySetValue(dict, kIOSurfaceBytesPerElement, CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bPE));
    CFDictionarySetValue(dict, kIOSurfaceWidth, CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &width));
    CFDictionarySetValue(dict, kIOSurfaceHeight, CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &height));
    CFDictionarySetValue(dict, kIOSurfacePixelFormat, CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, pixelFormat));
    CFDictionarySetValue(dict, kIOSurfaceAllocSize, CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &size));

    IOSurfaceRef destSurf = IOSurfaceCreate(dict);
    IOSurfaceAcceleratorRef outAcc;
    IOSurfaceAcceleratorCreate(NULL, 0, &outAcc);

    IOSurfaceAcceleratorTransferSurface(outAcc, (IOSurfaceRef)screenSurface, destSurf, dict, NULL);
    IOSurfaceUnlock((IOSurfaceRef)screenSurface, kIOSurfaceLockReadOnly, &aseed);
    CFRelease(outAcc);

    CGDataProviderRef provider =  CGDataProviderCreateWithData(NULL,  IOSurfaceGetBaseAddress(destSurf), (width * height * 4), NULL);

    CGImageRef cgImage = CGImageCreate(width, height, 8,8*4, IOSurfaceGetBytesPerRow(destSurf), CGColorSpaceCreateDeviceRGB(), kCGImageAlphaNoneSkipFirst |kCGBitmapByteOrder32Little, provider, NULL, YES, kCGRenderingIntentDefault);

    UIImage *image = [UIImage imageWithCGImage:cgImage];
    NSLog(@"PicName = %@",PicName);
    if (![UIImagePNGRepresentation(image) writeToFile:PicName atomically:YES]) {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"截图失败" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }

    }
    else{
        %orig;
    }



}
%end
*/


