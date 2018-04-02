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

#define TOUCH_PREFERENCE @"/var/mobile/Library/Preferences/com.lw.TouchTest.plist"
#define TOUCH_ABS_PREFERENCE @"/var/mobile/Library/Preferences/com.lw.TouchABS.plist"
#define TOUCH_RE_PREFERENCE @"/var/mobile/Library/Preferences/com.lw.TouchRE.plist"
#define TOUCH_WIDGET @"/var/mobile/Library/Preferences/com.lw.TouchWidget.plist"


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


%hook UIWindow
%new
-(NSDictionary *)getAbsFrame:(NSString *)type userInfo:(NSDictionary *)userInfo actionInfo:(NSDictionary *)actionInfo
{
	//获取点击信息
//	NSLog(@"each UI in getAbsFrame widget is %@",userInfo);
	NSString *touchText = [actionInfo objectForKey:@"text"];
	[touchText stringByReplacingOccurrencesOfString:@"U" withString:@"u"];
/*	NSLog(@"each UI in getAbsFrame actionInfo is %@",actionInfo);*/
    NSString *widgetSet = [userInfo objectForKey:@"widgetSet"];
     NSArray *UIArray_temp1 = [widgetSet componentsSeparatedByString:@"\n"];
     int count=[UIArray_temp1 count];
     NSMutableArray *UIArray = [NSMutableArray arrayWithCapacity:5];
     int count_temp = 0;
	int iii=0;
	iii++;
     while(count_temp < count -1 )
     {
        NSString *tmp = [UIArray_temp1 objectAtIndex:count_temp];
		int flag = 0;
		 //Fetch text
        NSString *text;
        int text_s = (int)([tmp rangeOfString:@"'"].location+1);
        if (text_s == 0)
        {
            text=nil;
        }
        else
        {
            NSString *text_start = [tmp substringFromIndex:text_s];
            int text_e = (int)([text_start rangeOfString:@"'"].location);
            text = [text_start substringToIndex:text_e];
			if([text rangeOfString:touchText].location != NSNotFound)
			{
				NSLog(@"each UI target get");
				flag = 1;
			}
        }
        int tail = (int)([tmp rangeOfString:@");"].location+1);
        NSString *slice_tmp = [tmp substringToIndex:tail];
        NSString *slice = [slice_tmp stringByReplacingOccurrencesOfString:@"|" withString:@""];

        //Fetch UI Name
        int Name_start = (int)([slice rangeOfString:@"<"].location + 1);
        if (Name_start == 0 )
        {
                count_temp ++;
                continue;
        }
        NSString *nameStart = [slice substringFromIndex:Name_start];
        int Name_end = (int)([nameStart rangeOfString:@":"].location);
        if(Name_end == -1)
        {
                count_temp ++;
                continue;
        }
        NSString *Name = [nameStart substringToIndex:Name_end];
        int level_num = floor(Name_start/4);
        NSString *level = [[NSString alloc]initWithFormat:@"%d",level_num];
        NSString *stringWithoutName = [nameStart substringFromIndex:Name_end];

        //Fetch UI address
        int Address_start = (int)[stringWithoutName rangeOfString:@"0x"].location;
        if(Address_start == -1)
        {
                count_temp ++;
                continue;
        }
        NSString *addressStart = [stringWithoutName substringFromIndex:Address_start];
        int Address_end = (int)([addressStart rangeOfString:@";"].location);
        if(Address_end == -1)
        {
                count_temp ++;
                continue;
	  	}
        NSString *Address = [addressStart substringToIndex:Address_end];
        NSString *stringWithoutAddress = [addressStart substringFromIndex:Address_end];

        //Fetch Position_X
        int Position_X_start = (int)([stringWithoutAddress rangeOfString:@"("].location + 1);
        if(Position_X_start == 0)
        {
                count_temp ++;
                continue;
        }
        NSString *Position_Xstart = [stringWithoutAddress substringFromIndex:Position_X_start];
        int Position_X_end = (int)([Position_Xstart rangeOfString:@" "].location);
        if(Position_X_end == -1)
        {
                count_temp ++;
                continue;
        }
        NSString *Position_X = [Position_Xstart substringToIndex:Position_X_end];
        NSString *stringWithoutPosition_X = [Position_Xstart substringFromIndex:Position_X_end];
        //NSLog(@"each UI Position_X is %@",Position_X);

        //Fetch Position_Y
        int Position_Y_start = (int)([stringWithoutPosition_X rangeOfString:@" "].location + 1);
        if(Position_Y_start == 0)
        {
                count_temp ++;
                continue;
        }
        NSString *Position_Ystart = [stringWithoutPosition_X substringFromIndex:Position_Y_start];
        int Position_Y_end = (int)([Position_Ystart rangeOfString:@";"].location);
        if(Position_Y_end == -1)
        {
                count_temp ++;
                continue;
        }
        NSString *Position_Y = [Position_Ystart substringToIndex:Position_Y_end];
        NSString *stringWithoutPosition_Y = [Position_Ystart substringFromIndex:Position_Y_end];
        //NSLog(@"each UI Position_Y is %@",Position_Y);

        //Fetch Size_X
        int Size_X_start = (int)([stringWithoutPosition_Y rangeOfString:@" "].location + 1);
        if(Size_X_start == 0)
        {
                count_temp ++;
                continue;
        }
        NSString *Size_Xstart = [stringWithoutPosition_Y substringFromIndex:Size_X_start];
        int Size_X_end = (int)([Size_Xstart rangeOfString:@" "].location);
if(Size_X_end == -1)
        {
                count_temp ++;
                continue;
        }
        NSString *Size_X = [Size_Xstart substringToIndex:Size_X_end];
        NSString *stringWithoutSize_X = [Size_Xstart substringFromIndex:Size_X_end];
        //NSLog(@"each UI Size_X is %@",Size_X);

        //Fetch Size_Y
         int Size_Y_start = (int)([stringWithoutSize_X rangeOfString:@" "].location + 1);
        if(Size_Y_start == 0)
        {
                count_temp ++;
                continue;
        }
        NSString *Size_Ystart = [stringWithoutSize_X substringFromIndex:Size_Y_start];
        int Size_Y_end = (int)([Size_Ystart rangeOfString:@")"].location);
        if(Size_Y_end == -1)
        {
                count_temp ++;
                continue;
        }
        NSString *Size_Y = [Size_Ystart substringToIndex:Size_Y_end];
       // NSString *stringWithoutSize_Y = [Size_Ystart substringFromIndex:Size_Y_end];
       // NSLog(@"each UI Size_Y is %@\n",Size_Y);

//		NSLog(@"text is %@",text);		
//      NSLog(@"each UI Name:%@ Address:%@ Position_X:%@ Position_Y:%@ Size_X:%@ Size_Y:%@ level:%@",Name,Address,Position_X,Position_Y,Size_X,Size_Y,level);
//      NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:Name, @"Name", Address, @"Address", Position_X, @"Position_X", Position_Y, @"Position_Y", Size_X, @"Size_X", Size_Y, @"Size_Y", level, @"level", nil];
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:Name,@"Name",Address,@"Address",Position_X,@"Position_X",Position_Y,@"Position_Y",Size_X,@"Size_X",Size_Y,@"Size_Y",level,@"level",text,@"text",nil];
        [UIArray addObject:dict];
        int UI_count = [UIArray count];
        int parentNum = 0;
		NSString *UIParent;
		if(flag==1)
		{
			//寻找控件的父节点
	        for (int j = UI_count -1; j>=0;j --)
    	    {
        	        if([[UIArray[j] valueForKey:@"level"] intValue]==(level_num - 1))
            	    {
               	            UIParent = [UIArray[j] valueForKey:@"Name"];
                	        parentNum = j;
                       	    break;
               		 }	
    	   }

       		 //根据父节点的确定控件的绝对坐标
     	   double abs_Position_X = [Position_X floatValue];
      	   double abs_Position_Y = [Position_Y floatValue];
    	   while([[UIArray[parentNum] valueForKey:@"Position_X"] intValue ] != 0 || [[UIArray[parentNum] valueForKey:@"Position_Y"] intValue ] != 0 || [[UIArray[parentNum] valueForKey:@"Size_X"] intValue ] != 320 || [[UIArray[parentNum] valueForKey:@"Size_Y"] intValue ] != 568 )
      	  {
        	 for (int k = parentNum; k>=0;k --)
            	    {
                	        if([[UIArray[k] valueForKey:@"level"] intValue]==(level_num - 1)  )
                    	    {
                        	//      NSString *UIParent = [UIArray[k] valueForKey:@"Name"];
                            	     parentNum = k;
                        //  	     NSLog(@"each UI in abs level = %@ Position_X is %@ Position_Y is %@ Size_X is %@ Size_Y is %@\n",[UIArray[parentNum]valueForKey:@"level"],[UIArray[parentNum] valueForKey:@"Position_X"],[UIArray[parentNum] valueForKey:@"Position_Y"],[UIArray[parentNum] valueForKey:@"Size_X"],[UIArray[parentNum] valueForKey:@"Size_Y"]);
                            	    level_num --;
                               		 break;
                      		  }
            	    }
                abs_Position_X = abs_Position_X + [[UIArray[parentNum] valueForKey:@"Position_X"] floatValue];
                abs_Position_Y = abs_Position_Y + [[UIArray[parentNum] valueForKey:@"Position_Y"] floatValue];
        //      NSLog(@"each UI in for Position_X is %@ Position_Y is %@",[UIArray[parentNum] valueForKey:@"Position_X"],[UIArray[parentNum] valueForKey:@"Position_Y"]);
        //      NSLog(@"each UI  in for abs_Postion_X is %f    abs_Position_Y is %f",abs_Position_X,abs_Position_Y);
      	  }
		abs_Position_X = abs_Position_X + [Size_X intValue]/2;
		abs_Position_Y = abs_Position_Y + [Size_Y intValue]/2;
		NSString *abs_X = [NSString stringWithFormat:@"%f",abs_Position_X];
		NSString *abs_Y = [NSString stringWithFormat:@"%f",abs_Position_Y];
        NSLog(@"each UI abs_Position_X = %f   abs_Position_Y = %f\n\n\n",abs_Position_X,abs_Position_Y);
        NSLog(@"each UI \n\n\n");
		NSLog(@"each UI name = %@",Name);
        NSLog(@"each UI \n\n\n");
//		NSLog(@"each UI Position_X is %@    each UI Position_Y is %@",Position_X,Position_Y);
		
		NSDictionary *resultDic = [NSDictionary dictionaryWithObjectsAndKeys:abs_X,@"xPoint",abs_Y,@"yPoint",nil];
		return resultDic;
		}
		count_temp ++;			
		
	}
	return nil;
}

