//
//  CSVReaderWriter.m
//  CSVReaderWriter
//
//  Created by Hungju Lu on 14/12/2016.
//  Copyright © 2016 Hungju. All rights reserved.
//

#import <CSVReaderWriter.h>

// - Changed all the true/false statements to the Objective-C YES/NO

// - Defined global consts for easy management.

static NSString * const TabCharacter = @"\t";
static NSString * const NewLineCharacter = @"\n";

static NSString * const UnknownFileModeExceptionName = @"UnknownFileModeException";
static NSString * const UnknownFileModeExceptionReason = @"Unknown file mode specified";

static NSString * const FileNotOpenedModeExceptionName = @"FileNotOpenedModeException";
static NSString * const FileNotOpenedModeExceptionReason = @"Please invoke open:mode: to open the file first";

// - Created a interface to declar ivars for aligning the
//   coding convention nowadays.
@interface CSVReaderWriter () {
    NSInputStream* inputStream;
    NSOutputStream* outputStream;
}
@end

@implementation CSVReaderWriter

#pragma mark - Open

- (void)open:(NSString*)path mode:(FileMode)mode {
    // - Changed the if else statement to use switch statement for easy management
    switch (mode) {
        case FileModeRead:{
            inputStream = [NSInputStream inputStreamWithFileAtPath:path];
            [inputStream open];
            break;
        }
        case FileModeWrite:{
            outputStream = [NSOutputStream outputStreamToFileAtPath:path
                                                             append:NO];
            [outputStream open];
            break;
        }
        default:{
            // - Added NSLocalizedString for future localisation use
            NSException* ex = [NSException exceptionWithName:NSLocalizedString(UnknownFileModeExceptionName, nil)
                                                      reason:NSLocalizedString(UnknownFileModeExceptionReason, nil)
                                                    userInfo:nil];
            @throw ex;
            break;
        }
    }
}

#pragma mark - Reader

- (NSString*)readLine {
    // - Checked if the stream is opened or will throws an exception.
    if (![self streamIsOpened:inputStream]) {
        NSException* ex = [NSException exceptionWithName:NSLocalizedString(FileNotOpenedModeExceptionName, nil)
                                                  reason:NSLocalizedString(FileNotOpenedModeExceptionReason, nil)
                                                userInfo:nil];
        @throw ex;
    }
    
    uint8_t ch = 0;
    NSMutableString* str = [NSMutableString string];
    while ([inputStream read:&ch maxLength:1] == 1) {
        if (ch == '\n')
            break;
        [str appendFormat:@"%c", ch];
    }
    return str;
}

- (BOOL)read:(NSMutableString**)column1 column2:(NSMutableString**)column2 {
    // - Reused the convenience method below for cleaner code
    //   but still maintained the backwards compatibility.
    
    NSMutableArray *columns = [[NSMutableArray alloc] init];
    [self readLineTo:columns];
    
    if (columns.count < 2) {
        *column1 = nil;
        *column2 = nil;
        return NO;
    }
    
    *column1 = columns[1];
    *column2 = columns[2];
    
    return YES;
}

- (BOOL)read:(NSMutableArray*)columns {
    // - Reused the convenience method below for cleaner code
    //   but still maintained the backwards compatibility.
    return [self readLineTo:columns];
}

// - Created an convenience method for reading a line and stored in a column

- (BOOL)readLineTo:(NSMutableArray *)columns {
    NSString *line = [self readLine];
    
    [columns removeAllObjects];
    
    if (line.length == 0) {
        return NO;
    }
    
    [columns addObjectsFromArray:[line componentsSeparatedByString:TabCharacter]];
    
    return YES;
}

#pragma mark - Writer

- (void)writeLine:(NSString*)line {
    // - Checked if the stream is opened or will throws an exception.
    if (![self streamIsOpened:outputStream]) {
        NSException* ex = [NSException exceptionWithName:NSLocalizedString(FileNotOpenedModeExceptionName, nil)
                                                  reason:NSLocalizedString(FileNotOpenedModeExceptionReason, nil)
                                                userInfo:nil];
        @throw ex;
    }
    
    NSData* data = [line dataUsingEncoding:NSUTF8StringEncoding];
    
    const void* bytes = [data bytes];
    [outputStream write:bytes maxLength:[data length]];
    
    unsigned char* lf = (unsigned char*)[NewLineCharacter cStringUsingEncoding:NSUTF8StringEncoding];
    [outputStream write: lf maxLength: 1];
}

- (void)write:(NSArray*)columns {
    [self writeLineWith:columns];
}

- (void)writeLineWith:(NSArray *)columns {
    // - Changed the complex joiner codes into a simple line
    NSString *output = [columns componentsJoinedByString:TabCharacter];
    [self writeLine:output];
}

#pragma mark - Close

- (void)close {
    if (inputStream != nil) {
        [inputStream close];
        inputStream = nil;
    }
    if (outputStream != nil) {
        [outputStream close];
        outputStream = nil;
    }
}

#pragma mark - Utilities

- (BOOL)streamIsOpened:(NSStream *)stream {
    return (stream != nil) && ([stream streamStatus] == NSStreamStatusOpen);
}

@end
