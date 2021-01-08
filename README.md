Create React Native App with Native Project
===

###### tags: `ReactNative`

# Android

因為新的專案載入FB套件需要用到 androidX 所以直接更新 Android Studio 到 4.x 版開新的的專案

## Create Native java Project

change configuration if gradle build failed:

```
implementation 'com.android.support:appcompat-v7:+'
```

react native use `minSdkVersion 16`. we have to update this part.

## Create Project Structure

- move android project to /android folder.
- create package.json. excue `npm init`

```json
{
  "name": "android-java-source",
  "version": "1.0.0",
  "description": "create react project by native android",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "Edmond,Wu",
  "license": "ISC"
}
```

## Add React Native to project

Add React native
```
yarn add react-native
```

Add React

```
yarn add react@version_printed_above
```

> version_printed_above 會叫你選要使用的版本號，可以看一下剛剛安裝 react-native 時下載的版本
> ex: 
> ├─ react-devtools-core@4.10.1
> ├─ react-is@16.13.1 <== 選這個版本
> ├─ react-native@0.63.4

## Add React Native to Native App

**build.gradle** : add following configurations
```
dependencies {
    // implementation "com.android.support:appcompat-v7:27.1.1"
    implementation "com.android.support:appcompat-v7:+"
    ...
    implementation "com.facebook.react:react-native:+" // From node_modules
    implementation "org.webkit:android-jsc:+"
}
```

**build.gradle** : add following configurations

```
repositories {
        maven {
            // All of React Native (JS, Android binaries) is installed from npm
            url "$rootDir/../node_modules/react-native/android"
        }
        maven {
            // Android JSC is installed from npm
            url("$rootDir/../node_modules/jsc-android/dist")
        }
        ...
    }
```

接著是個 Gradle Sync 一次：

但是出現下面的錯誤

```
Attribute application@appComponentFactory value=(android.support.v4.app.CoreComponentFactory) from [com.android.support:support-compat:28.0.0] AndroidManifest.xml:22:18-91
	is also present at [androidx.core:core:1.0.1] AndroidManifest.xml:22:18-86 value=(androidx.core.app.CoreComponentFactory).
	Suggestion: add 'tools:replace="android:appComponentFactory"' to <application> element at AndroidManifest.xml:5:5-19:19 to override.
```

這是因為 Android X 不相容

Add following cinfig to gradle.properties:

```
android.useAndroidX=true
android.enableJetifier=true
```

## Add auto link

**settings.gradle**

```
apply from: file("../node_modules/@react-native-community/cli-platform-android/native_modules.gradle"); applyNativeModulesSettingsGradle(settings)
```

**app/build.gradle**

加在有 dependencies 的那個檔案

```
apply from: file("../../node_modules/@react-native-community/cli-platform-android/native_modules.gradle"); applyNativeModulesAppBuildGradle(project)
```

## Configuring permissions

**AndroidManifest.xml**

```xml
<uses-permission android:name="android.permission.INTERNET" />
```
If you need to access to the DevSettingsActivity add to your **AndroidManifest.xml**:

<activity android:name="com.facebook.react.devsupport.DevSettingsActivity" />

## Cleartext Traffic (API level 28+)

設定聯網的部分，允許 app 連網路

**AndroidManifest.xml**

```
android:usesCleartextTraffic="true" tools:targetApi="28"
```

you may add following string to the top to enable tools.

```
xmlns:tools="http://schemas.android.com/tools"
```

## Create React Native files

1. add `index.js`

2. add react code:

```javascript
import React from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View
} from 'react-native';

class HelloWorld extends React.Component {
  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.hello}>Hello, World</Text>
      </View>
    );
  }
}
var styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center'
  },
  hello: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10
  }
});

AppRegistry.registerComponent(
  'MyReactNativeApp',
  () => HelloWorld
);
```

3. Configure permissions for development error overlay

add following code in **onCreate** method of activity.

```java
import android.os.Build;
import android.content.Intent;
import android.net.Uri;
import android.provider.Settings;

private final int OVERLAY_PERMISSION_REQ_CODE = 1;  // Choose any value

...

if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
    if (!Settings.canDrawOverlays(this)) {
        Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                   Uri.parse("package:" + getPackageName()));
        startActivityForResult(intent, OVERLAY_PERMISSION_REQ_CODE);
    }
}
```