%end


%hook UIViewController

CPDistributedMessagingCenter *simulatetouch_Center = [CPDistributedMessagingCenter centerNamed:@"simulatetouch"];
int lock =0;
//显示每个组件的时候调用
-(void)viewDidAppear:(BOOL)animated
{
	%orig;
	NSLog(@"each UI in viewDidAppear");
	//当且仅当第一次显示组件的时候注册simulatetouch_Center
	if(lock ==0)
	{
		rocketbootstrap_distributedmessagingcenter_apply(simulatetouch_Center);
		lock=1;
	}
	 NSDictionary *waitInfo = [NSDictionary dictionaryWithContentsOfFile:TOUCH_PREFERENCE];
	 //int waitTime = [[waitInfo objectForKey:@"waitTime"] intValue];
	 //int waitCount = [[waitInfo objectForKey:@"waitCount"]intValue]; 
	//读取一条动作记录之后，调用recursiveDescription获取当前界面的控件树
     if([[waitInfo objectForKey:@"read" ]isEqualToString:@"NO"]&&[[waitInfo objectForKey:@"touch"]isEqualToString:@"NO"] )
      {
			NSLog(@"each UI in viewDidAppear if ");
		    NSMethodSignature  *signature = [UIWindow instanceMethodSignatureForSelector:@selector(recursiveDescription)];
   			 NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    		//设置方法调用者
   		 	invocation.target =  [UIApplication sharedApplication].keyWindow;
    		//注意：这里的方法名一定要与方法签名类中的方法一致
  	 		 invocation.selector = @selector(recursiveDescription);
   			 //这里的Index要从2开始，以为0跟1已经被占据了，分别是self（target）,selector(_cmd)
      		 /* NSString *type = @"111";
       	 	[invocation setArgument:&type atIndex:2];
       	 	[invocation setArgument:&text atIndex:3];	*/
			[invocation invoke];
   		 	NSString *res = nil;
   			 if (signature.methodReturnLength != 0) {//有返回值
          	//将返回值赋值给res
        		  [invocation getReturnValue:&res];
  		    }
   		    NSString *widgetSet = res;
    		NSDictionary *widgetInfo = [[NSDictionary alloc]initWithObjectsAndKeys:widgetSet,@"widgetSet",nil];
			if([widgetSet rangeOfString:[waitInfo objectForKey:@"check"]].location!=NSNotFound)
			{
				[simulatetouch_Center sendMessageName:@"simulatetouchText" userInfo:widgetInfo];
				[waitInfo setValue:@"YES" forKey:@"touch"];
				[waitInfo writeToFile:TOUCH_PREFERENCE atomically:YES];

			}
			else
			{
				NSLog(@"each UI check-text in viewDidAppear do not appear!!!");
			}
		}
		else
		{
			NSMethodSignature  *signature = [UIWindow instanceMethodSignatureForSelector:@selector(recursiveDescription)];
             NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            //设置方法调用者
            invocation.target =  [UIApplication sharedApplication].keyWindow;
            //注意：这里的方法名一定要与方法签名类中的方法一致
             invocation.selector = @selector(recursiveDescription);
             //这里的Index要从2开始，以为0跟1已经被占据了，分别是self（target）,selector(_cmd)
             /* NSString *type = @"111";
            [invocation setArgument:&type atIndex:2];
            [invocation setArgument:&text atIndex:3];   */
            [invocation invoke];
            NSString *res = nil;
             if (signature.methodReturnLength != 0) {//有返回值
            //将返回值赋值给res
                  [invocation getReturnValue:&res];
            }
            NSString *widgetSet = res;
            NSDictionary *widgetInfo = [[NSDictionary alloc]initWithObjectsAndKeys:widgetSet,@"widgetSet",nil];
            [widgetInfo writeToFile:TOUCH_WIDGET atomically:YES];
		}
}
%end

