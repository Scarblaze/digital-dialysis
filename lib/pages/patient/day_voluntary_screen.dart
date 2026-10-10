import 'package:digitaldailysis/routes/route_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/patient_panel_controller.dart';

class DayVoluntaryScreen extends StatelessWidget {
  final String materialSessionId;
  final int dayNumber;
  final String patientId;

  const DayVoluntaryScreen({
    super.key,
    required this.materialSessionId,
    required this.dayNumber,
    required this.patientId
  });

  @override
  Widget build(BuildContext context) {

    final controller = Get.find<PatientPanelController>(tag: patientId);

    return Scaffold(
      appBar: AppBar(title: Text("Day $dayNumber")),
      body: Center(
        child: Obx(() {
          return controller.isLoading.value
              ? CircularProgressIndicator()
              : ElevatedButton(
            onPressed: () async {
              final sessionId =
              await controller.startDialysisDay(materialSessionId);

              if (sessionId != null) {
                Get.toNamed(RouteHelper.getDayDialysisScreen(
                  sessionId,
                  dayNumber,
                  materialSessionId,
                  patientId,
                ));
              }
            },
            child: Text("Start Dialysis"),
          );
        }),
      ),
    );
  }
}
