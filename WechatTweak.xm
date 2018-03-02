#import "Ourhdr.h"
#define WECHATTASKPATH @"/var/mobile/Library/Preferences/com.softsec.wechatTask.plist"
#define RECEIVEDWECHATPATH @"/var/mobile/Library/Preferences/com.softsec.wechatlog.plist"


@class NSMutableDictionary, NSRecursiveLock;
///CPDistributedMessagingCenter////

@interface CMessageWrap:NSObject
-(id)m_nsContent; 
- (id)initWithMsgType:(long long)arg1;
- (id)init;
@property(retain, nonatomic) NSString *m_nsToUsr;
@property(retain, nonatomic) NSString *m_nsFromUsr;
@property(retain, nonatomic) NSString *m_nsContent;
@end

@interface MMServiceCenter : NSObject
+ (id)defaultCenter;
- (id)getService:(Class)arg1;
- (id)init;
@end

@interface CMessageMgr:NSObject
- (void)AddMsg:(id)arg1 MsgWrap:(id)arg2;
@end

//d

%hook MicroMessengerAppDelegate

- (void)applicationWillEnterForeground:(id)arg1
{

    %orig;
    
    NSLog(@"******************applicationWillEnterForeground wechat************* ");
    //NSString *Recipient = @"wxj1992hs";
    //NSString *Body = @"hello";

    //NSLog(@"发送给%@:%@ ",Recipient,Body);

    NSLog(@"file%@ exist = %d",WECHATTASKPATH,[[NSFileManager defaultManager] fileExistsAtPath:WECHATTASKPATH]);
    NSArray *arraytmp = [[NSDictionary dictionaryWithContentsOfFile:WECHATTASKPATH] objectForKey:@"wechatTaskDetail"];

    NSLog(@"  detail = %@",arraytmp);
    
    int countWechat = [arraytmp count];


    int i;
    for(i=0;i<countWechat;i++)
    {
        NSDictionary *userInfo  = [arraytmp objectAtIndex:i];
        

    //NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:Recipient,@"recipient",Body,@"body",nil];
    
         NSLog(@"************* send wechat *****************");

         NSString *body = [userInfo objectForKey:@"body"];
    	 NSString *recipient = [userInfo objectForKey:@"recipient"];
         CMessageWrap *messagewrap = [[%c(CMessageWrap) alloc] initWithMsgType:1];
         [messagewrap setM_nsFromUsr:@"wuxj0412"];
         [messagewrap setM_nsContent:body];
         [messagewrap setM_nsToUsr:recipient];

        NSLog(@"****  wechat body = %@ ****",body);
        NSLog(@"****  wechat recipient = %@ ****",recipient);

        CMessageMgr * messagemgr = [[%c(MMServiceCenter) defaultCenter] getService:[%c(CMessageMgr) class]];
        [messagemgr AddMsg:recipient MsgWrap:messagewrap];
    }

}

%end


%hook CMessageMgr


- (void)MainThreadNotifyToExt:(id)arg1
{
    %orig;
    NSLog(@"*************************************");

    //NSString *content = [(CMessageWrap *)arg1 m_nsContent];
    //NSLog(@"****** get WeChat Message  :%@ ******",arg1);
    //NSDictionary *preference = [NSDictionary dictionaryWithContentsOfFile:PATH_PREFERENCE];

    if([arg1 objectForKey:@"3"]&&[arg1 objectForKey:@"2"])
    {
        NSString *anotherUser = [arg1 objectForKey:@"2"];
        NSLog(@"****** get WeChat Message anotherUser :%@ ******",anotherUser);
        NSLog(@"****** get WeChat Message content :%@ ******",[(CMessageWrap *)[arg1 objectForKey:@"3"] m_nsContent]);
        NSLog(@"****** get WeChat Message fromusr :%@ ******",[(CMessageWrap *)[arg1 objectForKey:@"3"] m_nsFromUsr]);
        NSLog(@"****** get WeChat Message tousr :%@ ******",[(CMessageWrap *)[arg1 objectForKey:@"3"] m_nsToUsr]);

        NSString *body = [(CMessageWrap *)[arg1 objectForKey:@"3"] m_nsContent];
        NSString *sender = [(CMessageWrap *)[arg1 objectForKey:@"3"] m_nsFromUsr];
        //NSString *recipent = [(CMessageWrap *)[arg1 objectForKey:@"3"] m_nsToUsr];

        UInt64 time2 = [[NSDate date] timeIntervalSince1970]*1000;
        NSString *time = [NSString stringWithFormat:@"%llu",time2];

        if([body rangeOfString:@"mission_id"].location != NSNotFound && ![sender isEqualToString:@""] && sender != NULL && [anotherUser isEqualToString:sender])
        {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
            NSDictionary *message_detail = [NSDictionary dictionaryWithObjectsAndKeys:sender,@"SendNum",time,@"receiveTime",body,@"text",nil];
    
            //写入plist
    	    if( (![[NSFileManager defaultManager] fileExistsAtPath:RECEIVEDWECHATPATH])||
                ([[NSDictionary dictionaryWithContentsOfFile:RECEIVEDWECHATPATH] objectForKey:@"wechatDetail"]==NULL) ){
    
        	    array = [NSMutableArray arrayWithObjects:message_detail,nil];
        	    NSDictionary *message_log = [NSDictionary dictionaryWithObjectsAndKeys:array,@"wechatDetail",nil];

        	    [message_log writeToFile:RECEIVEDWECHATPATH atomically:YES];
        	}else
	        {
                array = [[NSMutableDictionary dictionaryWithContentsOfFile:RECEIVEDWECHATPATH] objectForKey:@"wechatDetail"];

	    	    [array addObject:message_detail];

		    	NSMutableDictionary *message_log = [NSMutableDictionary dictionaryWithContentsOfFile:RECEIVEDWECHATPATH];
			    [message_log setValue:array forKey:@"wechatDetail"];

			    [message_log writeToFile:RECEIVEDWECHATPATH atomically:YES];


	         }

        }

    }

}


%end


    
