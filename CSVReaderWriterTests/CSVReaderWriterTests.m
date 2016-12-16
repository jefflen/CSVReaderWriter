//
//  CSVReaderWriterTests.m
//  CSVReaderWriterTests
//
//  Created by Hungju Lu on 14/12/2016.
//  Copyright © 2016 Hungju. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CSVReaderWriter/CSVReaderWriter.h>

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

static NSString * SampleCSVFileName = @"Sample-Spreadsheet-5000-rows";
static NSUInteger SampleCSVRowCount = 5000;
static NSString * CSVExtensionName = @"csv";
static NSString * TestWritingFileName = @"Test.csv";

#define TestWritingData \
  @[@[@(1), @"Eldon Base for stackable storage shelf"], \
    @[@(2), @"1.7 Cubic Foot Compact"], \
    @[@(3), @"Cardinal Slant-D® Ring Binder,  Heavy Gauge Vinyl"], \
    @[@(4), @"R380, Clay Rozendal"], \
    @[@(5), @"Holmes HEPA Air Purifier, Carlos Soltero"], \
    @[@(6), @"G.E. Longer-Life Indoor Recessed Floodlight Bulbs, Carlos Soltero"], \
    @[@(7), @"Angle-D Binders with Locking Rings"], \
    @[@(8), @"SAFCO Mobile Desk Side File,  Wire Frame"], \
    @[@(9), @"SAFCO Commercial Wire Shelving,  Black"], \
    @[@(10), @"Xerox 198"]]

static NSUInteger TestWritingDataCount = 10;

@interface CSVReaderWriterTests : XCTestCase {
    CSVReaderWriter *_reader;
    CSVReaderWriter *_writer;
    
    NSString *_temporaryFilePathForWriting;
}
@end

@implementation CSVReaderWriterTests

- (void)setUp {
    [super setUp];
    
    _reader = [[CSVReaderWriter alloc]init];
    _writer = [[CSVReaderWriter alloc]init];
    
    NSString *temporaryDirectory = NSTemporaryDirectory();
    _temporaryFilePathForWriting = [temporaryDirectory stringByAppendingPathComponent:TestWritingFileName];
}

- (void)tearDown {
    [super tearDown];
    
    [[NSFileManager defaultManager] removeItemAtPath:_temporaryFilePathForWriting error:nil];
}

#pragma mark - Utilities

- (void)openSampleFileWithReader:(CSVReaderWriter *)reader {
    NSString *path = [[NSBundle bundleForClass:[CSVReaderWriterTests class]] pathForResource:SampleCSVFileName ofType:CSVExtensionName];
    
    @try {
        [reader open:path mode:FileModeRead];
    } @catch (NSException *exception) {
        XCTAssert(NO, @"Could not open the file");
    }
}

- (void)createTestFileWithWriter:(CSVReaderWriter *)writer {
    [[NSFileManager defaultManager] createFileAtPath:_temporaryFilePathForWriting contents:nil attributes:nil];
    
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:_temporaryFilePathForWriting],
                  @"Could not create the test file");
    
    @try {
        [writer open:_temporaryFilePathForWriting mode:FileModeWrite];
    } @catch (NSException *exception) {
        XCTAssert(NO, @"Could not open the test file");
    }
}

- (void)openWroteFileWithReader:(CSVReaderWriter *)reader {
    @try {
        [reader open:_temporaryFilePathForWriting mode:FileModeRead];
    } @catch (NSException *exception) {
        XCTAssert(NO, @"Could not open the file");
    }
}

#pragma mark - Test deprecated methods

- (void)testLegacyCSVReaderByFirstTwoColumns {
    [self openSampleFileWithReader:_reader];
    
    NSUInteger rowsRead = 0;
    NSString *column1Cache;
    NSString *column2Cache;
    
    while ([_reader read:&column1Cache column2:&column2Cache]) {
        XCTAssertNotNil(column1Cache, @"Could not read column 1 data");
        XCTAssertNotNil(column2Cache, @"Could not read column 2 data");
        
        column1Cache = nil;
        column2Cache = nil;
        rowsRead ++;
    }
    
    XCTAssertEqual(rowsRead, SampleCSVRowCount, @"Did not read all rows");
    
    [_reader close];
}

- (void)testLegacyCSVReaderByAllColumn {
    [self openSampleFileWithReader:_reader];
    
    NSUInteger rowsRead = 0;
    NSMutableArray *cache = [[NSMutableArray alloc] init];
    
    while ([_reader read:cache]) {
        XCTAssertNotNil(cache, @"Cache being set to nil");
        XCTAssertGreaterThan(cache.count, 0, @"Could not read a single column with data");
        
        [cache removeAllObjects];
        rowsRead ++;
    }

    XCTAssertEqual(rowsRead, SampleCSVRowCount, @"Did not read all rows");
    
    [_reader close];
}

- (void)testLegacyCSVWriter {
    [self createTestFileWithWriter:_writer];
    
    NSArray *testWritingData = TestWritingData;
    
    for (NSArray *singleData in testWritingData) {
        [_writer write:singleData];
    }
    
    [_writer close];
    
    [self openWroteFileWithReader:_reader];
    
    NSUInteger rowsRead = 0;
    NSMutableArray *cache = [[NSMutableArray alloc] init];
    
    while ([_reader readLineTo:cache]) {
        XCTAssertNotNil(cache, @"Cache being set to nil");
        XCTAssertEqual(cache.count, 2, @"Could not read enough column with data");
        
        [cache removeAllObjects];
        rowsRead ++;
    }
    
    XCTAssertEqual(rowsRead, TestWritingDataCount, @"Did not read all rows");
    
    [_reader close];
}

#pragma mark - New

- (void)testNewCSVReader {
    [self openSampleFileWithReader:_reader];
    
    NSUInteger rowsRead = 0;
    NSMutableArray *cache = [[NSMutableArray alloc] init];
    
    while ([_reader readLineTo:cache]) {
        XCTAssertNotNil(cache, @"Cache being set to nil");
        XCTAssertGreaterThan(cache.count, 0, @"Could not read a single column with data");
        
        [cache removeAllObjects];
        rowsRead ++;
    }
    
    XCTAssertEqual(rowsRead, SampleCSVRowCount, @"Did not read all rows");
    
    [_reader close];
}

- (void)testNewCSVWriter {
    [self createTestFileWithWriter:_writer];
    
    NSArray *testWritingData = TestWritingData;
    
    for (NSArray *singleData in testWritingData) {
        [_writer writeLineWith:singleData];
    }
    
    [_writer close];
    
    [self openWroteFileWithReader:_reader];
    
    NSUInteger rowsRead = 0;
    NSMutableArray *cache = [[NSMutableArray alloc] init];
    
    while ([_reader readLineTo:cache]) {
        XCTAssertNotNil(cache, @"Cache being set to nil");
        XCTAssertEqual(cache.count, 2, @"Could not read enough column with data");
        
        [cache removeAllObjects];
        rowsRead ++;
    }
    
    XCTAssertEqual(rowsRead, TestWritingDataCount, @"Did not read all rows");
    
    [_reader close];
}

@end
