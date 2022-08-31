diff --git a/Libraries/Components/View/View.js b/Libraries/Components/View/View.js
index 42da7a9215e..7f0358257a7 100644
--- a/Libraries/Components/View/View.js
+++ b/Libraries/Components/View/View.js
@@ -13,6 +13,7 @@ import type {ViewProps} from './ViewPropTypes';
 import ViewNativeComponent from './ViewNativeComponent';
 import TextAncestor from '../../Text/TextAncestor';
 import * as React from 'react';
+import warnOnce from '../../Utilities/warnOnce';
 import invariant from 'invariant'; // TODO(macOS GH#774)
 
 export type Props = ViewProps;
@@ -29,11 +30,12 @@ const View: React.AbstractComponent<
   React.ElementRef<typeof ViewNativeComponent>,
 > = React.forwardRef((props: ViewProps, forwardedRef) => {
   // [TODO(macOS GH#774)
-  invariant(
-    // $FlowFixMe Wanting to catch untyped usages
-    props.acceptsKeyboardFocus === undefined,
-    'Support for the "acceptsKeyboardFocus" property has been removed in favor of "focusable"',
-  );
+  if (props.acceptsKeyboardFocus !== undefined) {
+    warnOnce(
+      'deprecated-acceptsKeyboardFocus',
+      '"acceptsKeyboardFocus" has been deprecated in favor of "focusable" and will be removed soon',
+    );
+  }
   // TODO(macOS GH#774)]
   return (
     <TextAncestor.Provider value={false}>
