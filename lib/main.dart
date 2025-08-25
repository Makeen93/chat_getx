import 'package:chat_getx/firebase_options.dart';
import 'package:chat_getx/routes/app_pages.dart';
import 'package:chat_getx/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Chat APP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      // home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
