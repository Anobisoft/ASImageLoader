//
//  ASImageLoaderTests.m
//  ASImageLoaderTests
//
//  Created by Anobisoft on 08/02/2017.
//  Copyright (c) 2017 Anobisoft. All rights reserved.
//

@import XCTest;
#import <ASImageLoader/AKTheme.h>

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp {
    [super setUp];

}

- (void)tearDown {
    [super tearDown];
}

- (void)testExample {
    NSUInteger count = [AKTheme allNames].count;
    XCTAssertEqual(count, 3, @"count (%lu) equal to 3", (unsigned long)count);
}

@end

