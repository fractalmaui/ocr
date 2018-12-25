//
//   ____                  _               _____           _
//  |  _ \ _ __ ___  _ __ | |__   _____  _|_   _|__   ___ | |___
//  | | | | '__/ _ \| '_ \| '_ \ / _ \ \/ / | |/ _ \ / _ \| / __|
//  | |_| | | | (_) | |_) | |_) | (_) >  <  | | (_) | (_) | \__ \
//  |____/|_|  \___/| .__/|_.__/ \___/_/\_\ |_|\___/ \___/|_|___/
//                  |_|
//
//  DropboxTools.m
//  testOCR
//
//  Created by Dave Scruton on 12/21/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import "DropboxTools.h"

@implementation DropboxTools


static DropboxTools *sharedInstance = nil;


//=============(DropboxTools)=====================================================
// Get the shared instance and create it if necessary.
+ (DropboxTools *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }

    return sharedInstance;
}

//=============(DropboxTools)=====================================================
-(instancetype) init
{
    if (self = [super init])
    {
        _batchFileList   = [[NSMutableArray alloc] init]; //CSV data as read in from csv.txt
        _batchImages     = [[NSMutableArray alloc] init]; //CSV data as read in from csv.txt
        _batchImagePaths = [[NSMutableArray alloc] init]; //CSV data as read in from csv.txt
        _batchImageData  = [[NSMutableArray alloc] init]; //CSV data as read in from csv.txt
        client           = [DBClientsManager authorizedClient];
    }
    return self;
}


//=============(DropboxTools)=====================================================
-(void) countEntries:(NSString *)batchFolder :(NSString *)vendorFolder
{
    //NSLog(@" ce %@",vendorFolder);
    NSString *searchPath = [NSString stringWithFormat:@"/%@/%@",batchFolder,vendorFolder];
    [[client.filesRoutes listFolder:searchPath]
     setResponseBlock:^(DBFILESListFolderResult *result, DBFILESListFolderError *routeError, DBRequestError *error) {
         if (result) { //Only handle good folders
             self->_entries = result.entries;
             int count = (int)result.entries.count;
             [self->_delegate didCountEntries:vendorFolder :count];
         }
         else
         {
             [self->_delegate didCountEntries:vendorFolder :0];
         }
     }];

} //end countEntries

//=============(DropboxTools)=====================================================
-(void) setParent : (UIViewController*) p
{
    parent = p;
}


//=============(DropboxTools)=====================================================
// Must be able to handle multiple pages : adds to internal array...
-(void)addImagesFromPDFData : (NSData *)fileData : (NSString *) imagePath
{
    [_batchImageData addObject:fileData];
    CFDataRef pdfData = (__bridge CFDataRef) fileData;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(pdfData);
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithProvider(provider);
    if (pdf)
    {
        int pageCount = (int)CGPDFDocumentGetNumberOfPages(pdf);
        //NSLog(@" PDF has %d pages",pageCount);
        for (int i = 1;i<=pageCount;i++) // loop over pages...
        {
            CGPDFPageRef PDFPage = CGPDFDocumentGetPage(pdf, i);
            if (PDFPage)
            {
                UIImage *nextImage = nil;
                // Determine the size of the PDF page.
                CGRect pageRect = CGPDFPageGetBoxRect(PDFPage, kCGPDFMediaBox);
                CGFloat PDFScale = 1.0; //view.frame.size.width/pageRect.size.width;
                pageRect.size = CGSizeMake(pageRect.size.width*PDFScale, pageRect.size.height*PDFScale);
                UIGraphicsBeginImageContext(pageRect.size);
                
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                // First fill the background with white.
                CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
                CGContextFillRect(context,pageRect);
                
                CGContextSaveGState(context);
                // Flip the context so that the PDF page is rendered right side up.
                CGContextTranslateCTM(context, 0.0, pageRect.size.height);
                CGContextScaleCTM(context, 1.0, -1.0);
                
                // Scale the context so that the PDF page is rendered at the correct size for the zoom level.
                CGContextScaleCTM(context, PDFScale,PDFScale);
                CGContextDrawPDFPage(context, PDFPage);
                CGContextRestoreGState(context);
                
                nextImage = UIGraphicsGetImageFromCurrentImageContext();
                if (nextImage != nil)
                {
                    [_batchImages addObject:nextImage];
                    [_batchImagePaths addObject:imagePath];
                }
                if (i == pageCount) [_delegate didDownloadImages];

            } //end pdfpage
        } //end for i
    }  //end if pdf
} //end addImagesFromPDFData

