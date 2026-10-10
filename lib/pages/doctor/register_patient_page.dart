// lib/pages/doctor/register_patient_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digitaldailysis/controllers/patient_registration_controller.dart';
import 'package:digitaldailysis/data/api/api_client.dart';
import 'package:digitaldailysis/utils/colors.dart';
import 'step1_basic_registration.dart';
import 'step2_medical_profile.dart';
import 'step3_baseline_assessment.dart';

class RegisterPatientPage extends StatelessWidget {
  final String doctorId;

  const RegisterPatientPage({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    // Get ApiClient from GetX dependency injection
    final apiClient = Get.find<ApiClient>();

    // Initialize controller with ApiClient
    final controller = Get.put(
      PatientRegistrationController(apiClient: apiClient),
      tag: 'patient_registration',
    );

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.darkPrimary,
        title: Text(
          "Register New Patient",
          style: TextStyle(
            fontSize: w * 0.05,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Step Indicator
          Obx(() => _buildStepIndicator(controller.currentStep.value, w, h)),

          // Step Content
          Expanded(
            child: Obx(() {
              switch (controller.currentStep.value) {
                case 0:
                  return Step1BasicRegistration(controller: controller, doctorId:doctorId);
                case 1:
                  return Step2MedicalProfile(controller: controller);
                case 2:
                  return Step3BaselineAssessment(controller: controller);
                default:
                  return const SizedBox();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int currentStep, double w, double h) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: h * 0.025, horizontal: w * 0.05),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepCircle(0, currentStep, "Basic", w),
          _buildStepLine(currentStep >= 1, w),
          _buildStepCircle(1, currentStep, "Profile", w),
          _buildStepLine(currentStep >= 2, w),
          _buildStepCircle(2, currentStep, "Assessment", w),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, int currentStep, String label, double w) {
    final isActive = currentStep >= step;
    final isCurrent = currentStep == step;

    return Column(
      children: [
        Container(
          width: w * 0.12,
          height: w * 0.12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.darkPrimary : AppColors.mediumGrey,
            border: Border.all(
              color: isCurrent ? AppColors.darkPrimary : Colors.transparent,
              width: 3,
            ),
          ),
          child: Center(
            child: isActive && !isCurrent
                ? const Icon(Icons.check, color: Colors.white)
                : Text(
              '${step + 1}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: w * 0.045,
              ),
            ),
          ),
        ),
        SizedBox(height: w * 0.015),
        Text(
          label,
          style: TextStyle(
            fontSize: w * 0.03,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.darkPrimary : AppColors.mediumGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive, double w) {
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: w * 0.08),
        color: isActive ? AppColors.darkPrimary : AppColors.mediumGrey,
      ),
    );
  }
}