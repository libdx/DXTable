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

@interface DXTableObserver : NSObject

@property (nonatomic, weak) id<DXTableObserverDelegate> delegate;

// TODO: make a few small specialized methods instead of these huge ones
- (void)startObservingTableModel:(DXTableModel *)tableModel inDataContext:(id)dataContext;
- (void)setupBindingsForCell:(UITableViewCell *)cell row:(DXTableRow *)row atIndexPath:(NSIndexPath *)indexPath inDataContext:(id)dataContext;

@end

typedef NS_ENUM(NSInteger, DXTableObserverChangeType) {
    DXTableObserverChangeInsert = 1,
    DXTableObserverChangeDelete,
    DXTableObserverChangeMove,
    DXTableObserverChangeUpdate,
    DXTableObserverChangeSetting
};

@protocol DXTableObserverDelegate <NSObject>

@optional

- (void)tableObserver:(DXTableObserver *)observer
  didObserveRowChange:(DXTableRow *)row
         atIndexPaths:(NSArray *)indexPaths
        forChangeType:(DXTableObserverChangeType)changeType
        newIndexPaths:(NSArray *)newIndexPaths;

// TODO: add same method for section changes

@end
