/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RCTEnhancedScrollView.h"
#import <React/RCTUtils.h>
#import <React/RCTScrollableProtocol.h>
#import <React/RCTAutoInsetsProtocol.h>

@interface RCTEnhancedScrollView () <
#if !TARGET_OS_OSX // [macOS]
    UIScrollViewDelegate
#else // [macOS
    RCTScrollableProtocol, RCTAutoInsetsProtocol
#endif // macOS]
>
@end

@implementation RCTEnhancedScrollView {
#if !TARGET_OS_OSX // [macOS]
  __weak id<UIScrollViewDelegate> _publicDelegate;
#else// [macOS
  __weak id<RCTScrollableProtocol, RCTAutoInsetsProtocol> _publicDelegate;
#endif // macOS]
  BOOL _isSetContentOffsetDisabled;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
  if ([key isEqualToString:@"delegate"]) {
    // For `delegate` property, we issue KVO notifications manually.
    // We need that to block notifications caused by setting the original `UIScrollView`s property.
    return NO;
  }

  return [super automaticallyNotifiesObserversForKey:key];
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
#if !TARGET_OS_OSX // [macOS]
    // We set the default behavior to "never" so that iOS
    // doesn't do weird things to UIScrollView insets automatically
    // and keeps it as an opt-in behavior.
    self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;

    // We intentionally force `UIScrollView`s `semanticContentAttribute` to `LTR` here
    // because this attribute affects a position of vertical scrollbar; we don't want this
    // scrollbar flip because we also flip it with whole `UIScrollView` flip.
    self.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;

    __weak __typeof(self) weakSelf = self;
    _delegateSplitter = [[RCTGenericDelegateSplitter alloc] initWithDelegateUpdateBlock:^(id delegate) {
      [weakSelf setPrivateDelegate:delegate];
    }];
    [_delegateSplitter addDelegate:self];
#else // [macOS
    self.hasHorizontalScroller = YES;
    self.hasVerticalScroller = YES;
    self.autohidesScrollers = YES;
#endif // macOS]
  }

  return self;
}

#if TARGET_OS_OSX // [macOS
- (void)setFrame:(NSRect)frame
{
  // Preserving and revalidating `contentOffset`.
  CGPoint originalOffset = self.contentOffset;

  [super setFrame:frame];

  UIEdgeInsets contentInset = self.contentInset;
  CGSize contentSize = self.contentSize;

  // If contentSize has not been measured yet we can't check bounds.
  if (CGSizeEqualToSize(contentSize, CGSizeZero)) {
    self.contentOffset = originalOffset;
  } else {
    CGSize boundsSize = self.bounds.size;
    CGFloat xMaxOffset = contentSize.width - boundsSize.width + contentInset.right;
    CGFloat yMaxOffset = contentSize.height - boundsSize.height + contentInset.bottom;
    // Make sure offset doesn't exceed bounds. This can happen on screen rotation.
    if ((originalOffset.x >= -contentInset.left) && (originalOffset.x <= xMaxOffset) &&
        (originalOffset.y >= -contentInset.top) && (originalOffset.y <= yMaxOffset)) {
      return;
    }
    self.contentOffset = CGPointMake(
        MAX(-contentInset.left, MIN(xMaxOffset, originalOffset.x)),
        MAX(-contentInset.top, MIN(yMaxOffset, originalOffset.y)));
  }
}

- (BOOL)isFlipped
{
  return !self.inverted;
}

- (NSSize)contentSize
{
  if (!self.documentView) {
    return [super contentSize];
  }
  
  return self.documentView.frame.size;
}
#endif // macos]

- (void)preserveContentOffsetWithBlock:(void (^)())block
{
  if (!block) {
    return;
  }

  _isSetContentOffsetDisabled = YES;
  block();
  _isSetContentOffsetDisabled = NO;
}

/*
 * Automatically centers the content such that if the content is smaller than the
 * ScrollView, we force it to be centered, but when you zoom or the content otherwise
 * becomes larger than the ScrollView, there is no padding around the content but it
 * can still fill the whole view.
 */
