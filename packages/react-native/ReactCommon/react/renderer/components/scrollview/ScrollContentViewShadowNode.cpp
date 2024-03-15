/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include "ScrollContentViewShadowNode.h"

#include <react/debug/react_native_assert.h>
#include <react/renderer/core/LayoutMetrics.h>

namespace facebook::react {

const char ScrollContentViewComponentName[] = "ScrollContentView";

#if TARGET_OS_OSX // [macOS
bool ScrollContentViewShadowNode::getIsVerticalAxisFlipped() const {
  return getConcreteProps().inverted;
}
#endif // macOS]

} // namespace facebook::react
