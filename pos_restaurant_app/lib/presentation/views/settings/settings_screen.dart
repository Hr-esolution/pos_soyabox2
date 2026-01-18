import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.put(SettingsController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Langue'.tr,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Obx(() => DropdownButtonFormField<String>(
              value: controller.currentLanguage.value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: 'fr',
                  child: Text('Français'.tr),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English'.tr),
                ),
                DropdownMenuItem(
                  value: 'ar',
                  child: Text('العربية'.tr),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.changeLanguage(newValue);
                }
              },
            )),
            const SizedBox(height: 30),
            Text(
              'Son'.tr,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Obx(() => SwitchListTile(
              title: Text('Activer le son'.tr),
              value: controller.isSoundEnabled.value,
              onChanged: (bool value) {
                controller.toggleSound();
              },
              secondary: Icon(
                controller.isSoundEnabled.value 
                  ? Icons.volume_up 
                  : Icons.volume_off,
                color: controller.isSoundEnabled.value 
                  ? Colors.green 
                  : Colors.red,
              ),
            )),
            const SizedBox(height: 30),
            Text(
              'Imprimante'.tr,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.print),
              title: Text('Configurer l\'imprimante'.tr),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implémenter la configuration de l'imprimante
                Get.snackbar(
                  'Info'.tr,
                  'Fonctionnalité d\'impression à implémenter'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}