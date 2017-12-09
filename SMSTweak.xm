

#import "Ourhdr.h"

#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCall.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AddressBook/AddressBook.h>

extern "C" CFStringRef MCCTPhoneNumber();

@interface NSConcreteNotification : NSNotification
-(id) object;
@end






%hook SMSApplication
/*
%new
- (int)madridStatusForAddress:(NSString *)address
{
	NSString *formattedAddress = nil;
	if ([address rangeOfString:@"@"].location != NSNotFound) formattedAddress = [@"mailto:" stringByAppendingString:address];
	else formattedAddress = [@"tel:" stringByAppendingString:address];
	NSDictionary *status = [[IDSIDQueryController sharedInstance] _currentIDStatusForDestinations:@[formattedAddress] service:@"com.apple.madrid" listenerID:@"__kIMChatServiceForSendingIDSQueryControllerListenerID"];
	return [status[formattedAddress] intValue];
}

%new
- (void)sendMadridMessageToAddress:(NSString *)address withInfo:(NSDictionary *)userInfo
{
	NSString *body = [userInfo objectForKey:@"body"];
	NSString *recipient_tmp = [userInfo objectForKey:@"recipient"];
    NSLog(@"-----------  in send sms  %@ to %@  -----------",body,recipient_tmp);

	IMServiceImpl *service = [IMServiceImpl smsService];
	IMAccount *account = [[IMAccountController sharedInstance] __ck_defaultAccountForService:service];
	IMHandle *handle = [account imHandleWithID:recipient_tmp alreadyCanonical:NO];
	IMChat *chat = [[IMChatRegistry sharedInstance] chatForIMHandle:handle];
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:body];
	IMMessage *message = [IMMessage instantMessageWithText:attributedString flags:1048581];
	[chat sendMessage:message];
	[attributedString release];
}
*/

-(id)init
{
	id ret = %orig;

	CPDistributedMessagingCenter *center_sms = [CPDistributedMessagingCenter centerNamed:@"com.lw.server_sms"] ;
	////////////////////////////7.0+////////////////////////////////////
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f){

		rocketbootstrap_distributedmessagingcenter_apply(center_sms);
	}
	////////////////////////////////////////////////////////////////////
	[center_sms runServerOnCurrentThread];
   // [center_sms registerForMessageName:@"sendsms" target:self selector:@selector(sendMadridMessageToAddress:withInfo:)];
	[center_sms registerForMessageName:@"sendsms" target:self selector:@selector(sendsms:userInfo:)];



	NSLog(@"短信服务器开启 in MobileSMS, %@",[[NSBundle mainBundle] bundleIdentifier]);


	CPDistributedMessagingCenter *center_mms = [CPDistributedMessagingCenter centerNamed:@"com.lw.server_mms"] ;
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f){

		rocketbootstrap_distributedmessagingcenter_apply(center_mms);
	}
	[center_mms runServerOnCurrentThread];
	[center_mms registerForMessageName:@"sendmms" target:self selector:@selector(sendmms:userInfo:)];



	return ret;
}


%new
- (void)sendsms:(NSString *)name userInfo:(NSDictionary *)userInfo
{

	//sendSMS
   // [[UIApplication sharedApplication]launchApplicationWithIdentifier:@"com.apple.MobileSMS" suspended:YES];

	NSString *body = [userInfo objectForKey:@"body"];
	NSString *recipient_tmp = [userInfo objectForKey:@"recipient"];
    NSLog(@"-----------  in send sms  %@ to %@  -----------",body,recipient_tmp);
    if(![recipient_tmp hasPrefix:@"+86"])
    {
        recipient_tmp = [NSString stringWithFormat:@"+86%@",recipient_tmp];
    }
    //Get the shared conversation list
    CKConversationList* conversationList = [CKConversationList sharedConversationList];
    //Get the conversation for an address
    IMServiceImpl *service = [IMServiceImpl smsService];
	IMAccount *account = [[IMAccountController sharedInstance] __ck_defaultAccountForService:service];
	IMHandle *handle = [account imHandleWithID:recipient_tmp alreadyCanonical:NO];
	IMChat *chat = [[IMChatRegistry sharedInstance] chatForIMHandle:handle];
    CKConversation *conversation = [conversationList _conversationForChat:chat ]; 
       
 
    //Make a new composition
    NSAttributedString* text = [[NSAttributedString alloc] initWithString:body];
    CKComposition* composition = [[CKComposition alloc] initWithText:text subject:nil];

       // NSLog(@"text = %@  composition =%@",text,composition);
    //A new message from the composition
    IMMessage* message = [conversation messageWithComposition:composition];
  //  NSLog(@"message  = %@",message);
    //And finally, send the message in the conversation
    [conversation sendMessage:message newComposition:YES];
    NSLog(@"-----------  send sms finished    ------------");
}