%hook SpringBoard

int r=0;//模拟点击的pathindex
NSDictionary *actionInfo;
int action_count=0;
int action_temp=0;
CPDistributedMessagingCenter *touchtext_Center = [CPDistributedMessagingCenter centerNamed:@"simulatetouch"];
int lock1=0;

-(void)applicationDidFinishLaunching:(id)application 
{
    NSLog(@"*************** in spring board ***********");
    %orig;
    NSLog(@"hello");
	//int cycle_count = 5;
	float cycle_interval = 36000.0;
    
        //创建偏好文件
    NSDictionary *preference = [[NSDictionary alloc]initWithObjectsAndKeys:@"normal",@"mode", nil];
    [preference writeToFile:PATH_PREFERENCE atomically:YES];
    

    //launchdapp_app
    
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
	NSLog(@"11");



   //后台启动程序
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
	[simulatetouch_center registerForMessageName:@"simulatetouchText" target:self selector:@selector(simulateTouchText:userInfo:)];
	[simulatetouch_center registerForMessageName:@"ReadScript" target:self selector:@selector(readscript:userInfo:)];
	[simulatetouch_center registerForMessageName:@"getWidget" target:self selector:@selector(getAbsFrame:userInfo:)];
    NSLog(@"模拟点击服务器开启");

	NSDictionary *bundle = [[NSDictionary alloc]initWithObjectsAndKeys:@"com.mqr.BlockTest",@"Bundle", nil];
	NSRunLoop *loop = [NSRunLoop currentRunLoop];
	NSLog(@"BlockTest!!! in applicationdidFinishLaunching bundle is %@",bundle);
    NSTimer *timer = [NSTimer  timerWithTimeInterval:cycle_interval target:self selector:@selector(awakeApp:) userInfo:bundle repeats:YES];
    [loop addTimer:timer forMode:NSDefaultRunLoopMode];
    [loop run];


}

