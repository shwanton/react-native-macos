/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RCTScrollContentComponentView.h"

#import <react/renderer/components/rncore/ComponentDescriptors.h>
#import <react/renderer/components/rncore/EventEmitters.h>
#import <react/renderer/components/rncore/Props.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@implementation RCTScrollContentComponentView

 - (instancetype)init
 {
   if (self = [super init]) {
     _props = std::make_shared<ScrollContentViewProps const>();
   }

   return self;
 }

- (void)updateProps:(Props::Shared const&)props oldProps:(Props::Shared const&)oldProps {
  const auto& newViewProps = *std::static_pointer_cast<ScrollContentViewProps const>(props);

  [self setInverted:newViewProps.inverted];

  [super updateProps:props oldProps:oldProps];
}

- (BOOL)isFlipped
{
  return !self.inverted;
}

#pragma mark - RCTComponentViewProtocol

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<ScrollContentViewComponentDescriptor>();
}

Class<RCTComponentViewProtocol> RCTScrollContentViewCls(void)
{
  return RCTScrollContentComponentView.class;
}

@end
