/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RCTSurfaceHostingProxyRootView.h"

#import <objc/runtime.h>

#import "RCTAssert.h"
#import "RCTBridge+Private.h"
#import "RCTBridge.h"
#import "RCTLog.h"
#import "RCTPerformanceLogger.h"
#import "RCTProfile.h"
#import "RCTRootContentView.h"
#import "RCTRootViewDelegate.h"
#import "RCTSurface.h"
#import "RCTUIManager.h"
#import "RCTUIManagerUtils.h"
#import "RCTSurfaceRootShadowView.h"

#import "UIView+React.h"

static RCTSurfaceSizeMeasureMode convertToSurfaceSizeMeasureMode(RCTRootViewSizeFlexibility sizeFlexibility)
{
  switch (sizeFlexibility) {
    case RCTRootViewSizeFlexibilityWidthAndHeight:
      return RCTSurfaceSizeMeasureModeWidthUndefined | RCTSurfaceSizeMeasureModeHeightUndefined;
    case RCTRootViewSizeFlexibilityWidth:
      return RCTSurfaceSizeMeasureModeWidthUndefined | RCTSurfaceSizeMeasureModeHeightExact;
    case RCTRootViewSizeFlexibilityHeight:
      return RCTSurfaceSizeMeasureModeWidthExact | RCTSurfaceSizeMeasureModeHeightUndefined;
    case RCTRootViewSizeFlexibilityNone:
      return RCTSurfaceSizeMeasureModeWidthExact | RCTSurfaceSizeMeasureModeHeightExact;
  }
}

static RCTRootViewSizeFlexibility convertToRootViewSizeFlexibility(RCTSurfaceSizeMeasureMode sizeMeasureMode)
{
  switch (sizeMeasureMode) {
    case RCTSurfaceSizeMeasureModeWidthUndefined | RCTSurfaceSizeMeasureModeHeightUndefined:
      return RCTRootViewSizeFlexibilityWidthAndHeight;
    case RCTSurfaceSizeMeasureModeWidthUndefined | RCTSurfaceSizeMeasureModeHeightExact:
      return RCTRootViewSizeFlexibilityWidth;
    case RCTSurfaceSizeMeasureModeWidthExact | RCTSurfaceSizeMeasureModeHeightUndefined:
      return RCTRootViewSizeFlexibilityHeight;
    case RCTSurfaceSizeMeasureModeWidthExact | RCTSurfaceSizeMeasureModeHeightExact:
    default:
      return RCTRootViewSizeFlexibilityNone;
  }
}

@implementation RCTSurfaceHostingProxyRootView

- (instancetype)initWithSurface:(id<RCTSurfaceProtocol>)surface
{
  if (self = [super initWithSurface:surface
                    sizeMeasureMode:RCTSurfaceSizeMeasureModeWidthExact | RCTSurfaceSizeMeasureModeHeightExact]) {
    [surface start];
  }
  return self;
}

RCT_NOT_IMPLEMENTED(-(instancetype)initWithFrame : (CGRect)frame)
RCT_NOT_IMPLEMENTED(-(instancetype)initWithCoder : (NSCoder *)aDecoder)

#pragma mark proxy methods to RCTSurfaceHostingView

- (NSString *)moduleName
{
  return super.surface.moduleName;
}

- (RCTUIView *)view // [macOS]
{
  return (RCTUIView *)super.surface.view; // [macOS]
}

- (RCTUIView *)contentView
{
  return self;
}

- (NSNumber *)reactTag
{
  return super.surface.rootViewTag;
}

- (RCTRootViewSizeFlexibility)sizeFlexibility
{
  return convertToRootViewSizeFlexibility(super.sizeMeasureMode);
}

- (void)setSizeFlexibility:(RCTRootViewSizeFlexibility)sizeFlexibility
{
  super.sizeMeasureMode = convertToSurfaceSizeMeasureMode(sizeFlexibility);
}

- (NSDictionary *)appProperties
{
  return super.surface.properties;
}

- (void)setAppProperties:(NSDictionary *)appProperties
{
  [super.surface setProperties:appProperties];
}

- (RCTUIView *)loadingView // [macOS]
{
  return super.activityIndicatorViewFactory ? super.activityIndicatorViewFactory() : nil;
}

- (void)setLoadingView:(RCTUIView *)loadingView // [macOS]
{
  super.activityIndicatorViewFactory = ^RCTUIView *(void) // [macOS]
  {
    return loadingView;
  };
}

#pragma mark RCTSurfaceDelegate proxying

- (void)surface:(RCTSurface *)surface didChangeStage:(RCTSurfaceStage)stage
{
  [super surface:surface didChangeStage:stage];
  if (RCTSurfaceStageIsRunning(stage)) {
    [_bridge.performanceLogger markStopForTag:RCTPLTTI];
    dispatch_async(dispatch_get_main_queue(), ^{
      [[NSNotificationCenter defaultCenter] postNotificationName:RCTContentDidAppearNotification object:self];
    });
  }
}

- (void)surface:(RCTSurface *)surface didChangeIntrinsicSize:(CGSize)intrinsicSize
{
  [super surface:surface didChangeIntrinsicSize:intrinsicSize];

  [_delegate rootViewDidChangeIntrinsicSize:(RCTRootView *)self];
}

#pragma mark legacy

- (UIViewController *)reactViewController
{
  return _reactViewController ?: [super reactViewController];
}

// [macos
- (void)setMinimumSize:(CGSize)minimumSize
{
  if (CGSizeEqualToSize(_minimumSize, minimumSize)) {
    return;
  }

  _minimumSize = minimumSize;
  __block NSNumber *tag = self.reactTag;
  __weak RCTSurfaceHostingProxyRootView* weakSelf = self;
  RCTExecuteOnUIManagerQueue(^{
    __strong RCTSurfaceHostingProxyRootView* strongSelf = weakSelf;
    if (strongSelf && strongSelf->_bridge.isValid) {
      RCTSurfaceRootShadowView *shadowView = (RCTSurfaceRootShadowView *)[strongSelf->_bridge.uiManager shadowViewForReactTag:tag];
      [shadowView setMinimumSize:minimumSize];
    }
  });
}

- (void)setIntrinsicContentSize:(CGSize)intrinsicContentSize
{
  BOOL oldSizeHasAZeroDimension = _intrinsicContentSize.height == 0 || _intrinsicContentSize.width == 0;
  BOOL newSizeHasAZeroDimension = intrinsicContentSize.height == 0 || intrinsicContentSize.width == 0;
  BOOL bothSizesHaveAZeroDimension = oldSizeHasAZeroDimension && newSizeHasAZeroDimension;

  BOOL sizesAreEqual = CGSizeEqualToSize(_intrinsicContentSize, intrinsicContentSize);

  _intrinsicContentSize = intrinsicContentSize;

  [self invalidateIntrinsicContentSize];
  [self.superview setNeedsLayout:YES];

  // Don't notify the delegate if the content remains invisible or its size has not changed
  if (bothSizesHaveAZeroDimension || sizesAreEqual) {
    return;
  }

  [self invalidateIntrinsicContentSize];
  [self.superview setNeedsLayout:YES];

  [_delegate rootViewDidChangeIntrinsicSize:(RCTRootView *)self];
}
// macos]

#pragma mark unsupported

- (void)cancelTouches
{
  // Not supported.
}

@end
