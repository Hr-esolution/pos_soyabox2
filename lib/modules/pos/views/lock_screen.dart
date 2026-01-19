import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LockScreen extends StatefulWidget {
  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final AuthController authController = Get.find();
  String enteredPin = '';
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());

  @override
  void initState() {
    super.initState();
    // Request focus on the first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onDigitPressed(String digit) {
    if (enteredPin.length < 6) {
      setState(() {
        enteredPin += digit;
        
        // Update the corresponding text field
        int currentIndex = enteredPin.length - 1;
        if (currentIndex < 6) {
          _controllers[currentIndex].text = digit;
          
          // Move focus to next field
          if (currentIndex < 5) {
            FocusScope.of(context).requestFocus(_focusNodes[currentIndex + 1]);
          }
        }
      });

      // Check if PIN is complete
      if (enteredPin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (enteredPin.isNotEmpty) {
      int lastIndex = enteredPin.length - 1;
      setState(() {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
        
        // Clear the last field
        if (lastIndex < 6) {
          _controllers[lastIndex].clear();
          
          // Move focus back to previous field
          if (lastIndex > 0) {
            FocusScope.of(context).requestFocus(_focusNodes[lastIndex - 1]);
          }
        }
      });
    }
  }

  Future<void> _verifyPin() async {
    bool isValid = await authController.verifyPin(enteredPin);
    if (isValid) {
      authController.unlock();
      Get.offAllNamed('/choice');
    } else {
      // Show error and reset
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PIN incorrect. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        enteredPin = '';
        for (var controller in _controllers) {
          controller.clear();
        }
        FocusScope.of(context).requestFocus(_focusNodes[0]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[900]!,
                Colors.blue[900]!,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo/App Title
              Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  child: Icon(
                    Icons.lock,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              
              // Title
              Text(
                'Entrez votre PIN',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              SizedBox(height: 40),
              
              // PIN Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    width: 50,
                    height: 60,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      readOnly: true, // We control the input through buttons
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              
              SizedBox(height: 60),
              
              // Number Pad
              Container(
                width: 300,
                child: Column(
                  children: [
                    // First Row
                    _buildNumberPadRow(['1', '2', '3']),
                    SizedBox(height: 15),
                    
                    // Second Row
                    _buildNumberPadRow(['4', '5', '6']),
                    SizedBox(height: 15),
                    
                    // Third Row
                    _buildNumberPadRow(['7', '8', '9']),
                    SizedBox(height: 15),
                    
                    // Fourth Row (0 and Delete)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNumberPadButton('0', 0, 120),
                        _buildDeleteButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNumberPadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((digit) => 
        _buildNumberPadButton(digit, double.parse(digit).toInt(), 80)
      ).toList(),
    );
  }
  
  Widget _buildNumberPadButton(String digit, int value, double width) {
    return SizedBox(
      width: width,
      height: 60,
      child: ElevatedButton(
        onPressed: () => _onDigitPressed(digit),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          digit,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Widget _buildDeleteButton() {
    return SizedBox(
      width: 80,
      height: 60,
      child: ElevatedButton(
        onPressed: _onDeletePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withOpacity(0.2),
          foregroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Icon(
          Icons.backspace,
          size: 24,
        ),
      ),
    );
  }
}