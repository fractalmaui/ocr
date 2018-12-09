//
//   _                           _____           _
//  (_)_ __ ___   __ _  __ _  __|_   _|__   ___ | |___
//  | | '_ ` _ \ / _` |/ _` |/ _ \| |/ _ \ / _ \| / __|
//  | | | | | | | (_| | (_| |  __/| | (_) | (_) | \__ \
//  |_|_| |_| |_|\__,_|\__, |\___||_|\___/ \___/|_|___/
//                     |___/
//
//  imageTools.m
//  testOCR
//
//  Created by Dave Scruton on 12/5/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import "imageTools.h"

@implementation imageTools

//=============OCR Tester=====================================================
-(UIImage *)convertOriginalImageToBWImage:(UIImage *)originalImage
{
    UIImage *newImage;
    
    CGColorSpaceRef colorSapce = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, originalImage.size.width * originalImage.scale, originalImage.size.height * originalImage.scale, 8, originalImage.size.width * originalImage.scale, colorSapce, kCGImageAlphaNone);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetShouldAntialias(context, NO);
    CGContextDrawImage(context, CGRectMake(0, 0, originalImage.size.width, originalImage.size.height), [originalImage CGImage]);
    
    CGImageRef bwImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSapce);
    
    UIImage *resultImage = [UIImage imageWithCGImage:bwImage];
    CGImageRelease(bwImage);
    
    UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, originalImage.scale);
    [resultImage drawInRect:CGRectMake(0.0, 0.0, originalImage.size.width, originalImage.size.height)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return newImage;
}

//=============OCR Tester=====================================================
-(UIImage*)getHiContrast:(UIImage*)inputImage
{
    CIImage *coreImage = [[CIImage alloc] init];
    coreImage = [coreImage initWithImage:inputImage];
    
    NSNumber *workNumCont = [NSNumber numberWithFloat:1.2f];
    NSNumber *workNumSat  = [NSNumber numberWithFloat:0.0f];
    CIFilter *filterCont  = [CIFilter filterWithName:@"CIColorControls"
                                       keysAndValues: kCIInputImageKey,  coreImage,
                             @"inputSaturation", workNumSat,
                             @"inputContrast", workNumCont,
                             nil];
    CIImage *workCoreImage = [filterCont outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimage = [context createCGImage:workCoreImage fromRect:[workCoreImage extent] format:kCIFormatRGBA8 colorSpace:CGColorSpaceCreateDeviceRGB()];
    UIImage *i = [UIImage imageWithCGImage:cgimage scale:0 orientation:[inputImage imageOrientation]];
    CGImageRelease(cgimage);
    return i;
}

//=============OCR Tester=====================================================
-(int) findLHEdge : (int) row
{
    int ptr = 4 * iwid * row; //RGB or RGBA?
    int count = 0;
    int found = 0;
    int iw2 = iwid/2;
    while (count < iw2 && found == 0)
    {
        int red = (int)idata[ptr];
        int red2 = (int) idata[ptr+4];
        int red3 = (int) idata[ptr+8];
        //if (row < 200) NSLog(@" row %d col %d : %d",row,count,red);
        if (red < 20 && red2 < 20 && red3 < 20) found = 1; //Dark pixel = hit!
        else
        {
            count++;
            ptr+=4;
        }
    }
    //if (row < 200) NSLog(@"............");
    if (found != 0) return count;
    return -1;
}

//=============OCR Tester=====================================================
-(void) deskew : (UIImage *)workImage
{
    pixelData = CGDataProviderCopyData(CGImageGetDataProvider(workImage.CGImage));
    if (pixelData == nil) return;
    idata = CFDataGetBytePtr(pixelData);
    iwid = workImage.size.width;
    ihit = workImage.size.height;
    int i;
    for (i=0;i<MAXBINS;i++)
    {
        bins[i] = -1;
        bgrad[i] = -1;
        absgrad[i] = -1;
    }
    int bcount = 0;
    int stride = 1;
    //Every "stride" rows, find LH edge, store in bins
    for (i=0;i<ihit;i+=stride)
    {
        bins[bcount++] = [self findLHEdge:i];
    }
    //Now get bin gradients
    for (i=1;i<bcount;i++)
    {
        if (bins[i-1] != -1)
            bgrad[i-1] = bins[i] - bins[i-1];
    }
    //Get abs bingrads
    for (i=0;i< bcount;i++)
    {
        if (bins[i] == -1) absgrad[i] = -1;
        else absgrad[i] = abs(bgrad[i]);
    }
    //Get average of absgrads
    float asum = 0.0f;
    float acount = 0.0f;
    for (i=0;i<bcount-1;i++)
    {
        if (absgrad[i] != -1)
        {
            asum+=(float)absgrad[i];
            acount++;
        }
    }
    asum/=acount;
    //Toss big skews
    for (i=0;i<bcount-1;i++)
    {
        if (absgrad[i] > (int)asum) absgrad[i] = -1;
    }
    //OK get average of grads
    asum =  acount = 0.0f;
    for (i=0;i<bcount-1;i++)
    {
        if (absgrad[i] != -1)
        {
            asum+=(float)bgrad[i];
            acount++;
        }
    }
    asum/=acount; //Final skew average...
    float fdx = asum;
    float fdy = (float)stride;
    float angle = atan2f(fdy, fdx);
    //float adeg  = 360.0 * (angle / (2 * 3.14159));
    NSLog(@"  dxy %f %f : skew %f",fdx,fdy,angle);
    
} //end deskew

@end
