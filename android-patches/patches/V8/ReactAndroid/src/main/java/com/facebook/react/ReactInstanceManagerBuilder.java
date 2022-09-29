--- "\\ReactAndroid\\src\\main\\java\\com\\facebook\\react\\ReactInstanceManagerBuilder.java"	2022-09-29 15:47:40.515043600 -0700
+++ "\\ReactAndroid\\src\\main\\java\\com\\facebook\\react\\ReactInstanceManagerBuilder.java"	2022-09-29 15:57:50.948475300 -0700
@@ -34,6 +34,8 @@
 import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler;
 import com.facebook.react.packagerconnection.RequestHandler;
 import com.facebook.react.uimanager.UIImplementationProvider;
+import com.facebook.react.v8executor.V8ExecutorFactory;
+import com.facebook.react.v8executor.V8Executor;
 import java.util.ArrayList;
 import java.util.List;
 import java.util.Map;
@@ -382,22 +384,15 @@
     // if nothing is specified, use old loading method
     // else load the required engine
     if (jsInterpreter == JSInterpreter.OLD_LOGIC) {
-      try {
-        // If JSC is included, use it as normal
-        initializeSoLoaderIfNecessary(applicationContext);
-        JSCExecutor.loadLibrary();
-        return new JSCExecutorFactory(appName, deviceName);
-      } catch (UnsatisfiedLinkError jscE) {
-        if (jscE.getMessage().contains("__cxa_bad_typeid")) {
-          throw jscE;
-        }
-        HermesExecutor.loadLibrary();
-        return new HermesExecutorFactory();
-      }
+      V8Executor.loadLibrary();
+      return new V8ExecutorFactory(appName, deviceName);
     } else if (jsInterpreter == JSInterpreter.HERMES) {
       HermesExecutor.loadLibrary();
       return new HermesExecutorFactory();
-    } else {
+    } else if(jsInterpreter == JSInterpreter.V8) {
+      V8Executor.loadLibrary();
+      return new V8ExecutorFactory(appName, deviceName);
+     } else {
       JSCExecutor.loadLibrary();
       return new JSCExecutorFactory(appName, deviceName);
     }
