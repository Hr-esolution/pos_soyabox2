import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'app/routes/app_pages.dart';
import 'app/bindings/app_binding.dart';
import 'app/theme/app_theme.dart';
import 'services/local_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Isar
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [IsarUserSchema, IsarSyncOperationSchema],
    directory: dir.path,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'POS Soyabox',
      initialBinding: AppBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
