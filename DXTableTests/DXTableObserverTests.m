//
//  DXTableObserverTests.m
//  DXTable
//
//  Created by Alexander Ignatenko on 08/07/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "DXTableObserver.h"

typedef void (^BlockObserverDelegateRowChange)
(DXTableObserver *, DXTableRow *, NSArray *, DXTableObserverChangeType, NSArray *);

typedef void (^BlockObserverDelegateSectionChange)
(DXTableObserver *, DXTableSection *, NSIndexSet *, DXTableObserverChangeType, NSIndexSet *);

@interface BlockObserverDelegate : NSObject <DXTableObserverDelegate>

@property (nonatomic, copy) BlockObserverDelegateRowChange rowChange;
@property (nonatomic, copy) BlockObserverDelegateSectionChange sectionChange;

@end

@implementation BlockObserverDelegate

- (void)tableObserver:(DXTableObserver *)observer
  didObserveRowChange:(DXTableRow *)row
         atIndexPaths:(NSArray *)indexPaths
        forChangeType:(DXTableObserverChangeType)changeType
        newIndexPaths:(NSArray *)newIndexPaths
{
    if (self.rowChange)
        self.rowChange(observer, row, indexPaths, changeType, newIndexPaths);
}

- (void)tableObserver:(DXTableObserver *)observer
didObserveSectionChange:(DXTableSection *)section
            atIndexes:(NSIndexSet *)indexes
        forChangeType:(DXTableObserverChangeType)changeType
           newIndexes:(NSIndexSet *)newIndexes
{
    if (self.sectionChange)
        self.sectionChange(observer, section, indexes, changeType, newIndexes);
}


@end

@interface DXTableObserverTests : XCTestCase

@property (nonatomic) DXTableObserver *observer;
@property (nonatomic) BlockObserverDelegate *delegate;

@end

@implementation DXTableObserverTests

- (void)setUp
{
    [super setUp];
    self.observer = [[DXTableObserver alloc] init];
    self.delegate = [[BlockObserverDelegate alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testExample
{

}

@end