%new
- (void)awakeApp:(NSTimer *)timer{
    CPDistributedMessagingCenter *Launchapp_Center3 = [CPDistributedMessagingCenter centerNamed:@"launchdapp_app2"];
	NSDictionary *appbundle = [timer userInfo];
	NSLog(@"BlockTest!!! in awake userInfo is %@",appbundle);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f){
        //7.0+
        rocketbootstrap_distributedmessagingcenter_apply(Launchapp_Center3);
    }
    [Launchapp_Center3 sendMessageName:@"launchdapp_app2" userInfo:appbundle];
    NSLog(@"nana: in awakeApp");
}

%new
-(void)touchExistText
{
	if(lock1 ==0)
    {
        rocketbootstrap_distributedmessagingcenter_apply(touchtext_Center);
        lock1=1;
    }	
	NSDictionary *waitInfo = [NSDictionary dictionaryWithContentsOfFile:TOUCH_PREFERENCE];
	if([[waitInfo objectForKey:@"read"]isEqualToString:@"NO"]&&[[waitInfo objectForKey:@"touch"]isEqualToString:@"NO"]&&(![[waitInfo objectForKey:@"text"]isEqualToString:@""]))
	{
		NSLog(@"each UI in touchExistText !!!!!!!!!!!!!  waitInfo is %@",waitInfo);	
		NSDictionary *widgetInfo = [NSDictionary dictionaryWithContentsOfFile:TOUCH_WIDGET];
	    NSString *widgetSet = [widgetInfo objectForKey:@"widgetSet"];
		if([widgetSet rangeOfString:[waitInfo objectForKey:@"check"]].location!=NSNotFound)
     	{
        	[simulatetouch_Center sendMessageName:@"simulatetouchText" userInfo:widgetInfo];
          	[waitInfo setValue:@"YES" forKey:@"touch"];
          	[waitInfo writeToFile:TOUCH_PREFERENCE atomically:YES];
     	}
     	else
     	{
        	  NSLog(@"each UI in touchExist check-text do not appear!!!");
     	}
	}			
}


