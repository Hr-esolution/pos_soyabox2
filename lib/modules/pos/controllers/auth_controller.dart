import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthController extends GetxController {
  var isLocked = true.obs;
  
  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    String? storedHash = prefs.getString('pin_hash');
    
    if (storedHash == null) {
      // No PIN set, allow access
      return true;
    }
    
    String inputHash = sha256.convert(utf8.encode(pin)).toString();
    return inputHash == storedHash;
  }
  
  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    String hash = sha256.convert(utf8.encode(pin)).toString();
    await prefs.setString('pin_hash', hash);
  }
  
  Future<bool> hasPinSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('pin_hash');
  }
  
  void lock() {
    isLocked.value = true;
  }
  
  void unlock() {
    isLocked.value = false;
  }
}