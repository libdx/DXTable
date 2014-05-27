//
//  DXTableObserver.h
//  Pieces
//
//  Created by Alexander Ignatenko on 27/05/14.
//  Copyright (c) 2014 Alexander Ignatenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DXTableModel, DXTableRow;
@protocol DXTableObserverDelegate;

// TODO: pickup better name
// possible names are DXTableBinder[Helper] DXTableObser[er][Helper]
@interface DXTableObserver : NSObject

@property (nonatomic, weak) id<DXTableObserverDelegate> delegate;

- (void)startObservingTableModel:(DXTableModel *)tableModel inDataContext:(id)dataContext;
- (void)setupBindingsForCell:(UITableViewCell *)cell atRow:(DXTableRow *)row inDataContext:(id)dataContext;

@end

@protocol DXTableObserverDelegate <NSObject>

@optional
- (void)tableObserver:(DXTableObserver *)observer
    didObserveActivityChange:(BOOL)active
                      forRow:(DXTableRow *)row
                 atIndexPath:(NSIndexPath *)indexPath;

@end
