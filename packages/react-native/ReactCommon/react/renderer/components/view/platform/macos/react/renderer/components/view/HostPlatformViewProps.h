// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#pragma once

#include <react/renderer/components/view/BaseViewProps.h>
#include <react/renderer/components/view/HostPlatformTypes.h>
#include <react/renderer/core/PropsParserContext.h>
#include <react/renderer/components/view/MacOSViewEvents.h>
#include <react/renderer/components/view/KeyEvent.h>

namespace facebook::react {
class HostPlatformViewProps : public BaseViewProps {
 public:
  HostPlatformViewProps() = default;
  HostPlatformViewProps(
      const PropsParserContext &context,
      const HostPlatformViewProps &sourceProps,
      const RawProps &rawProps);

  void
  setProp(const PropsParserContext &context, RawPropsPropNameHash hash, const char *propName, RawValue const &value);

  MacOSViewEvents macOSViewEvents{};
  
  bool enableFocusRing{true};
  bool focusable{false};

  std::optional<std::vector<HandledKey>> validKeysDown{};
  std::optional<std::vector<HandledKey>> validKeysUp{};

  std::optional<std::vector<DraggedType>> draggedTypes{};

  std::optional<std::string> tooltip{};
};
} // namespace facebook::react
