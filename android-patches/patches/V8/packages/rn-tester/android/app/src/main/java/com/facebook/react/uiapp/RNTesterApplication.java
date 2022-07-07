diff --git a/packages/rn-tester/android/app/src/main/java/com/facebook/react/uiapp/RNTesterApplication.java b/packages/rn-tester/android/app/src/main/java/com/facebook/react/uiapp/RNTesterApplication.java
index 6d014d9dac..6c4b7663f8 100644
--- a/packages/rn-tester/android/app/src/main/java/com/facebook/react/uiapp/RNTesterApplication.java
+++ b/packages/rn-tester/android/app/src/main/java/com/facebook/react/uiapp/RNTesterApplication.java
@@ -7,10 +7,14 @@
 
 package com.facebook.react.uiapp;
 
+import static com.facebook.react.modules.systeminfo.AndroidInfoHelpers.getFriendlyDeviceName;
+
 import android.app.Application;
 import android.content.Context;
 import androidx.annotation.Nullable;
 import com.facebook.fbreact.specs.SampleTurboModule;
+import com.facebook.hermes.reactexecutor.HermesExecutorFactory;
+import com.facebook.react.jscexecutor.JSCExecutorFactory;
 import com.facebook.react.ReactApplication;
 import com.facebook.react.ReactInstanceManager;
 import com.facebook.react.ReactNativeHost;
@@ -22,6 +26,7 @@ import com.facebook.react.bridge.JSIModuleProvider;
 import com.facebook.react.bridge.JSIModuleSpec;
 import com.facebook.react.bridge.JSIModuleType;
 import com.facebook.react.bridge.JavaScriptContextHolder;
+import com.facebook.react.bridge.JavaScriptExecutorFactory;
 import com.facebook.react.bridge.NativeModule;
 import com.facebook.react.bridge.ReactApplicationContext;
 import com.facebook.react.bridge.UIManager;
@@ -35,6 +40,7 @@ import com.facebook.react.module.model.ReactModuleInfoProvider;
 import com.facebook.react.shell.MainReactPackage;
 import com.facebook.react.uimanager.ViewManagerRegistry;
 import com.facebook.react.views.text.ReactFontManager;
+import com.facebook.react.v8executor.V8ExecutorFactory;
 import com.facebook.soloader.SoLoader;
 import java.lang.reflect.InvocationTargetException;
 import java.util.ArrayList;
@@ -47,6 +53,20 @@ public class RNTesterApplication extends Application implements ReactApplication
 
   private final ReactNativeHost mReactNativeHost =
       new ReactNativeHost(this) {
+        @Override
+        public JavaScriptExecutorFactory getJavaScriptExecutorFactory() {
+          if (BuildConfig.FLAVOR.equals("hermes")) {
+            return new HermesExecutorFactory();
+          } else if (BuildConfig.FLAVOR.equals("v8")) {
+            return new V8ExecutorFactory(getApplication().getPackageName(), getFriendlyDeviceName());
+          } else if (BuildConfig.FLAVOR.equals("jsc")) {
+            SoLoader.loadLibrary("jscexecutor");
+            return new JSCExecutorFactory(getApplication().getPackageName(), getFriendlyDeviceName());
+          } else {
+            throw new IllegalArgumentException("Missing handler in getJavaScriptExecutorFactory for build flavor: " + BuildConfig.FLAVOR);
+          }
+        }
+
         @Override
         public String getJSMainModuleName() {
           return "packages/rn-tester/js/RNTesterApp.android";
