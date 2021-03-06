//
//  DXTableObserver.h
//  Pieces
//
//  Created by Alexander Ignatenko on 27/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DXTableModel, DXTableSection, DXTableRow, DXTableItem;
@protocol DXTableObserverDelegate;

@interface DXTableObserver : NSObject

@property (nonatomic, weak) id<DXTableObserverDelegate> delegate;

// TODO: make a few small specialized methods instead of these huge ones
- (void)startObservingTableModel:(DXTableModel *)tableModel;
- (void)stopObserving;
- (void)setupBindingsForCell:(UITableViewCell *)cell row:(DXTableRow *)row atIndexPath:(NSIndexPath *)indexPath;
- (void)setupBindingsForView:(UIView *)view item:(DXTableItem *)item inDataContext:(id)dataContext;

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

- (void)tableObserver:(DXTableObserver *)observer
didObserveSectionChange:(DXTableSection *)section
            atIndexes:(NSIndexSet *)indexes
        forChangeType:(DXTableObserverChangeType)changeType
           newIndexes:(NSIndexSet *)newIndexes;

@end
