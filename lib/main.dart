import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'helpers/ad_helper.dart';
import 'helpers/config.dart';
import 'helpers/pref.dart';
import 'screens/splash_screen.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

//global object for accessing device screen size
late Size mq;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //enter full-screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  //firebase initialization
  await Firebase.initializeApp();

  //initializing remote config
  await Config.initConfig();

  await Pref.initializeHive();

  await AdHelper.initAds();

  //for setting orientation to portrait only
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((v) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Root VPN',
      home: SplashScreen(),
      navigatorObservers: [PosthogObserver()],

      //theme
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.red,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 3,
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
      ),

      themeMode: Pref.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      //dark theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
        primarySwatch: Colors.red,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 3,
          backgroundColor: Colors.red.shade900,
        ),
      ),

      debugShowCheckedModeBanner: false,
    );
  }
}

extension AppTheme on ThemeData {
  Color get lightText => Pref.isDarkMode ? Colors.white70 : Colors.black54;
  Color get bottomNav => Pref.isDarkMode ? Colors.white12 : Colors.red;
}