- (void)setContentOffset:(CGPoint)contentOffset
{
  if (_isSetContentOffsetDisabled) {
    return;
  }

  if (_centerContent && !CGSizeEqualToSize(self.contentSize, CGSizeZero)) {
#if !TARGET_OS_OSX // [macOS]
    CGSize scrollViewSize = self.bounds.size;
#else // [macOS
    CGSize scrollViewSize = self.contentView.bounds.size;
#endif // macOS]
    if (self.contentSize.width <= scrollViewSize.width) {
      contentOffset.x = -(scrollViewSize.width - self.contentSize.width) / 2.0;
    }
    if (self.contentSize.height <= scrollViewSize.height) {
      contentOffset.y = -(scrollViewSize.height - self.contentSize.height) / 2.0;
    }
  }

#if !TARGET_OS_OSX // [macOS]
  super.contentOffset = CGPointMake(
      RCTSanitizeNaNValue(contentOffset.x, @"scrollView.contentOffset.x"),
      RCTSanitizeNaNValue(contentOffset.y, @"scrollView.contentOffset.y"));
#else // [macOS
  if (!NSEqualPoints(contentOffset, self.documentVisibleRect.origin)) {
    [self.contentView scrollToPoint:contentOffset];
    [self reflectScrolledClipView:self.contentView];
  }
#endif // macOS]
}

#if TARGET_OS_OSX // [macOS
- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
  if (animated) {
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.3];
    [[self.contentView animator] setBoundsOrigin:contentOffset];
    [NSAnimationContext endGrouping];
  } else {
    self.contentOffset = contentOffset;
  } 
}

- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated
{
  [self magnifyToFitRect:rect];
}

- (void)flashScrollIndicators
{
  [self flashScrollers];
}
#endif // macOS]

#if !TARGET_OS_OSX // [macOS]
- (BOOL)touchesShouldCancelInContentView:(RCTUIView *)view // [macOS]
{
  if ([_overridingDelegate respondsToSelector:@selector(touchesShouldCancelInContentView:)]) {
    return [_overridingDelegate touchesShouldCancelInContentView:view];
  }

  return [super touchesShouldCancelInContentView:view];
}

#pragma mark - RCTGenericDelegateSplitter

- (void)setPrivateDelegate:(id<UIScrollViewDelegate>)delegate
{
  [super setDelegate:delegate];
}

- (id<UIScrollViewDelegate>)delegate
{
  return _publicDelegate;
}

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate
{
  if (_publicDelegate == delegate) {
    return;
  }

  if (_publicDelegate) {
    [_delegateSplitter removeDelegate:_publicDelegate];
  }

  [self willChangeValueForKey:@"delegate"];
  _publicDelegate = delegate;
  [self didChangeValueForKey:@"delegate"];

  if (_publicDelegate) {
    [_delegateSplitter addDelegate:_publicDelegate];
  }
}

