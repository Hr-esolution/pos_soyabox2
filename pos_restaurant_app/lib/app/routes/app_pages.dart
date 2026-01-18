import 'package:get/get.dart';
import '../../presentation/views/pos/choice_screen.dart';
import '../../presentation/views/pos/table_plan_screen.dart';
import '../../presentation/views/pos/pos_screen.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.CHOICE;

  static final routes = [
    GetPage(
      name: _Paths.CHOICE,
      page: () => const ChoiceScreen(),
    ),
    GetPage(
      name: _Paths.TABLE_PLAN,
      page: () => const TablePlanScreen(),
    ),
    GetPage(
      name: _Paths.POS,
      page: () => const PosScreen(),
    ),
  ];
}