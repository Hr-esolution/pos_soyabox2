import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app/routes/app_pages.dart';
import 'localization/locale_keys.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "SoYaBox POS",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('fr', 'FR'),
        Locale('ar', 'MA'), // Morocco Arabic variant
      ],
      locale: const Locale('fr', 'FR'), // Default to French
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: const Color(0xFFc92a2a), // Pantone 2025 red
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}