/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RCTAccessibilityElement.h"

@implementation RCTAccessibilityElement

- (CGRect)accessibilityFrame
{
  RCTUIView *container = (RCTUIView *)self.accessibilityContainer;
  if (CGRectEqualToRect(_frame, CGRectZero)) {
    return UIAccessibilityConvertFrameToScreenCoordinates(container.bounds, container);
  } else {
    return UIAccessibilityConvertFrameToScreenCoordinates(_frame, container);
  }
}

@end