//读取脚本
%new
-(void)readscript:(NSString *)type userInfo:(NSDictionary *)userInfo
{
	NSArray *array = [userInfo objectForKey:@"task"];
	//NSString *appBundle = [userInfo objectForKey:@"Bundle"];
	int count = [array count];
    action_count = count;
	//另开一个线程读取脚本，同步读脚本和点击的过程
	dispatch_queue_t read_queue = dispatch_queue_create("readscript", nil);
    dispatch_async(read_queue, ^{
	int count_temp=0;
	NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:@"NO",@"read",@"NO",@"touch",@"null",@"check",@"null",@"text",@"null",@"waitCount",@"null",@"waitTime",@"NO",@"back",nil];
	[dic writeToFile:TOUCH_PREFERENCE atomically:YES];
	while(count_temp < count)
	{
		//TOUCH_PREFERENCE里保存
		NSDictionary *waitInfo = [NSDictionary dictionaryWithContentsOfFile:TOUCH_PREFERENCE];
		if([[waitInfo objectForKey:@"read" ]isEqualToString:@"NO"] && count_temp !=0 )
		{	
			[NSThread sleepForTimeInterval:2];		
			continue;
		}
		NSLog(@"each UI in readscript count_temp: %d waitInfo is %@",count_temp,waitInfo);
		//读取一条动作指令
		actionInfo = [array[count_temp] copy];
		NSLog(@"each UI in readscript actionInfo is %@",actionInfo);
        [waitInfo setValue:@"NO" forKey:@"read"];
        [waitInfo setValue:@"NO" forKey:@"touch"];	
		[waitInfo setValue:[actionInfo objectForKey:@"waitTime"] forKey:@"waitTime"];
        [waitInfo setValue:[actionInfo objectForKey:@"waitCount"] forKey:@"waitCount"];
		if([[actionInfo objectForKey:@"type"]isEqualToString:@"click"])
		{
			if(![[actionInfo objectForKey:@"check"]isEqualToString:@""]) //按照控件点击
        	{
				[waitInfo setValue:[actionInfo objectForKey:@"text"] forKey:@"text"];
				[waitInfo setValue:[actionInfo objectForKey:@"check"] forKey:@"check"];
            	[waitInfo writeToFile:TOUCH_PREFERENCE atomically:YES];
            	NSLog(@"each UI send Script to viewDidAppear");
				NSLog(@"each UI read touch text waitInfo is %@",[NSDictionary dictionaryWithContentsOfFile:TOUCH_PREFERENCE]);
			    NSRunLoop *loop = [NSRunLoop currentRunLoop];
    			NSTimer *timer = [NSTimer  timerWithTimeInterval:3 target:self selector:@selector(touchExistText) userInfo:nil repeats:NO];
    			[loop addTimer:timer forMode:NSDefaultRunLoopMode];
    			[loop run];
        	}
        	else if(![[actionInfo objectForKey:@"x"]isEqualToString:@""]) //按照坐标点击
        	{
            	NSLog(@"each UI in read will simulateTouch point");
            	[NSThread sleepForTimeInterval:6];
				[waitInfo setValue:@"" forKey:@"text"];
                [waitInfo setValue:@"" forKey:@"check"];
            	NSDictionary *abs_point = [[NSDictionary alloc]initWithObjectsAndKeys:[actionInfo objectForKey:@"x"],@"xPoint",[actionInfo objectForKey:@"y"],@"yPoint",nil];
            	NSLog(@"each UI will simulateTouch abs_point is %@",abs_point);
         		[waitInfo writeToFile:TOUCH_PREFERENCE atomically:YES];
				NSLog(@"each UI read touch point waitInfo is %@",[NSDictionary dictionaryWithContentsOfFile:TOUCH_PREFERENCE]);
			   	[self performSelector:@selector(simulateTouchPoint:) withObject:abs_point];
        	}	
		}
		else if([[actionInfo objectForKey:@"type"]isEqualToString:@"swipe"])
		{
			NSLog(@"each UI in readscript in swipe!!!");
			[NSThread sleepForTimeInterval:6];
			[waitInfo setValue:@"" forKey:@"text"];
            [waitInfo setValue:@"" forKey:@"check"];
            NSDictionary *abs_point = [[NSDictionary alloc]initWithObjectsAndKeys:[actionInfo objectForKey:@"x1"],@"xPoint_from",[actionInfo objectForKey:@"x2"],@"xPoint_to",[actionInfo objectForKey:@"y1"],@"yPoint_from",[actionInfo objectForKey:@"y2"],@"yPoint_to",@"2.0",@"duration",nil];
            NSLog(@"each UI will simulateSwipe abs_point is %@",abs_point);
			[waitInfo writeToFile:TOUCH_PREFERENCE atomically:YES];
            NSLog(@"each UI read swipe waitInfo is %@",[NSDictionary dictionaryWithContentsOfFile:TOUCH_PREFERENCE]);
			[self performSelector:@selector(simulateSwipe:) withObject:abs_point];
		}
			count_temp ++;		
	}
	});
	
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



