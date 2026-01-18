import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  var isSoundEnabled = true.obs;
  var currentLanguage = 'fr'.obs; // Langue par défaut: français

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isSoundEnabled.value = prefs.getBool('sound_enabled') ?? true;
    currentLanguage.value = prefs.getString('language') ?? 'fr';
  }

  Future<void> toggleSound() async {
    isSoundEnabled.toggle();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', isSoundEnabled.value);
  }

  Future<void> changeLanguage(String languageCode) async {
    currentLanguage.value = languageCode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    
    // Changer la langue de l'application
    Get.updateLocale(Locale(languageCode));
  }
}