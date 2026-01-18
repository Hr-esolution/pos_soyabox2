import 'package:get/get.dart';
import '../../presentation/views/pos/choice_screen.dart';
import '../../presentation/views/pos/table_plan_screen.dart';
import '../../presentation/views/pos/pos_screen.dart';
import '../../presentation/controllers/pos/choice_controller.dart';
import '../../presentation/controllers/pos/table_plan_controller.dart';
import '../../presentation/controllers/pos/pos_controller.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.CHOICE;

  static final routes = [
    GetPage(
      name: Routes.CHOICE,
      page: () => const ChoiceScreen(),
      binding: ChoiceBinding(),
    ),
    GetPage(
      name: Routes.TABLE_PLAN,
      page: () => const TablePlanScreen(),
      binding: TablePlanBinding(),
    ),
    GetPage(
      name: Routes.POS,
      page: () => const PosScreen(),
      binding: PosBinding(),
    ),
  ];
}