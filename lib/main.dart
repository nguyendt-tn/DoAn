import 'package:flutter/material.dart';
import 'package:grammar_app/screens/nav.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
            statusBarColor: Colors.transparent) // Or Brightness.dark
        );
    return MaterialApp(
        home: Nav(),
        builder: EasyLoading.init(),
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
        ));
  }
}
