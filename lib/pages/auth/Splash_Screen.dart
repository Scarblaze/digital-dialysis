import 'package:digitaldailysis/controllers/login_controller.dart';
import 'package:digitaldailysis/routes/route_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      // Go straight to the home screen if a previous login was saved
      if (!Get.find<LoginController>().restoreSession()) {
        Get.offNamed(RouteHelper.getLoginPage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'images/aiims_logo-removebg-preview.png',
              height: size.height * 0.25,
              width: size.width * 0.5,
              fit: BoxFit.contain,
            ),

            SizedBox(height: size.height * 0.03),

            // Title text
            Text(
              "All India Institute of Medical Sciences\nNagpur",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange.shade700,
              ),
            ),

            SizedBox(height: size.height * 0.02),

            // Subtitle / tagline
            Text(
              "स्वास्थ्य सर्वार्थसाधनम्",
              style: TextStyle(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),

            SizedBox(height: size.height * 0.05),

            // Loading indicator
            SizedBox(
              height: size.height * 0.05,
              width: size.height * 0.05,
              child: const CircularProgressIndicator(
                color: Colors.deepOrange,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
