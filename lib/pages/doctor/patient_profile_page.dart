import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/patient_profile_controller.dart';
import '../../data/api/api_client.dart';

class PatientProfilePage extends StatelessWidget {
  final String patientId;

  const PatientProfilePage({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      PatientProfileController(
        apiClient: Get.find<ApiClient>(),
        patientId: patientId,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Patient Profile")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.profileResponse.value == null) {
          return Center(
            child: Text(
              controller.errorMsg.value.isEmpty
                  ? "No profile data"
                  : controller.errorMsg.value,
            ),
          );
        }

        final p = controller.profileResponse.value!.profile;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🧍 PATIENT HEADER
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(Icons.person, size: 40,
                            color: Colors.blue.shade800),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.crNumber,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text("${p.gender}, ${p.age} yrs"),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _chip(p.bloodGroup, Colors.red),
                                const SizedBox(width: 8),
                                _chip(p.dialysisType, Colors.blue),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// 🩺 MEDICAL SUMMARY
              _card(
                "Medical Summary",
                Icons.medical_information,
                Colors.purple,
                [
                  _info("Primary Diagnosis", p.primaryDiagnosis),
                  _info("Native Kidney Disease", p.nativeKidneyDisease),
                  _info("Comorbidities", p.comorbidities.join(", ")),
                  _info("Allergies", p.allergies.join(", ")),
                ],
              ),

              /// 📞 CONTACT
              _card(
                "Contact",
                Icons.phone,
                Colors.green,
                [
                  _info("Phone", p.contactNumber),
                  _info("Address", p.address),
                ],
              ),

              /// 🚨 EMERGENCY
              Card(
                elevation: 4,
                color: Colors.red.shade50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.emergency, color: Colors.red),
                          const SizedBox(width: 8),
                          const Text(
                            "Emergency Contact",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      const Divider(),
                      _info("Name", p.emergencyContact.name),
                      _info("Relation", p.emergencyContact.relation),
                      _info("Phone", p.emergencyContact.phone),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }


  Widget _card(String title, IconData icon, Color color,
      List<Widget> children) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            ...children
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black54)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