//跳转到某个app
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
- (void)simulateTouchPoint:(NSDictionary *)abs_point
{
	action_temp ++;
	NSDictionary *waitInfo = [NSDictionary dictionaryWithContentsOfFile:TOUCH_PREFERENCE];
	NSLog(@"each UI in simulateTouchPoint waitInfo is %@",waitInfo);
	[waitInfo setValue:@"NO" forKey:@"touch"];
    [waitInfo setValue:@"YES" forKey:@"read"];
    [waitInfo writeToFile:TOUCH_PREFERENCE atomically:YES];	
	CPDistributedMessagingCenter *touchPoint_Center = [CPDistributedMessagingCenter centerNamed:@"simulatetouch"];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f){
            //7.0+
                rocketbootstrap_distributedmessagingcenter_apply(touchPoint_Center);
        }
	[NSThread sleepForTimeInterval:1];
	[touchPoint_Center sendMessageName:@"simulatetouchDown" userInfo:abs_point];		
	[NSThread sleepForTimeInterval:3];
	[touchPoint_Center sendMessageName:@"simulatetouchUp" userInfo:abs_point];
	NSLog(@"each UI action_temp=%d !!! action_count=%d !!!",action_temp,action_count);
	if(action_temp == action_count)
    {
        [waitInfo setValue:@"YES" forKey:@"back"];
        NSLog(@"each UI write back YES to file");
        [waitInfo writeToFile:TOUCH_PREFERENCE atomically:YES];
        //有时候写文件会出错也不知道为啥，就先用这么一个笨办法再写一遍吧
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:TOUCH_PREFERENCE];
        NSLog(@"each UI finally TOUCH_PREFERENCE is %@",dict);
        if([[dict objectForKey:@"back"]isEqualToString:@"NO"])
        {
            [dict setValue:@"YES" forKey:@"back"];
        }
         [dict writeToFile:TOUCH_PREFERENCE atomically:YES];
        action_temp=0;
    }
    NSLog(@"each UI in simulateTouchPoint write read YES touch NO to preference");
}

