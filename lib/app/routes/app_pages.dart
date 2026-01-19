import 'package:get/get.dart';
import '../../modules/pos/views/lock_screen.dart';
import '../../modules/pos/views/choice_screen.dart';
import '../../modules/pos/views/fulfillment_type_screen.dart';
import '../../modules/pos/views/tables_plan_screen.dart';
import '../../modules/pos/views/new_order_page.dart';

class AppPages {
  static const initial = Routes.lock;

  static final routes = [
    GetPage(
      name: Routes.lock,
      page: () => LockScreen(),
    ),
    GetPage(
      name: Routes.choice,
      page: () => ChoiceScreen(),
    ),
    GetPage(
      name: Routes.fulfillmentType,
      page: () => FulfillmentTypeScreen(),
    ),
    GetPage(
      name: Routes.tablesPlan,
      page: () => TablesPlanScreen(),
    ),
    GetPage(
      name: Routes.newOrder,
      page: () => NewOrderPage(),
    ),
  ];
}

class Routes {
  static const lock = '/lock';
  static const choice = '/choice';
  static const fulfillmentType = '/fulfillment-type';
  static const tablesPlan = '/tables-plan';
  static const newOrder = '/new-order';
}