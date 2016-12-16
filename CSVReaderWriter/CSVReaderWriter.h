//
//  CSVReaderWriter.h
//  CSVReaderWriter
//
//  Created by Hungju Lu on 14/12/2016.
//  Copyright © 2016 Hungju. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 File mode for opening a csv file

 - FileModeRead: supports reading contents
 - FileModeWrite: supports writing contents
 */
typedef NS_ENUM(NSUInteger, FileMode) {
    FileModeRead = 1,
    FileModeWrite = 2
};

@interface CSVReaderWriter : NSObject

// - Added documentation on the interface

/**
 Opens the file and keeps the reference for read / write use.

 @param path The path of the file.
 @param mode The mode for the file.
 */
- (void)open:(NSString*)path mode:(FileMode)mode;

/**
 Read one line and store the data from column 1 and column 2 into given
 NSString reference.
 
 @note This method is deprecated, please use readLineTo: instead.

 @param column1 NSString reference for storing the data from 1st column.
 @param column2 NSString reference for storing the data from 2nd column.
 @return Reading successful.
 */
- (BOOL)read:(NSMutableString* __autoreleasing *)column1
     column2:(NSMutableString* __autoreleasing *)column2
__attribute__((deprecated("Use readLineTo: instead")));

/**
 Read one line and store all the columns into a given NSMutableArray.
 
 @note This method is deprecated, please use readLineTo: instead.
 
 @param columns NSMutableArray to store all the column data.
 @return Reading successful.
 */
- (BOOL)read:(NSMutableArray*)columns
__attribute__((deprecated("Use readLineTo: instead")));

/**
 Read one line and store all the columns into a given NSMutableArray.
 
 @param columns NSMutableArray to store all the column data.
 @return Reading successful.
 */
- (BOOL)readLineTo:(NSMutableArray *)columns;

/**
 Write a column data to the end of file.
 
 @note This method is deprecated, please use writeLineWith: instead.

 @param columns The data for all columns
 */
- (void)write:(NSArray*)columns
__attribute__((deprecated("Use writeLineWith: instead")));

/**
 Write a column data to the end of file.
 
 @param columns The data for all columns
 */
- (void)writeLineWith:(NSArray*)columns;

/**
 Close the file.
 */
- (void)close;

@end
