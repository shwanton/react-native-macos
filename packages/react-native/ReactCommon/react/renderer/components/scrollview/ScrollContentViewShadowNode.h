/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

#include <react/renderer/components/rncore/Props.h>
#include <react/renderer/components/view/ConcreteViewShadowNode.h>
#include <react/renderer/core/LayoutContext.h>

namespace facebook {
namespace react {

extern const char ScrollContentViewComponentName[];

/*
 * `ShadowNode` for <ScrollContentView> component.
 */
class ScrollContentViewShadowNode final : public ConcreteViewShadowNode<
                                       ScrollContentViewComponentName,
                                       ScrollContentViewProps> {
 public:
  using ConcreteViewShadowNode::ConcreteViewShadowNode;
};

} // namespace react
} // namespace facebook
