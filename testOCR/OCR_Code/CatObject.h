//
//  CatObject.h
//  testOCR
//
//  Created by Dave Scruton on 12/19/18.
//  Copyright © 2018 huedoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatObject : NSObject
{
    
}
@property (nonatomic , strong) NSString* category;
@property (nonatomic , strong) NSString* item;
@property (nonatomic , strong) NSString* processed;
@property (nonatomic , strong) NSString* local;
@property (nonatomic , assign) BOOL isProcessed;
@property (nonatomic , assign) BOOL isLocal;

- (id) initWithCategory : (NSString*) c : (NSString*) i : (NSString*) p : (NSString*) l;


@end

