// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include "HostPlatformViewProps.h"

#include <react/renderer/components/view/conversions.h>
#include <react/renderer/components/view/propsConversions.h>
#include <react/renderer/components/view/HostPlatformConversions.h>
#include <react/renderer/core/graphicsConversions.h>
#include <react/utils/CoreFeatures.h>

namespace facebook::react {

HostPlatformViewProps::HostPlatformViewProps(
    const PropsParserContext& context,
    const HostPlatformViewProps& sourceProps,
    const RawProps& rawProps)
    : macOSViewEvents(
          CoreFeatures::enablePropIteratorSetter 
              ? sourceProps.macOSViewEvents
              : convertRawProp(context, rawProps, sourceProps.macOSViewEvents, {})),
      focusable(
          CoreFeatures::enablePropIteratorSetter
              ? sourceProps.focusable
              : convertRawProp(context, rawProps, "focusable", sourceProps.focusable, {})),
      enableFocusRing(
          CoreFeatures::enablePropIteratorSetter
              ? sourceProps.enableFocusRing
              : convertRawProp(context, rawProps, "enableFocusRing", sourceProps.enableFocusRing, true)),
      validKeysDown(
          CoreFeatures::enablePropIteratorSetter
              ? sourceProps.validKeysDown
              : convertRawProp(context, rawProps, "validKeysDown", sourceProps.validKeysDown, {})),
      validKeysUp(
          CoreFeatures::enablePropIteratorSetter
              ? sourceProps.validKeysUp
              : convertRawProp(context, rawProps, "validKeysUp", sourceProps.validKeysUp, {})),
      draggedTypes(
          CoreFeatures::enablePropIteratorSetter
              ? sourceProps.draggedTypes
              : convertRawProp(context, rawProps, "draggedTypes", sourceProps.draggedTypes, {})),
      tooltip(
          CoreFeatures::enablePropIteratorSetter
              ? sourceProps.tooltip
              : convertRawProp(context, rawProps, "tooltip", sourceProps.tooltip, {})){};

#define VIEW_EVENT_CASE_MACOS(eventType, eventString) \
  case CONSTEXPR_RAW_PROPS_KEY_HASH(eventString): {   \
    MacOSViewEvents defaultViewEvents{};              \
    bool res = defaultViewEvents[eventType];          \
    if (value.hasValue()) {                           \
      fromRawValue(context, value, res);              \
    }                                                 \
    macOSViewEvents[eventType] = res;                 \
    return;                                           \
  }

void HostPlatformViewProps::setProp(
    const PropsParserContext& context,
    RawPropsPropNameHash hash,
    const char* propName,
    RawValue const& value) {
  // All Props structs setProp methods must always, unconditionally,
  // call all super::setProp methods, since multiple structs may
  // reuse the same values.
  BaseViewProps::setProp(context, hash, propName, value);

  static auto defaults = HostPlatformViewProps{};

  switch (hash) {
    VIEW_EVENT_CASE_MACOS(MacOSViewEvents::Offset::KeyDown, "onKeyDown");
    VIEW_EVENT_CASE_MACOS(MacOSViewEvents::Offset::KeyUp, "onKeyUp");
    VIEW_EVENT_CASE_MACOS(MacOSViewEvents::Offset::MouseEnter, "onMouseEnter");
    VIEW_EVENT_CASE_MACOS(MacOSViewEvents::Offset::MouseLeave, "onMouseLeave");
    VIEW_EVENT_CASE_MACOS(MacOSViewEvents::Offset::DoubleClick, "onDoubleClick");
    RAW_SET_PROP_SWITCH_CASE_BASIC(focusable);
    RAW_SET_PROP_SWITCH_CASE_BASIC(enableFocusRing);
    RAW_SET_PROP_SWITCH_CASE_BASIC(validKeysDown);
    RAW_SET_PROP_SWITCH_CASE_BASIC(validKeysUp);
    RAW_SET_PROP_SWITCH_CASE_BASIC(draggedTypes);
    RAW_SET_PROP_SWITCH_CASE_BASIC(tooltip);
    RAW_SET_PROP_SWITCH_CASE_BASIC(cursor);
  }
}

} // namespace facebook::react
