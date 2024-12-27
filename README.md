# JamNode
 An app where people can display their music profiles, including instruments/vocal skills. It allows people to start 'jam session' so as to find people to jam with.<br>
<br>
## Tech Stack
<table>
  <tr>
    <td align='center'>
      <a href="https://www.dartlang.org/"> <img width='36' height='36' src='https://img.stackshare.io/service/1646/Twitter-02.png' alt='Dart'> </a>
      <br>
      <sub></sub>
    </td>
    <td align='center'>
      <a href="https://flutter.io/"> <img width='36' height='36' src='https://img.stackshare.io/service/7180/flutter-mark-square-100.png' alt='Flutter'> </a>
      <br>
      <sub></sub>
    </td>
    <td align='center'>
      <a href="https://firebase.google.com/"><img width='36' height='36' src='https://img.stackshare.io/service/116/cZLxNFZS.jpg' alt='Firebase'> </a>
      <br>
      <sub></sub>
    </td>
  </tr>
</table>

## Development
1. Download the [Flutter Development Kit](https://docs.flutter.dev/get-started/install).
2. For instructions on how to install watch:
   1. [Windows Setup](https://www.youtube.com/watch?v=qAeEdaiK7hM)
   2. [Mac Setup](https://www.youtube.com/watch?v=d_yOKQt7BdY)
   3. [Ubuntu Setup](https://www.youtube.com/watch?v=d_yOKQt7BdY)
3. Navigate to the folder you want to create the flutter project.
4. Using terminal, create new project:
   ```sh
   flutter create <project-name>
   ```
5. Replace the existing `lib` folder in the newly created flutter project with the [lib](https://github.com/ar3s-nd/SnapShop/tree/main/lib) folder of this repo.
6. Replace the `pubspec.yaml` with the [pubspec.yaml](https://github.com/ar3s-nd/SnapShop/blob/main/pubspec.yaml) of this repo or add the dependencies and assets list in the file.
7. To verify configurations, run:
   ```sh
   flutter doctor -v
   ```
8. Setup [firebase](https://firebase.google.com/docs), [firebase auth](https://firebase.google.com/docs/auth) and [cloud firestore](https://firebase.google.com/docs/firestore).
9. For debugging, run the following on the command-line:
   ```sh
   flutter clean
   flutter pub get
   flutter run
   ```

10. For any queries, see [flutter docs](https://docs.flutter.dev/)
11. For deployment, see [deploy flutter](https://docs.flutter.dev/deployment)

## App Installation
1. Download the apk file [JamNode](https://github.com/ar3s-nd/JamNode/blob/main/chattz_app/JamNode.apk) on your android device.
2. Install the apk from the downloads folder.
3. Give permission for system to download `files from unknown sources`.
4. Wait for app to install.

## Dependencies
<table>
  <tr>
    <td>
      <a href="https://pub.dev/packages/cupertino_icons">Cupertino Icons</a>
    </td>
    <td>Asset repo containing the default set of icon assets used by Flutter's <a href = 'https://github.com/flutter/flutter/tree/master/packages/flutter/lib/src/cupertino'>Cupertino widgets</a>.</td>
  </tr>
  
  <tr>
    <td>
      <a href="https://pub.dev/packages/firebase_core">Firebase Core</a>
    </td>
    <td>A Flutter plugin to use the Firebase Core API, which enables connecting to multiple Firebase apps.</td>
  </tr>
  
  <tr>
    <td>
      <a href="https://pub.dev/packages/firebase_auth">Firebase Authentication</a>
    </td>
    <td>A Flutter plugin to use the <a href = "https://firebase.google.com/products/auth">Firebase Authentication API</a>.</td>
  </tr>

  <tr>
    <td>
      <a href="https://pub.dev/packages/cloud_firestore">Cloud Firestore</a>
    </td>
    <td>A Flutter plugin to use the <a href = 'https://firebase.google.com/docs/firestore/'>Cloud Firestore API</a> to manage realtime database.</td>
  </tr>
  
  <tr>
    <td>
      <a href="https://pub.dev/packages/intl">intl</a>
    </td>
    <td>Provides internationalization and localization facilities, including message translation, plurals and genders, date/number formatting and parsing, and bidirectional text.</td>
  </tr>
  
  <tr>
    <td>
      <a href="https://pub.dev/packages/smooth_page_indicator">Smooth Page Indicator</a>
    </td>
    <td>SmoothPageIndicator is a Flutter package that provides a set of animated page indicators with a variety of effects.</td>
  </tr>

  
  <tr>
    <td>
      <a href="https://pub.dev/packages/flutter_login">Flutter Login</a>
    </td>
    <td>FlutterLogin is a ready-made login/signup widget with many animation effects to demonstrate the capabilities of Flutter.</td>
  </tr>

  <tr>
    <td>
      <a href="https://pub.dev/packages/lottie">Lottie</a>
    </td>
    <td>Lottie is a mobile library for Android and iOS that parses <a href = 'https://www.adobe.com/products/aftereffects.html'>Adobe After Effects</a> animations exported as json with Bodymovin and renders them natively on mobile.</td>
  </tr>

  <tr>
    <td>
      <a href="https://pub.dev/packages/liquid_pull_to_refresh">Liquid Pull to Refresh</a>
    </td>
    <td>A beautiful and custom refresh indicator for flutter</td>
  </tr>

  <tr>
    <td>
      <a href="https://pub.dev/packages/flutter_carousel_slider">Flutter Carousel Slider</a>
    </td>
    <td>A customizable carousel slider for flutter.</td>
  </tr>

  <tr>
    <td>
      <a href="https://pub.dev/packages/avatar_glow">Avatar Glow</a>
    </td>
    <td>An Avatar Glow Flutter Widget with cool background glowing animation.</td>
  </tr>

  <tr>
    <td>
      <a href="https://pub.dev/packages/shimmer">Shimmer</a>
    </td>
    <td>Easily add staggered animations to your ListView, GridView, Column and Row children as shown in <a href = 'https://material.io/design/motion/customization.html#sequencing'>Material Design guidelines</a>.</td>
  </tr>
</table> 

## Contributors
[Navaneeth D](https://github.com/ar3s-nd/)