%new
- (void)simulateSwipe:(NSDictionary *)abs_point
{
	action_temp++;
	NSLog(@"each UI in simulateSwipe!!!");
	NSDictionary *waitInfo = [NSDictionary dictionaryWithContentsOfFile:TOUCH_PREFERENCE];
    [waitInfo setValue:@"NO" forKey:@"touch"];
    [waitInfo setValue:@"YES" forKey:@"read"];
    [waitInfo writeToFile:TOUCH_PREFERENCE atomically:YES];
    CPDistributedMessagingCenter *swipe_Center = [CPDistributedMessagingCenter centerNamed:@"simulatetouch"];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f){
            //7.0+
                rocketbootstrap_distributedmessagingcenter_apply(swipe_Center);
        }
    [NSThread sleepForTimeInterval:1];
	[swipe_Center sendMessageName:@"simulateSwipe" userInfo:abs_point];
	NSLog(@"each UI action_temp=%d !!! action_count=%d !!!",action_temp,action_count);
}


%new
- (void)simulateTouchText:(NSString *)type userInfo:(NSDictionary *)userInfo
{
	action_temp ++;
	//获取一次点击操作
	NSDictionary *TouchAction = [actionInfo copy];
	NSLog(@"each UI in Text touch actionInfo is %@",TouchAction);
	//根据getAbsFrame方法获取指定控件的绝对坐标
	NSMethodSignature  *signature = [UIWindow instanceMethodSignatureForSelector:@selector(getAbsFrame:userInfo:actionInfo:)];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	//设置方法调用者
	invocation.target = [[UIApplication sharedApplication]keyWindow];
	//注意：这里的方法名一定要与方法签名类中的方法一致
	invocation.selector = @selector(getAbsFrame:userInfo:actionInfo:);
	//这里的Index要从2开始，以为0跟1已经被占据了，分别是self（target）,selector(_cmd)
	[invocation setArgument:&type atIndex:2];
	[invocation setArgument:&userInfo atIndex:3];
	[invocation setArgument:&TouchAction atIndex:4];
	 //3、调用invoke方法
   	[invocation invoke];
   	NSDictionary *res = nil;
    if (signature.methodReturnLength != 0) {//有返回值
      	//将返回值赋值给res
      	[invocation getReturnValue:&res];
      	}
	//根据返回值获取绝对坐标
   	NSDictionary *abs_point = res;
   	NSLog(@"each UI in if abs_point is %@",abs_point);
	//根据之前注册的方法实现控件点击
	CPDistributedMessagingCenter *get_absFrame_Center = [CPDistributedMessagingCenter centerNamed:@"simulatetouch"];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f){
            //7.0+
            	rocketbootstrap_distributedmessagingcenter_apply(get_absFrame_Center);
      	}

	NSDictionary *waitInfo = [NSDictionary dictionaryWithContentsOfFile:TOUCH_PREFERENCE];
    NSLog(@"each UI in simulateTouchText waitInfo is %@",waitInfo);
	[waitInfo setValue:@"NO" forKey:@"touch"];
    [waitInfo setValue:@"YES" forKey:@"read"];
    [waitInfo writeToFile:TOUCH_PREFERENCE atomically:YES];
	//创建一个同步线程队列是因为touch up可能会在touch down之前执行
	dispatch_queue_t touch_queue = dispatch_queue_create("touch", nil);
    dispatch_async(touch_queue, ^{	
	[NSThread sleepForTimeInterval:1];
	[get_absFrame_Center sendMessageName:@"simulatetouchDown" userInfo:abs_point];
    NSLog(@"each UI touchDown complete!");
	[NSThread sleepForTimeInterval:3];
    [get_absFrame_Center sendMessageName:@"simulatetouchUp" userInfo:abs_point];
	NSLog(@"each UI touchUp complete!");
	NSLog(@"each UI action_temp=%d !!! action_count=%d !!!",action_temp,action_count);
	if(action_temp == action_count)
    {
        [waitInfo setValue:@"YES" forKey:@"back"];
		NSLog(@"each UI write back YES to file");
		[waitInfo writeToFile:TOUCH_PREFERENCE atomically:YES];
		//有时候写文件会出错也不知道为啥，就先用这么一个笨办法再写一遍吧
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:TOUCH_PREFERENCE];
		NSLog(@"each UI finally TOUCH_PREFERENCE is %@",dict);
		if([[dict objectForKey:@"back"]isEqualToString:@"NO"])
		{
			[dict setValue:@"YES" forKey:@"back"];
		}
		 [dict writeToFile:TOUCH_PREFERENCE atomically:YES];
		action_temp=0;
    }
	NSLog(@"each UI in simulateTouchText  write read YES touch NO to preference");
	//有时候写文件会出错也不知道为啥，就先用这么一个笨办法再写一遍吧
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:TOUCH_PREFERENCE];
        NSLog(@"each UI after touch text TOUCH_PREFERENCE is %@",dict);
        if([[dict objectForKey:@"read"]isEqualToString:@"NO"])
        {
            [dict setValue:@"YES" forKey:@"read"];
        }
         [dict writeToFile:TOUCH_PREFERENCE atomically:YES];
 });
}

%new
- (void)simulateTouch:(NSString *)type userInfo:(NSDictionary *)userInfo
{
    NSLog(@"*************each UI Touch type = %@***********",type);
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
            NSLog(@"each UI  iOSREError: Simutale touch down failed at (%f, %f).\n",x,y);
        }
        NSLog(@"each UI in touchDown xPoint = %@ ,yPoint = %@",xPoint,yPoint);

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
            NSLog(@"each UI iOSREError: Simutale touch up failed at (%f, %f).\n",x,y);
        }
        NSLog(@"each UI in touchUP xPoint = %@ ,yPoint = %@",xPoint,yPoint);

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

