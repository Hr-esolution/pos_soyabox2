import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pos/choice_controller.dart';

class ChoiceScreen extends StatelessWidget {
  const ChoiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChoiceController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SoYaBox POS'),
        centerTitle: true,
        backgroundColor: const Color(0xFFc92a2a), // Pantone 2025 red
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFc92a2a), Color(0xFFff6b6b)], // Red to pink gradient
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Choose Service Type',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 50),
                _buildServiceButton(
                  context,
                  'Sur place',
                  'On-site',
                  'في المكان',
                  Icons.local_dining,
                  () {
                    controller.setSelectedFulfillmentType('surplace');
                    controller.goToTablePlan();
                  },
                ),
                const SizedBox(height: 20),
                _buildServiceButton(
                  context,
                  'À emporter',
                  'Take away',
                  'ل带走',
                  Icons.shopping_bag,
                  () {
                    controller.setSelectedFulfillmentType('emporter');
                    controller.goToPosScreen();
                  },
                ),
                const SizedBox(height: 20),
                _buildServiceButton(
                  context,
                  'Livraison',
                  'Delivery',
                  'توصيل',
                  Icons.delivery_dining,
                  () {
                    controller.setSelectedFulfillmentType('livraison');
                    controller.goToPosScreen();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceButton(
    BuildContext context,
    String frenchText,
    String englishText,
    String arabicText,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFc92a2a),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Color(0xFFc92a2a), width: 2),
          ),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, size: 30),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    frenchText,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    englishText,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    arabicText,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}