%new
- (void)sendmms:(NSString *)name userInfo:(NSDictionary *)userInfo
{

    NSLog(@"-----------  in send mms  -----------");

    NSString *body = [userInfo objectForKey:@"body"];
	NSString *recipient_tmp = [userInfo objectForKey:@"recipient"];
    NSString *subject_tmp = [userInfo objectForKey:@"subject"];
    NSString *ImagePath = [userInfo objectForKey:@"ImagePath"];

    NSLog(@"-----------  in send mms  %@ to %@ with subject:%@ 附件%@ -----------",body,recipient_tmp,subject_tmp,ImagePath);
    if(![recipient_tmp hasPrefix:@"+86"])
    {
        recipient_tmp = [NSString stringWithFormat:@"+86%@",recipient_tmp];
    }
    //Get the shared conversation list
    CKConversationList* conversationList = [CKConversationList sharedConversationList];
    //Get the conversation for an address
    IMServiceImpl *service = [IMServiceImpl smsService];
	IMAccount *account = [[IMAccountController sharedInstance] __ck_defaultAccountForService:service];
	IMHandle *handle = [account imHandleWithID:recipient_tmp alreadyCanonical:NO];
	IMChat *chat = [[IMChatRegistry sharedInstance] chatForIMHandle:handle];
    CKConversation *conversation = [conversationList _conversationForChat:chat ]; 
       

    //Make a new composition
     NSAttributedString* text = [[NSAttributedString alloc] initWithString:body];
    NSAttributedString* subject = [[NSAttributedString alloc] initWithString:subject_tmp];

    CKComposition* composition = [[CKComposition alloc] initWithText:text subject:subject];

    if([[NSFileManager defaultManager] fileExistsAtPath:ImagePath])
    {
        NSLog(@"附件存在");
        //添加附件
        NSData* data = [NSData dataWithContentsOfFile:ImagePath];
        CKMediaObject *mediaObject = [[CKMediaObjectManager sharedInstance]mediaObjectWithData:data UTIType:[[IMFileManager defaultHFSFileManager] UTITypeOfPath:ImagePath] filename:nil transcoderUserInfo:nil];

    //NSArray *mediaObjects = [NSArray arrayWithObjects:mediaObject,mediaObject, nil];

    //NSLog(@"mediaobjects = %@",mediaObjects);
    //composition = [composition compositionByAppendingMediaObjects:mediaObjects];
        composition = [composition compositionByAppendingMediaObject:mediaObject];
    }
    else
    {
        NSLog(@"附件不存在");
    }

    //A new message from the composition
    IMMessage* message = [conversation messageWithComposition:composition];
  //  NSLog(@"message  = %@",message);
    //And finally, send the message in the conversation
    [conversation sendMessage:message newComposition:YES];
    


    /*
    NSString *body = [userInfo objectForKey:@"body"];
	NSString *recipient = [userInfo objectForKey:@"recipient"];
    NSString *subject_tmp = [userInfo objectForKey:@"subject"];
    NSLog(@"-----------  in send mms  %@ to %@ with subject:%@ -----------",body,recipient,subject_tmp);
    
    NSAttributedString* subject = [[NSAttributedString alloc] initWithString:subject_tmp];


    NSData *data = nil;
    CKMediaObject *mediaObject = nil;
    //CKMediaObjectMessagePart *messagePart = nil;

    NSString *ImagePath = MMSATTACHPATH;
    //    NSString *body = [userInfo objectForKey:@"body"];

    //make entities
    CKEntity *imentity = [CKEntity copyEntityForAddressString:recipient];
    NSArray *recipient_arra = [[NSArray alloc]initWithObjects:imentity, nil];

    //make composition from an address
    data = [NSData dataWithContentsOfFile:ImagePath];
    mediaObject = [[CKMediaObjectManager sharedInstance]mediaObjectWithData:data UTIType:[[IMFileManager defaultHFSFileManager] UTITypeOfPath:ImagePath] filename:nil transcoderUserInfo:nil];
   // messagePart = [[CKMediaObjectMessagePart alloc] initWithMediaObject:mediaObject];
    CKComposition *composition = [CKComposition compositionWithMediaObject:mediaObject subject:subject];

    //make conversation
    CKConversationList *conversationList = [CKConversationList sharedConversationList];
    CKConversation *conversation = [conversationList conversationForRecipients:recipient_arra create:YES];

    //new message
    CKIMMessage *message = [conversation newMessageWithComposition:composition addToConversation:YES];
    [conversation addMessage:message];

    //send message

    [conversation sendMessage:message newComposition:YES];

    */
       }


%end