//=============(DropboxTools)=====================================================
// Looks in default location for this app, we have ONLY one folder for now...
-(void) getBatchList : (NSString *) batchFolder : (NSString *) vendorFolder
{
    NSString *searchPath = [NSString stringWithFormat:@"/%@/%@",batchFolder,vendorFolder]; //Prepend / to get subfolder
    //NSLog(@"  get batchList from DB [%@]",searchPath);
    _prefix = searchPath;
    // list folder metadata contents (folder will be root "/" Dropbox folder if app has permission
    // "Full Dropbox" or "/Apps/<APP_NAME>/" if app has permission "App Folder").
    [[client.filesRoutes listFolder:searchPath]
     setResponseBlock:^(DBFILESListFolderResult *result, DBFILESListFolderError *routeError, DBRequestError *error) {
         if (result) {
             if (result.entries.count == 0) //Empty folder? No batch!
             {
                 [self->_delegate errorGettingBatchList : @"Empty Batch Folder"];
                 return;
             }
             self->_entries = result.entries;
             [self loadBatchEntries :result.entries];
             [self->_delegate didGetBatchList : result.entries];
         } else {
             NSString *title = @"";
             NSString *message = @"";
             if (routeError) {
                 // Route-specific request error
                 title = @"Route-specific error";
                 if ([routeError isPath]) {
                     message = [NSString stringWithFormat:@"Invalid path: %@", routeError.path];
                 }
             } else {
                 // Generic request error
                 title = @"Generic request error";
                 if ([error isInternalServerError]) {
                     DBRequestInternalServerError *internalServerError = [error asInternalServerError];
                     message = [NSString stringWithFormat:@"%@", internalServerError];
                 } else if ([error isBadInputError]) {
                     DBRequestBadInputError *badInputError = [error asBadInputError];
                     message = [NSString stringWithFormat:@"%@", badInputError];
                 } else if ([error isAuthError]) {
                     DBRequestAuthError *authError = [error asAuthError];
                     message = [NSString stringWithFormat:@"%@", authError];
                 } else if ([error isRateLimitError]) {
                     DBRequestRateLimitError *rateLimitError = [error asRateLimitError];
                     message = [NSString stringWithFormat:@"%@", rateLimitError];
                 } else if ([error isHttpError]) {
                     DBRequestHttpError *genericHttpError = [error asHttpError];
                     message = [NSString stringWithFormat:@"%@", genericHttpError];
                 } else if ([error isClientError]) {
                     DBRequestClientError *genericLocalError = [error asClientError];
                     message = [NSString stringWithFormat:@"%@", genericLocalError];
                 }
             }
             [self errMsg:@"Dropbox read error" :message];
             [self->_delegate errorGettingBatchList : message];

             //  [self setFinished];
         }
     }];
}

//=============(DropboxTools)=====================================================
//DHS try adding PDF?
- (BOOL)isImageType:(NSString *)itemName {
    NSRange range = [itemName rangeOfString:@"\\.jpeg|\\.jpg|\\.JPEG|\\.JPG|\\.png|\\.pdf" options:NSRegularExpressionSearch];
    return range.location != NSNotFound;
}


