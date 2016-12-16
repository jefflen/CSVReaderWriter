`/*
 A junior developer was tasked with writing a reusable implementation for a mass mailing application to read and write text files that hold tab separated data.
 
 His implementation, although it works and meets the needs of the application, is of very low quality.
 
 Your task:
 
 - Identify and annotate the shortcomings in the current implementation as if you were doing a code review, using comments in the source files.
 
 - Refactor the CSVReaderWriter implementation into clean, idiomatic, elegant, rock-solid & well performing code, without over-engineering.
 
 - Where you make trade offs, comment & explain.
 
 - Assume this code is in production and backwards compatibility must be maintained. Therefore if you decide to change the public interface, please deprecate the existing methods. Feel free to evolve the code in other ways though. You have carte blanche while respecting the above constraints. 
 */

#import <Foundation/Foundation.h>

// - It is recommended to use NS_ENUM instead of NS_OPTIONS,
//   as the file can not be both readable and writable at
//   the same time
typedef NS_OPTIONS(NSUInteger, FileMode) {
    FileModeRead = 1,
    FileModeWrite = 2
};

@interface CSVReaderWriter : NSObject

- (void)open:(NSString*)path mode:(FileMode)mode;
// - It is not recommended to define methods as specific usage, the method
//   should be as general as possible.
- (BOOL)read:(NSMutableString**)column1 column2:(NSMutableString**)column2;
- (BOOL)read:(NSMutableArray*)columns;
- (void)write:(NSArray*)columns;
- (void)close;

@end

// - Put the instance variable in the @implementation is acceptable,
//   however, it is not aligned to the coding style convention nowadays.
@implementation CSVReaderWriter {
    NSInputStream* inputStream;
    NSOutputStream* outputStream;
}

- (void)open:(NSString*)path mode:(FileMode)mode {
    // - Using switch statement for enums is recommended
    if (mode == FileModeRead) {
        inputStream = [NSInputStream inputStreamWithFileAtPath:path];
        [inputStream open];
    }
    else if (mode == FileModeWrite) {
        outputStream = [NSOutputStream outputStreamToFileAtPath:path
                                                         append:NO];
        [outputStream open];
    }
    else {
        // - It is recommnded to declare those strings as const variable.
        // - Using NSLocalizedString for the reason is recommended for future localisation.
        NSException* ex = [NSException exceptionWithName:@"UnknownFileModeException"
                                                  reason:@"Unknown file mode specified"
                                                userInfo:nil];
        @throw ex;
    }
}

// - It doesn't check if the stream is opened
- (NSString*)readLine {
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
    // - This scope could actually use read: method instead
    
    // - It is recommended to define the column index as global const
    int FIRST_COLUMN = 0;
    int SECOND_COLUMN = 1;
    
    NSString* line = [self readLine];
    
    if ([line length] == 0) {
        *column1 = nil;
        *column2 = nil;
        return false;
    }
    
    // - It is recommnded to declare those characters as const variable.
    NSArray* splitLine = [line componentsSeparatedByString: @"\t"];
    
    if ([splitLine count] == 0) {
        *column1 = nil;
        *column2 = nil;
        return false;
    }
    else {
        *column1 = [NSMutableString stringWithString:splitLine[FIRST_COLUMN]];
        *column2 = [NSMutableString stringWithString:splitLine[SECOND_COLUMN]];
        return true;
    }
}

- (BOOL)read:(NSMutableArray*)columns {
    // - It is recommended to define the column index as global const
    int FIRST_COLUMN = 0;
    int SECOND_COLUMN = 1;
    
    NSString* line = [self readLine];
    
    if ([line length] == 0) {
        // - When passing nil to an NSArray, it will crash as NSArray couldn't take nil.
        //   However, it could takes in [NSNull null], but I don't think it suits in this
        //   context.
        // - It doesn't aligned to the same coding style elsewhere where there's no space
        //   between the '=' syntax
        columns[FIRST_COLUMN]=nil;
        columns[SECOND_COLUMN] = nil;
        return false;
    }
    
    // - It is recommnded to declare those characters as const variable.
    NSArray* splitLine = [line componentsSeparatedByString: @"\t"];
    
    if ([splitLine count] == 0) {
        // - When passing nil to an NSArray, it will crash as NSArray couldn't take nil.
        //   However, it could takes in [NSNull null], but I don't think it suits in this
        //   context.
        columns[FIRST_COLUMN] = nil;
        columns[SECOND_COLUMN] = nil;
        return false;
    }
    else {
        columns[FIRST_COLUMN] = splitLine[FIRST_COLUMN];
        columns[SECOND_COLUMN] = splitLine[SECOND_COLUMN];
        return true;
    }
}

// - It doesn't check if the stream is opened
- (void)writeLine:(NSString*)line {
    NSData* data = [line dataUsingEncoding:NSUTF8StringEncoding];
    
    const void* bytes = [data bytes];
    [outputStream write:bytes maxLength:[data length]];
    
    // - It is recommnded to declare those characters as const variable.
    unsigned char* lf = (unsigned char*)"\n";
    [outputStream write: lf maxLength: 1];
}

- (void)write:(NSArray*)columns {
    // - This method can simply use the componentJoinedWithSeparator: method
    //   provided in the NSArray.
    
    // - Declare mutalbe string by mutable copy doubles the memory usage,
    //   using [NSMutableString string] is recommended.
    NSMutableString* outPut = [@"" mutableCopy];
    
    // - It is recommended to use NSUInteger in the for loop
    for (int i = 0; i < [columns count]; i++) {
        [outPut appendString: columns[i]];
        if (([columns count] - 1) != i) {
            // - It is recommnded to declare those characters as const variable.
            [outPut appendString: @"\t"];
        }
    }
    
    [self writeLine:outPut];
}

- (void)close {
    if (inputStream != nil) {
        [inputStream close];
        // - It is recommended to assign nil to the stream as an NSStream cannot be
        //   reopened.
    }
    // - There is a typo here, it should be outputStream
    if (inputStream != nil) {
        [inputStream close];
    }
}

@end