%hook IMDServiceSession
- (void)didReceiveMessage:(id)arg1 forChat:(id)arg2 style:(unsigned char)arg3{


      %orig;//注释掉就无法收到短信了
    
//-----------------------------提取信息的发件人和文本内容-----------------------------------//
   //   NSString *sender = [(FZMessage*)arg1 sender];
    //  NSString *body   = [[(FZMessage*)arg1 body] string];
     // NSString *receiveNumber = (__bridge NSString *)MCCTPhoneNumber();

      //NSString *str = [[NSString alloc] initWithFormat:@"1%@向%@发送了：\n%@\n",sender,receiveNumber,body];
      //NSString *str = [[NSString alloc] initWithFormat:@"发送短信@LW@%s@LW@%s@LW@%s@LW@%s@LW@%s@LW@%s@LW@%s",sender,receiveNumber,body];
      //NSString * content = [str stringByAppendingString:@"\r\n"];
    //  NSLog(@"%@",content);
     // SocketClass *mySocket = [[SocketClass alloc] init];
     // [mySocket SendSocket:content];

    NSLog(@" ----------- in receive SMS !!!!!! ------------,%@",[[NSBundle mainBundle] bundleIdentifier]);

    NSString *body = [[(FZMessage*)arg1 body] string];
    NSString *subject = [(FZMessage*)arg1 subject];
	NSString *sender = [(FZMessage*)arg1 sender];
    NSArray *fileTransferGUIDs = [(FZMessage*)arg1 fileTransferGUIDs];
    
    //NSLog(@"orig_sender = %@",sender);
    UInt64 time2 = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *time = [NSString stringWithFormat:@"%llu",time2];

   // NSLog(@"time = %@  timeD = %@", time,time_delivered);
    NSLog(@"body=|%@|",body);
    NSLog(@"subject=|%@|",subject);
    NSLog(@"fileTransferGUIDs = |%@|",fileTransferGUIDs);
    

    if([body rangeOfString:@"id"].location != NSNotFound && [body rangeOfString:@"text"].location != NSNotFound &&  ![sender isEqualToString:@""] && sender != NULL)
    {

         //统一sender格式
    	NSMutableString *numberString = [[NSMutableString alloc] init];
    	NSString *tempStr;
    	NSScanner *scanner = [NSScanner scannerWithString:sender];
    	NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];

    	while (![scanner isAtEnd])
    	{
	    	// Throw away characters before the first number.
	    	[scanner scanUpToCharactersFromSet:numbers intoString:NULL];

	    	// Collect numbers.
	    	[scanner scanCharactersFromSet:numbers intoString:&tempStr];
	    	[numberString appendString:tempStr];
	    	tempStr = @"";
    	}
    	sender = numberString;
    	if([sender hasPrefix:@"86"])
    	{
    		sender = [sender substringFromIndex:2];
    	}


	    NSLog(@"time = %@ body = %@  sender = %@ ",time,body,sender);
    	NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];

        NSDictionary *message_detail = [NSDictionary dictionaryWithObjectsAndKeys:sender,@"SendNum",time,@"receiveTime",body,@"text",nil];
    
        if(subject||[fileTransferGUIDs count]>0)//判断为彩信
        {
             	//写入plist
    	    if( (![[NSFileManager defaultManager] fileExistsAtPath:RECEIVEDMMSPATH])||
                ([[NSDictionary dictionaryWithContentsOfFile:RECEIVEDMMSPATH] objectForKey:@"mmsDetail"]==NULL) ){
    
        	    array = [NSMutableArray arrayWithObjects:message_detail,nil];
        	    NSDictionary *message_log = [NSDictionary dictionaryWithObjectsAndKeys:array,@"mmsDetail",nil];

        	    [message_log writeToFile:RECEIVEDMMSPATH atomically:YES];
    	    }else
	        {
                 array = [[NSMutableDictionary dictionaryWithContentsOfFile:RECEIVEDMMSPATH] objectForKey:@"mmsDetail"];

	    	    [array addObject:message_detail];

	            //NSLog(@"array = %@",array);

			    NSMutableDictionary *message_log = [NSMutableDictionary dictionaryWithContentsOfFile:RECEIVEDMMSPATH];
			    [message_log setValue:array forKey:@"mmsDetail"];

		    	[message_log writeToFile:RECEIVEDMMSPATH atomically:YES];
            }

        }
        else//判断为短信
        {
            //写入plist
    	    if( (![[NSFileManager defaultManager] fileExistsAtPath:RECEIVEDSMSPATH])||
                ([[NSDictionary dictionaryWithContentsOfFile:RECEIVEDSMSPATH] objectForKey:@"smsDetail"]==NULL) ){
    
        	    array = [NSMutableArray arrayWithObjects:message_detail,nil];
        	    NSDictionary *message_log = [NSDictionary dictionaryWithObjectsAndKeys:array,@"smsDetail",nil];

        	    [message_log writeToFile:RECEIVEDSMSPATH atomically:YES];
        	}else
	        {
                array = [[NSMutableDictionary dictionaryWithContentsOfFile:RECEIVEDSMSPATH] objectForKey:@"smsDetail"];

	    	    [array addObject:message_detail];

	            //NSLog(@"array = %@",array);

		    	NSMutableDictionary *message_log = [NSMutableDictionary dictionaryWithContentsOfFile:RECEIVEDSMSPATH];
			    [message_log setValue:array forKey:@"smsDetail"];

			    [message_log writeToFile:RECEIVEDSMSPATH atomically:YES];


	    }

        }
    }
    else
    {
        NSLog(@"格式错误");    
    }

    }

%end
/*
%hook CKComposition
+(id)compositionForMessageParts:(id)arg1
{
    %orig;
    NSLog(@" compositionForMessageParts arg1=%@, class= %@",arg1,[arg1 class]);
}
%end
*/

%ctor{

    NSString *processName = [[NSProcessInfo processInfo] processName];
    if(![processName isEqualToString:@"imagent"]){
    
        return;
    }
}


