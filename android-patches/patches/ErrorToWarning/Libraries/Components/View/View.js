diff --git a/Libraries/Components/View/View.js b/Libraries/Components/View/View.js
index 42da7a9215e..f8355eef6fd 100644
--- a/Libraries/Components/View/View.js
+++ b/Libraries/Components/View/View.js
@@ -29,11 +29,12 @@ const View: React.AbstractComponent<
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
