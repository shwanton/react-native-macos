/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <React/RCTComponent.h>
#import <React/RCTEventDispatcher.h> // [macOS]

#import <React/RCTUIKit.h> // [macOS]

NS_ASSUME_NONNULL_BEGIN

@interface RCTTextView : RCTUIView // [macOS]

- (instancetype)initWithEventDispatcher:(id<RCTEventDispatcherProtocol>)eventDispatcher; // [macOS]

@property (nonatomic, assign) BOOL selectable;
#if TARGET_OS_OSX // [macOS
@property (nonatomic, strong) NSArray<NSMenuItem *> *additionalMenuItems;
#endif // macOS]

- (void)setTextStorage:(NSTextStorage *)textStorage
          contentFrame:(CGRect)contentFrame
       descendantViews:(NSArray<RCTPlatformView *> *)descendantViews; // [macOS]

/**
 * (Experimental and unused for Paper) Pointer event handlers.
 */
@property (nonatomic, assign) RCTBubblingEventBlock onClick;

@end

NS_ASSUME_NONNULL_END
