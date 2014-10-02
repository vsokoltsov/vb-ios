//
//  APIConnect.m
//  voenbank
//
//  Created by vsokoltsov on 30.09.14.
//  Copyright (c) 2014 vsokoltsov. All rights reserved.
//

#import "APIConnect.h"

#define MAIN_URL [NSURL URLWithString:@"http://localhost:3000/api"]



@implementation APIConnect

@synthesize completed = _completed;
@synthesize errored = _errored;

- (void)getData:(NSString *)url params: (NSString *) params success: (requestCompletedBlock) completed{
    self.completed = completed;
    NSURL *finalURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", MAIN_URL, url]];
    NSData *postData = [params dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    //// создаем объект NSURLRequest - запрос
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:finalURL];
    request.HTTPMethod = @"POST";
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(connection)
    {
        userData = [NSMutableData data];
    }
    else
    {
        NSLog(@"Connection failed");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [userData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *result = [[NSString alloc] initWithData:userData encoding:NSUTF8StringEncoding];
//    NSLog(@"result is %@", result);
    if([result isEqualToString:@"null"])
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"ОШИБКА"
                              message:@"Пользователя с такими данными не существует"
                              delegate:self
                              cancelButtonTitle: @"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    else{
    id jsonObject = [NSJSONSerialization JSONObjectWithData:userData options:NSJSONReadingMutableContainers error:nil];
//        [self setUserData:result];
        self.completed(jsonObject);
    }
}

-(void) setUserData: (NSString *) params{
    self.dataFromServer = params;
}
@end
