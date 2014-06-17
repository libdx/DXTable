//
//  DXTableObserver.h
//  Pieces
//
//  Created by Alexander Ignatenko on 27/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DXTableModel, DXTableRow;
@protocol DXTableObserverDelegate;

// FIXME: redesign this class it is mess of code

// TODO: pickup better name
// possible names are DXTableBinder[Helper] DXTableObser[er][Helper]
@interface DXTableObserver : NSObject

@property (nonatomic, weak) id<DXTableObserverDelegate> delegate;

- (void)startObservingTableModel:(DXTableModel *)tableModel inDataContext:(id)dataContext;
- (void)setupBindingsForCell:(UITableViewCell *)cell atRow:(DXTableRow *)row inDataContext:(id)dataContext;

@end

typedef NS_ENUM(NSInteger, DXTableObserverChangeType) {
    DXTableObserverChangeInsert = 1,
    DXTableObserverChangeDelete,
    DXTableObserverChangeMove,
    DXTableObserverChangeUpdate
};

@protocol DXTableObserverDelegate <NSObject>

@optional
- (void)tableObserver:(DXTableObserver *)observer
  didObserveRowChange:(DXTableRow *)row
         atIndexPaths:(NSArray *)indexPaths
        forChangeType:(DXTableObserverChangeType)changeType
        newIndexPaths:(NSArray *)newIndexPaths;

@end
