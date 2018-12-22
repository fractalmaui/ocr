//
//  DropboxTools.m
//  testOCR
//
//  Created by Dave Scruton on 12/21/18.
//  Copyright © 2018 huedoku. All rights reserved.
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
        _batchFileList = [[NSMutableArray alloc] init]; //CSV data as read in from csv.txt
        _batchImages   = [[NSMutableArray alloc] init]; //CSV data as read in from csv.txt
//        [self loadCategoriesFile];
        client = [DBClientsManager authorizedClient];

        NSLog(@" dropbox tools created, client:%@",client);
    }
    return self;
}

//=============(DropboxTools)=====================================================
-(void) setParent : (UIViewController*) p
{
    parent = p;
}

//=============(DropboxTools)=====================================================
// Looks in default location for this app, we have ONLY one folder for now...
-(void) getBatchList
{
    NSString *searchPath = @"";
    NSLog(@"  get batchList from DB");
    // list folder metadata contents (folder will be root "/" Dropbox folder if app has permission
    // "Full Dropbox" or "/Apps/<APP_NAME>/" if app has permission "App Folder").
    [[client.filesRoutes listFolder:searchPath]
     setResponseBlock:^(DBFILESListFolderResult *result, DBFILESListFolderError *routeError, DBRequestError *error) {
         if (result) {
             
             [self loadBatchEntries :result.entries];
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
             NSLog(@"DROPBOX ERROR!!! [%@]",message);
             //Put this into an error message somewhere
//             UIAlertController *alertController =
//             [UIAlertController alertControllerWithTitle:title
//                                                 message:message
//                                          preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
//             [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
//                                                                 style:(UIAlertActionStyle)UIAlertActionStyleCancel
//                                                               handler:nil]];
             //[self presentViewController:alertController animated:YES completion:nil];
             
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
    NSLog(@" entries %@",folderEntries);
    NSMutableArray<NSString *> *imagePaths = [NSMutableArray new];
    [_batchFileList removeAllObjects];
    for (DBFILESMetadata *entry in folderEntries) {
        NSString *itemName = entry.name;
        if ([self isImageType:itemName]) {
            [imagePaths addObject:entry.pathDisplay];
            [_batchFileList addObject:entry.pathDisplay];
        }
    }
//    if ([imagePaths count] > 0) {
//        NSString *imagePathToDownload = imagePaths[arc4random_uniform((int)[imagePaths count] - 1)];
//        [self downloadImage:imagePathToDownload];
//    } else {
//        NSLog(@" no entries found!");
//    }
    NSLog(@" loaded %d entries",(int)_batchFileList.count);
} //end loadBatchEntries


//=============(DropboxTools)=====================================================
- (void)downloadImage:(NSString *)imagePath {
    DBUserClient *client = [DBClientsManager authorizedClient];
    NSLog(@" dload image %@",imagePath);
    
    
    [[client.filesRoutes downloadData:imagePath]
     setResponseBlock:^(DBFILESFileMetadata *result, DBFILESDownloadError *routeError, DBRequestError *error, NSData *fileData) {
         if (result) {
             UIImageView *imageView;
             //Got a PDF?
             if ([imagePath.lowercaseString containsString:@"pdf"])
             {
                 UIImage *pimage = [self getImageFromPDFData:fileData];
                 
//                 imageView = [[UIImageView alloc] initWithImage:pimage];
                 
             } //end .pdf string
//             else //Non-pdf
//             {
//                 imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:fileData]];
//             }
//
//             imageView.frame = CGRectMake(100, 100, 300, 300);
//             [imageView setCenter:CGPointMake(parent.view.bounds.size.width/2, self.view.bounds.size.height/2)];
//             [self.view addSubview:imageView];
//             _currentImageView = imageView;
//             [self setFinished];
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
             
             UIAlertController *alertController =
             [UIAlertController alertControllerWithTitle:title
                                                 message:message
                                          preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
             [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                                 style:(UIAlertActionStyle)UIAlertActionStyleCancel
                                                               handler:nil]];
             [parent presentViewController:alertController animated:YES completion:nil];
             
//             [self setFinished];
         }
     }];
}

//=============(DropboxTools)=====================================================
-(UIImage *)getImageFromPDFData : (NSData *)fileData
{
    CFDataRef pdfData = (__bridge CFDataRef) fileData;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(pdfData);
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithProvider(provider);
    UIImage *result = nil;
    if (pdf)
    {
        
        CGPDFPageRef PDFPage = CGPDFDocumentGetPage(pdf, 1);
        
        if (PDFPage)
        {
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
            
            result = UIGraphicsGetImageFromCurrentImageContext();
        } //end pdfpage
    }
    return result;
} //end getImageFromPDFData

@end
