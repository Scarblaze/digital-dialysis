import 'package:digitaldailysis/pages/doctor/create_active_material_screen.dart';
import 'package:digitaldailysis/pages/doctor/material_session_details.dart';
import 'package:digitaldailysis/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digitaldailysis/controllers/patient_info_controller.dart';
import 'package:digitaldailysis/models/patient/patient_info_model.dart';
import 'package:digitaldailysis/pages/doctor/patient_profile_page.dart';
import 'package:intl/intl.dart';

class PatientInfoScreen extends StatelessWidget {
  final String patientId;
  final String doctorId;

  const PatientInfoScreen({
    Key? key,
    required this.patientId,
    required this.doctorId,
  }) : super(key: key);

  String _prettyDate(DateTime date) {
    final day = date.day;
    String suffix = "th";
    if (day == 1 || day == 21 || day == 31) suffix = "st";
    if (day == 2 || day == 22) suffix = "nd";
    if (day == 3 || day == 23) suffix = "rd";

    return "$day$suffix ${DateFormat('MMMM yyyy').format(date)}";
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PatientInfoController>();
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.responseModel.value == null) {
          return const Center(child: Text("No patient data available"));
        }

        final patient = controller.responseModel.value!.patient;
        final sessions = controller.responseModel.value!.materialSessions;

        return CustomScrollView(
          slivers: [
            /// APP BAR
            SliverAppBar(
              expandedHeight: h * 0.26,
              pinned: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  color: AppColors.lightGrey,
                  onPressed: () async {
                    await controller.refresh();
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                   color: AppColors.darkPrimary
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(w * 0.05),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: w * 0.09,
                            backgroundColor: AppColors.white,
                            child: Icon(Icons.person,
                                size: w * 0.09, color: AppColors.darkPrimary),
                          ),
                          SizedBox(width: w * 0.04),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  Get.to(
                                        () => PatientProfilePage(
                                      patientId: patient.id,
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      patient.name,
                                      style: TextStyle(
                                        fontSize: w * 0.06,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.open_in_new,
                                      color: Colors.white70,
                                      size: 18,
                                    )
                                  ],
                                ),
                              ),
                              Text(
                                patient.email,
                                style: TextStyle(
                                  fontSize: w * 0.038,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// CONTENT
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(w * 0.045),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// CREATE SESSION BUTTON
                    _createSessionButton(context, patient.id, w,h),

                    SizedBox(height: h * 0.03),

                    /// HEADER
                    Row(
                      children: [
                        Icon(Icons.history,
                            color: AppColors.darkGrey, size: w * 0.065),
                        SizedBox(width: w * 0.02),
                        Text(
                          "Medical Sessions",
                          style: TextStyle(
                            fontSize: w * 0.055,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: h * 0.02),

                    /// SESSION LIST
                    if (sessions.isEmpty)
                      _emptyState(w, h)
                    else
                      ...sessions
                          .map((s) => _sessionCard(s, w, h))
                          .toList(),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _createSessionButton(
      BuildContext context, String patientId, double w, double h ) {
    return InkWell(
      borderRadius: BorderRadius.circular(w * 0.04),
      onTap: () async {
        final controller = Get.find<PatientInfoController>();

        final result = await Get.to(
              () => CreateActiveMaterialScreen(
            doctorId: doctorId,
            patientId: patientId,
          ),
        );

        if (result == true) {
          controller.refresh();
        }

      },
      child: Container(
        padding: EdgeInsets.all(w * 0.045),
        decoration: BoxDecoration(
          color: AppColors.darkPrimary,
          borderRadius: BorderRadius.circular(w * 0.04),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 12),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.add_circle_outline,
                color: Colors.white, size: 28),
            SizedBox(width: w * 0.04),
            Text(
              "Create New Dialysis Session",
              style: TextStyle(
                fontSize: w * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sessionCard(MaterialSession ms, double w, double h) {
    final created = ms.createdAt?.toLocal();
    final dateText =
    created != null ? _prettyDate(created) : "Session Date";
    final timeText =
    created != null ? DateFormat('hh:mm a').format(created) : "";

    Color color;
    switch (ms.status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'active':
        color = Colors.blue;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      margin: EdgeInsets.only(bottom: h * 0.018),
      padding: EdgeInsets.all(w * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: InkWell(
        onTap: () async {
          final controller = Get.find<PatientInfoController>();

          Get.dialog(
            const Center(child: CircularProgressIndicator()),
            barrierDismissible: false,
          );

          await controller.fetchMaterialSessionDetailsByDoc(
            patientId: patientId,
            materialSessionId: ms.materialSessionId,
          );

          Get.back();

          if (controller.materialSessionDetails.value != null) {
            Get.to(
                  () => MaterialSessionDetailScreen(


                    patientId: patientId,
                    materialSessionId: ms.materialSessionId,
                    patientName: "Alice",
              ),
            );
          } else {
            Get.snackbar(
              'Error',
              controller.materialSessionError.value.isEmpty
                  ? 'Failed to load session details'
                  : controller.materialSessionError.value,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(Icons.event, color: color),
            ),
            SizedBox(width: w * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateText,
                    style: TextStyle(
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: h * 0.005),
                  Text(
                    timeText,
                    style: TextStyle(
                      fontSize: w * 0.035,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.03,
                vertical: h * 0.005,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(w * 0.02),
              ),
              child: Text(
                ms.status.capitalizeFirst!,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _emptyState(double w, double h) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: h * 0.06),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.event_busy, size: w * 0.2, color: Colors.grey[400]),
            SizedBox(height: h * 0.02),
            Text(
              "No sessions yet",
              style: TextStyle(
                fontSize: w * 0.048,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Create a new dialysis session to begin",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
