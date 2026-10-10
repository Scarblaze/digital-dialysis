import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digitaldailysis/data/repository/doctor_repo.dart';
import 'package:digitaldailysis/models/patient/patient_list_model.dart';
import 'package:digitaldailysis/widgets/custom_snackbar.dart';

import '../routes/route_helper.dart';

class DoctorController extends GetxController implements GetxService {
  final DoctorRepo doctorRepo;

  DoctorController({required this.doctorRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PatientModel> _patients = [];
  List<PatientModel> get patients => _patients;

  Future<void> fetchPatients(String doctorId) async {
    _isLoading = true;
    update();

    try {
      final response = await doctorRepo.getPatientsList(doctorId);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          _patients = (decoded['patients'] as List)
              .map((e) => PatientModel.fromJson(e))
              .toList();
        } else {
          customSnackBar("No patients found");
        }
      } else {
        customSnackBar("Failed to load patients (HTTP ${response.statusCode})");
      }
    } catch (e) {
      customSnackBar("Failed to load patients: $e");
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> registerPatient(
      String name, String email, String password, String doctorId) async {
    _isLoading = true;
    update();

    try {
      final response =
          await doctorRepo.postregisterPatient(name, email, password, doctorId);
      Map<String, dynamic>? decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {}

      if (response.statusCode == 200 && decoded?['success'] == true) {
        Get.offNamed(RouteHelper.getDoctorHomeScreen(doctorId));
        Get.snackbar(
          "Success",
          "Patient registered successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          decoded?['message']?.toString() ??
              "Failed to register patient (HTTP ${response.statusCode})",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } finally {
      _isLoading = false;
      update();
    }
  }
}