//=============(DropboxTools)=====================================================
-(void) loadBatchEntries : (NSArray *)folderEntries
{
    //NSLog(@" entries %@",folderEntries);
    NSMutableArray<NSString *> *imagePaths = [NSMutableArray new];
    [_batchFileList removeAllObjects];
    for (DBFILESMetadata *entry in folderEntries) {
        NSString *itemName = entry.name;
        if ([self isImageType:itemName]) {
            [imagePaths addObject:entry.pathDisplay];
            [_batchFileList addObject:entry.pathDisplay];
        }
    }
    //Make this an error message!
    if ([imagePaths count] == 0)
    {
        [self errMsg:@"Error loading batch list" :@" no entries found!"];
        NSLog(@" no entries found!");
    }
    //NSLog(@" loaded %d entries",(int)_batchFileList.count);
} //end loadBatchEntries


//=============(DropboxTools)=====================================================
- (void)downloadImages:(NSString *)imagePath
{
    DBUserClient *client = [DBClientsManager authorizedClient];
    NSLog(@" dropbox dload image %@",imagePath);
    
    [_batchImages     removeAllObjects];
    [_batchImagePaths removeAllObjects];
    [_batchImageData  removeAllObjects];
    [[client.filesRoutes downloadData:imagePath]
     setResponseBlock:^(DBFILESFileMetadata *result, DBFILESDownloadError *routeError, DBRequestError *error, NSData *fileData) {
         if (result) {
             UIImage *nextImage;
             //Got a PDF?
             if ([imagePath.lowercaseString containsString:@"pdf"])
             {
                 [self addImagesFromPDFData:fileData:imagePath]; //May add more than one image!
                 return; //Delegate gets called later...
             } //end .pdf string
             else //Jpg / PNG file?
             {
                 nextImage = [UIImage imageWithData:fileData];
                 if (nextImage != nil)
                 {
                     [self->_batchImages addObject:nextImage];
                     [self->_batchImagePaths addObject:imagePath];
                 }
             }
             NSLog(@" ....dropbox delegate...");
             [self->_delegate didDownloadImages];
         } else {
             NSString *title = @"";
             NSString *message = @"";
             if (routeError) {
                 // Route-specific request error
                 title = @"Route-specific error";
                 if ([routeError isPath]) {
                     message = [NSString stringWithFormat:@"Invalid path: %@", routeError.path];
                 } else if ([routeError isOther]) {
                     message = [NSString stringWithFormat:@"Unknown error: %@", routeError];
                 }
             } else {
                 // Generic request error
                 title = @"Generic request error";
                 if ([error isInternalServerError]) {
                     DBRequestInternalServerError *internalServerError = [error asInternalServerError];
                     message = [NSString stringWithFormat:@"%@", internalServerError];
                 } else if ([error isBadInputError]) {
                     DBRequestBadInputError *badInputError = [error asBadInputError];
                     message = [NSString stringWithFormat:@"%@", badInputError];
                 } else if ([error isAuthError]) {
                     DBRequestAuthError *authError = [error asAuthError];
                     message = [NSString stringWithFormat:@"%@", authError];
                 } else if ([error isRateLimitError]) {
                     DBRequestRateLimitError *rateLimitError = [error asRateLimitError];
                     message = [NSString stringWithFormat:@"%@", rateLimitError];
                 } else if ([error isHttpError]) {
                     DBRequestHttpError *genericHttpError = [error asHttpError];
                     message = [NSString stringWithFormat:@"%@", genericHttpError];
                 } else if ([error isClientError]) {
                     DBRequestClientError *genericLocalError = [error asClientError];
                     message = [NSString stringWithFormat:@"%@", genericLocalError];
                 }
             }
             [self->_delegate errorDownloadingImages:message];
             //             [self setFinished];
         }
     }];
}

//=============(DropboxTools)=====================================================
-(void) errMsg : (NSString *)title : (NSString*)message
{
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:(UIAlertActionStyle)UIAlertActionStyleCancel
                                                      handler:nil]];
    [parent presentViewController:alertController animated:YES completion:nil];

} //end errMsg


@end
