//
//  ChatTests.m
//  ChatTests
//
//  Created by Filippos Zampounis on 13/09/16.
//
//

#import <XCTest/XCTest.h>
#import "BotService.h"
#import "Buddy.h"
#import <OCMock/OCMock.h>

@interface BotService (MyPrivateMethodsUsedForTesting)
@property(nonatomic,strong) NSString *botId;
@property(nonatomic,strong) NSString *botcust2;
- (void) sendRequestFromURL: (NSString *) url completion:(void (^)(NSString *, NSError *))mockSuccessBlockWithOneArgumentTwoBlocks postData:(NSString *)postData;
@end

@interface ChatTests : XCTestCase
@property (nonatomic) BotService *botService;
@property (nonatomic) Buddy *buddy;
@property (nonatomic) NSString *content;
@end

@implementation ChatTests

- (void)setUp {
    [super setUp];
    self.botService = [[BotService alloc] init];
    self.buddy = [[Buddy alloc]init];
    self.content = @"<iframe src=\"http://sheepridge.pandorabots.com/pandora/talk?botid=b69b8d517e345aba&skin=custom_input\" width=\"600\" height=\"1000\" frameborder=\"0\">";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testinitWithBuddy {
    [self.botService initWithBuddy:self.buddy];
    
    XCTAssertEqualObjects(self.buddy, self.botService.buddy, @"buddy is not the initilized one");
}

- (void)testThatWeFetchProperPandoraURL;
{
    NSString *url = @"https://alice.pandorabots.com";
    XCTestExpectation *expectation = [self expectationWithDescription:@"GET https://alice.pandorabots.com"];
    [self.botService sendRequestFromURL:url completion:^(NSString *result, NSError *error){
        [expectation fulfill];
        XCTAssertNotNil(result, @"result should not be nill");
        XCTAssertNil(error, @"error should be nill");
    } postData:nil];
    
    [self.botService startTheBot];
    
    [self waitForExpectationsWithTimeout:30 handler:nil];
}


@end
