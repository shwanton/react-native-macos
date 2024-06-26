/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "Screenshot.h"

#import <React/RCTUIManager.h>

@implementation ScreenshotManager

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(takeScreenshot
                  : (id /* NSString or NSNumber */)target withOptions
                  : (NSDictionary *)options resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject)
{
  [self.bridge.uiManager addUIBlock:^(
                             __unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RCTPlatformView *> *viewRegistry) { // [macOS]
#if !TARGET_OS_OSX // [macOS]
    // Get view
    UIView *view;
    if (target == nil || [target isEqual:@"window"]) {
      view = RCTKeyWindow();
    } else if ([target isKindOfClass:[NSNumber class]]) {
      view = viewRegistry[target];
      if (!view) {
        RCTLogError(@"No view found with reactTag: %@", target);
        return;
      }
    }

    // Get options
    CGSize size = [RCTConvert CGSize:options];
    NSString *format = [RCTConvert NSString:options[@"format"] ?: @"png"];

    // Capture image
    if (size.width < 0.1 || size.height < 0.1) {
      size = view.bounds.size;
    }

    UIGraphicsImageRendererFormat *const rendererFormat = [UIGraphicsImageRendererFormat defaultFormat];
    UIGraphicsImageRenderer *const renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size format:rendererFormat];

    __block BOOL success = NO;
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *_Nonnull context) {
      success = [view drawViewHierarchyInRect:(CGRect){CGPointZero, size} afterScreenUpdates:YES];
    }];

    if (!success || !image) {
      reject(RCTErrorUnspecified, @"Failed to capture view snapshot.", nil);
      return;
    }

    // Convert image to data (on a background thread)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSData *data;
      if ([format isEqualToString:@"png"]) {
        data = UIImagePNGRepresentation(image);
      } else if ([format isEqualToString:@"jpeg"]) {
        CGFloat quality = [RCTConvert CGFloat:options[@"quality"] ?: @1];
        data = UIImageJPEGRepresentation(image, quality);
      } else {
        RCTLogError(@"Unsupported image format: %@", format);
        return;
      }

      // Save to a temp file
      NSError *error = nil;
      NSString *tempFilePath = RCTTempFilePath(format, &error);
      if (tempFilePath) {
        if ([data writeToFile:tempFilePath options:(NSDataWritingOptions)0 error:&error]) {
          resolve(tempFilePath);
          return;
        }
      }

      // If we reached here, something went wrong
      reject(RCTErrorUnspecified, error.localizedDescription, error);
    });
#else // [macOS
		// find the key window
		NSWindow *keyWindow;
		for (NSWindow *window in NSApp.windows) {
			if (window.keyWindow) {
				keyWindow = window;
				break;
			}
		}

		// take a snapshot of the key window
		CGWindowID windowID = (CGWindowID)[keyWindow windowNumber];
		CGWindowImageOption imageOptions = kCGWindowImageDefault;
		CGWindowListOption listOptions = kCGWindowListOptionIncludingWindow;
		CGRect imageBounds = CGRectNull;
		CGImageRef windowImage = CGWindowListCreateImage(imageBounds, listOptions, windowID, imageOptions);
		NSImage *image = [[NSImage alloc] initWithCGImage:windowImage size:[keyWindow frame].size];
		CGImageRelease(windowImage);

		// save to a temp file
		NSError *error = nil;
		NSString *tempFilePath = RCTTempFilePath(@"jpeg", &error);
		NSData *imageData = [image TIFFRepresentation];
		NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
		NSDictionary *imageProps = [NSDictionary dictionaryWithObject:@0.8 forKey:NSImageCompressionFactor];
		imageData = [imageRep representationUsingType:NSBitmapImageFileTypeJPEG properties:imageProps];
		BOOL success = [imageData writeToFile:tempFilePath atomically:NO];

		 if (success) {
				 resolve(tempFilePath);
		 } else {
			 reject(RCTErrorUnspecified, error.localizedDescription, error);
		 }
#endif // macOS]
  }];
}

@end
