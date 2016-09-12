#import <Foundation/Foundation.h>


@interface NSObject (NSObjectAdditions)

// replacement for new that does autorelease
+(NSArray*)declaredProperties;
-(NSArray*)declaredProperties;

@end
