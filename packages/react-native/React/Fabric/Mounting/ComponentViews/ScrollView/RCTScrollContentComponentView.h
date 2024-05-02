/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <React/RCTUIKit.h> // [macOS]

#import <React/RCTViewComponentView.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCTScrollContentComponentView : RCTViewComponentView

@property (nonatomic, assign, getter=isInverted) BOOL inverted;

@end

NS_ASSUME_NONNULL_END