#endif // [macOS]

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(RCTUIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset // [macOS]
{
  if (self.snapToOffsets && self.snapToOffsets.count > 0) {
    // An alternative to enablePaging and snapToInterval which allows setting custom
    // stopping points that don't have to be the same distance apart. Often seen in
    // apps which feature horizonally scrolling items. snapToInterval does not enforce
    // scrolling one interval at a time but guarantees that the scroll will stop at
    // a snap offset point.

    // Find which axis to snap
    BOOL isHorizontal = [self isHorizontal:scrollView];
    CGFloat velocityAlongAxis = isHorizontal ? velocity.x : velocity.y;
    CGFloat offsetAlongAxis = isHorizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y;

    // Calculate maximum content offset
    CGSize viewportSize = self.bounds.size;
    CGFloat maximumOffset = isHorizontal ? MAX(0, scrollView.contentSize.width - viewportSize.width)
                                         : MAX(0, scrollView.contentSize.height - viewportSize.height);

    // Calculate the snap offsets adjacent to the initial offset target
    CGFloat targetOffset = isHorizontal ? targetContentOffset->x : targetContentOffset->y;
    CGFloat smallerOffset = 0.0;
    CGFloat largerOffset = maximumOffset;

    for (unsigned long i = 0; i < self.snapToOffsets.count; i++) {
      CGFloat offset = [[self.snapToOffsets objectAtIndex:i] floatValue];

      if (offset <= targetOffset) {
        if (targetOffset - offset < targetOffset - smallerOffset) {
          smallerOffset = offset;
        }
      }

      if (offset >= targetOffset) {
        if (offset - targetOffset < largerOffset - targetOffset) {
          largerOffset = offset;
        }
      }
    }

    // Calculate the nearest offset
    CGFloat nearestOffset = targetOffset - smallerOffset < largerOffset - targetOffset ? smallerOffset : largerOffset;

    CGFloat firstOffset = [[self.snapToOffsets firstObject] floatValue];
    CGFloat lastOffset = [[self.snapToOffsets lastObject] floatValue];

    // if scrolling after the last snap offset and snapping to the
    // end of the list is disabled, then we allow free scrolling
    if (!self.snapToEnd && targetOffset >= lastOffset) {
      if (offsetAlongAxis >= lastOffset) {
        // free scrolling
      } else {
        // snap to end
        targetOffset = lastOffset;
      }
    } else if (!self.snapToStart && targetOffset <= firstOffset) {
      if (offsetAlongAxis <= firstOffset) {
        // free scrolling
      } else {
        // snap to beginning
        targetOffset = firstOffset;
      }
    } else if (velocityAlongAxis > 0.0) {
      targetOffset = largerOffset;
    } else if (velocityAlongAxis < 0.0) {
      targetOffset = smallerOffset;
    } else {
      targetOffset = nearestOffset;
    }

    // Make sure the new offset isn't out of bounds
    targetOffset = MIN(MAX(0, targetOffset), maximumOffset);

    // Set new targetContentOffset
    if (isHorizontal) {
      targetContentOffset->x = targetOffset;
    } else {
      targetContentOffset->y = targetOffset;
    }
  } else if (self.snapToInterval) {
    // An alternative to enablePaging which allows setting custom stopping intervals,
    // smaller than a full page size. Often seen in apps which feature horizonally
    // scrolling items. snapToInterval does not enforce scrolling one interval at a time
    // but guarantees that the scroll will stop at an interval point.
    CGFloat snapToIntervalF = (CGFloat)self.snapToInterval;

    // Find which axis to snap
    BOOL isHorizontal = [self isHorizontal:scrollView];

    // What is the current offset?
    CGFloat velocityAlongAxis = isHorizontal ? velocity.x : velocity.y;
    CGFloat targetContentOffsetAlongAxis = targetContentOffset->y;
    if (isHorizontal) {
      // Use current scroll offset to determine the next index to snap to when momentum disabled
      targetContentOffsetAlongAxis = self.disableIntervalMomentum ? scrollView.contentOffset.x : targetContentOffset->x;
    } else {
      targetContentOffsetAlongAxis = self.disableIntervalMomentum ? scrollView.contentOffset.y : targetContentOffset->y;
    }

    // Offset based on desired alignment
    CGFloat frameLength = isHorizontal ? self.frame.size.width : self.frame.size.height;
    CGFloat alignmentOffset = 0.0f;
    if ([self.snapToAlignment isEqualToString:@"center"]) {
      alignmentOffset = (frameLength * 0.5f) + (snapToIntervalF * 0.5f);
    } else if ([self.snapToAlignment isEqualToString:@"end"]) {
      alignmentOffset = frameLength;
    }

    // Pick snap point based on direction and proximity
    CGFloat fractionalIndex = (targetContentOffsetAlongAxis + alignmentOffset) / snapToIntervalF;

    NSInteger snapIndex = velocityAlongAxis > 0.0 ? ceil(fractionalIndex)
        : velocityAlongAxis < 0.0                 ? floor(fractionalIndex)
                                                  : round(fractionalIndex);
    CGFloat newTargetContentOffset = ((CGFloat)snapIndex * snapToIntervalF) - alignmentOffset;

    // Set new targetContentOffset
    if (isHorizontal) {
      targetContentOffset->x = newTargetContentOffset;
    } else {
      targetContentOffset->y = newTargetContentOffset;
    }
  }
}

#pragma mark -

- (BOOL)isHorizontal:(RCTUIScrollView *)scrollView // [macOS]
{
  return scrollView.contentSize.width > self.frame.size.width;
}

@end
