## 1.5.0 2023-12-21
* Rename Easing to MpEasing to not conflict with Flutter Easing
* Export most classes in mp_chart so that users only import mp_chart instead of individual classes
* Flutter 3.16 updates
* Upgrade dependencies intl
* Upgrade example app dependencies url_launcher, permission_handler, intl
## 1.4.0 2023-10-27
* Update sdk constraints to >=3.0.0 <4.0.0
* Upgrade dependencies intl, path_provider
* Upgrade example app dependencies url_launcher, permission_handler, cupertino_icons, intl
## 1.3.0 2023-06-11
* Flutter 3.10 updates
* Upgrade dependencies intl, screenshot, permission_handler 
## 1.2.2 2023-06-03
* Upgrade dependencies path_provider, url_launcher
## 1.2.1 2023-03-17
* Flutter 3.7 updates
* Null safety cleanups
* BarLineChartBasePainter getData, getAxisRange getter improvements
* Upgrade dependency vector_math
* Bump sdk constraints to >=2.18.0
## 1.2.0 2023-03-13
* Disable image saver(image_gallery_saver) for now, as it's using a very old kotlin-gradle-plugin
## 1.1.0 2023-03-13
* Upgrade dependencies path_provider, screenshot, url_launcher, permission_handler
## 1.0.0 2022-10-16
* Flutter 3.3 fixes
* Upgrade dependencies path_provider, path_drawing, optimized_gesture_detector
* bump sdk from >=2.12.0 to >=2.17.0
* Example app:
  ** Upgrade dependencies, url_launcher, permission_handler, cupertino_icons
## 0.3.3 2022-05-16
* Flutter 3 fixes.
* Upgrade dependencies path_provider, vector_math.
* Example app:
** Use Uri instead of deprecated String in launchUrl 
** Upgrade dependencies, url_launcher, permission_handler 
## 0.3.2 2022-02-06
* Null safety updates.
* Upgrade dependencies.
## 0.3.1 2020-10-30
* Updated for Flutter 1.22.0 to use updated Dart intl package 0.17.0-nullsafety.1.
## 0.3.0 2020-09-18
* Updated for Flutter 1.22.0 to use update optimized_gesture_detector package.
* 0.3.0 is for Flutter 1.22 and newer prior version 0.2.2 is for pre-Flutter 1.22 versions. 
## 0.2.2 2020-06-27
* in a single scale do not change the scale direction
## 0.2.1 2020-06-07
* add chart control in scrollable view like PageView etc.
## 0.2.0 2020-05-18
* fix chart data's setValueTextSize setValueTypeface not work
## 0.1.9 2020-03-18
* Support trans background
* Support legend text color set
* Fix pie radar chart rotateEnabled no used
* Fix bugs when description is enabled
## 0.1.8 2020-03-08
* Support addEntryByIndex in line scatter bubble candlestick chart
* Support updateEntryByIndex in all chart
## 0.1.7 2020-02-22
* Updated dependency to include vector_math package.
## 0.1.6 2020-02-21
* Copied LICENSE file to mp_chart directory [#66](https://github.com/SunPointed/MPFlutterChart/pull/66).
* Updated .gitignore not show modified or generated files e.g., pubspec.lock, .flutter-plugins-dependencies and ios/Flutter/flutter_export_environment.sh [#66](https://github.com/SunPointed/MPFlutterChart/pull/66).
* Removed any checked in pubspec.lock files [#66](https://github.com/SunPointed/MPFlutterChart/pull/66).