import 'dart:async';
import 'package:get/get.dart';
import '../models/user.dart';
import '../services/local_database.dart';
import '../constants/app_constants.dart';

class SessionController extends GetxController {
  final LocalDatabase _localDb = LocalDatabase();
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isLocked = true.obs; // Start locked
  final Rx<DateTime?> _lastActivity = Rx<DateTime?>(null);
  
  User? get currentUser => _currentUser.value;
  bool get isLocked => _isLocked.value;
  Timer? _lockTimer;

  @override
  void onInit() {
    super.onInit();
    _startLockTimer();
  }

  @override
  void onClose() {
    _lockTimer?.cancel();
    super.onClose();
  }

  void _startLockTimer() {
    _lockTimer?.cancel();
    _lastActivity.value = DateTime.now();
    
    _lockTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_lastActivity.value != null) {
        final now = DateTime.now();
        final diff = now.difference(_lastActivity.value!).inMinutes;
        
        if (diff >= AppConstants.lockTimeout.inMinutes && !_isLocked.value) {
          lockSession();
        }
      }
    });
  }

  Future<bool> unlockWithPin(String pin) async {
    if (currentUser != null && currentUser!.pin == pin) {
      _isLocked.value = false;
      _lastActivity.value = DateTime.now();
      return true;
    }
    
    // Check in local database as well
    final user = await _localDb.getUserByPin(pin);
    if (user != null) {
      _currentUser.value = user;
      _isLocked.value = false;
      _lastActivity.value = DateTime.now();
      return true;
    }
    
    return false;
  }

  void lockSession() {
    _isLocked.value = true;
  }

  void updateLastActivity() {
    _lastActivity.value = DateTime.now();
  }

  void setCurrentUser(User? user) {
    _currentUser.value = user;
    if (user != null) {
      _isLocked.value = false;
      updateLastActivity();
    } else {
      _isLocked.value = true;
    }
  }
}