```java
import com.facebook.react.ReactInstanceManager;

@Override
protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    if (requestCode == OVERLAY_PERMISSION_REQ_CODE) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!Settings.canDrawOverlays(this)) {
                // SYSTEM_ALERT_WINDOW permission not granted
            }
        }
    }
    mReactInstanceManager.onActivityResult( this, requestCode, resultCode, data );
}

```

**ReactRootView**

MyReactActivity 下的東西可以放在任何 Activity 中，記得對應 AndroidManifest.xml 中的內容

github 的專案事都先放在 MainActivity 中做測試

```java
public class MyReactActivity extends Activity implements DefaultHardwareBackBtnHandler {
    private ReactRootView mReactRootView;
    private ReactInstanceManager mReactInstanceManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        SoLoader.init(this, false);

        mReactRootView = new ReactRootView(this);
        List<ReactPackage> packages = new PackageList(getApplication()).getPackages();
        // Packages that cannot be autolinked yet can be added manually here, for example:
        // packages.add(new MyReactNativePackage());
        // Remember to include them in `settings.gradle` and `app/build.gradle` too.

        mReactInstanceManager = ReactInstanceManager.builder()
                .setApplication(getApplication())
                .setCurrentActivity(this)
                .setBundleAssetName("index.android.bundle")
                .setJSMainModulePath("index")
                .addPackages(packages)
                .setUseDeveloperSupport(BuildConfig.DEBUG)
                .setInitialLifecycleState(LifecycleState.RESUMED)
                .build();
        // The string here (e.g. "MyReactNativeApp") has to match
        // the string in AppRegistry.registerComponent() in index.js
        mReactRootView.startReactApplication(mReactInstanceManager, "MyReactNativeApp", null);

        setContentView(mReactRootView);
    }

    @Override
    public void invokeDefaultOnBackPressed() {
        super.onBackPressed();
    }
}
```

> 以上如果要 working 可以直接都加在 MainActivity 跑跑看

## Add Activity to MainActivityMainfest

如果是另外創的要記得加進去

```xml
<activity
  android:name=".MyReactActivity"
  android:label="@string/app_name"
  android:theme="@style/Theme.AppCompat.Light.NoActionBar">
</activity>
```

## Add LiftCycle Event

```java
@Override
protected void onPause() {
    super.onPause();

    if (mReactInstanceManager != null) {
        mReactInstanceManager.onHostPause(this);
    }
}

@Override
protected void onResume() {
    super.onResume();

    if (mReactInstanceManager != null) {
        mReactInstanceManager.onHostResume(this, this);
    }
}

@Override
protected void onDestroy() {
    super.onDestroy();

    if (mReactInstanceManager != null) {
        mReactInstanceManager.onHostDestroy(this);
    }
    if (mReactRootView != null) {
        mReactRootView.unmountReactApplication();
    }
}
```

**Override back press**

```java
@Override
 public void onBackPressed() {
    if (mReactInstanceManager != null) {
        mReactInstanceManager.onBackPressed();
    } else {
        super.onBackPressed();
    }
}
```

**Add ctl + M (show develop menu)**

```java
@Override
public boolean onKeyUp(int keyCode, KeyEvent event) {
    if (keyCode == KeyEvent.KEYCODE_MENU && mReactInstanceManager != null) {
        mReactInstanceManager.showDevOptionsDialog();
        return true;
    }
    return super.onKeyUp(keyCode, event);
}
```

## Completed !

```
yarn start
```

```
npx react-native run-android
```

## Creating a release build in Android Studio

```shell
$ npx react-native bundle --platform android --dev false --entry-file index.js --bundle-output android/com/your-company-name/app-package-name/src/main/assets/index.android.bundle --assets-dest android/com/your-company-name/app-package-name/src/main/res/
```

## Error

```
./android/gradlew --version
```

Update **gradle-wrapper.properties**
```
distributionUrl=https\://services.gradle.org/distributions/gradle-5.4.1-all.zip
```
