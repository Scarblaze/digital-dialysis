import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digitaldailysis/controllers/doctor_controller.dart';
import 'package:digitaldailysis/controllers/login_controller.dart';
import 'package:digitaldailysis/routes/route_helper.dart';
import 'package:digitaldailysis/utils/colors.dart';

class DoctorHomePage extends StatefulWidget {
  final String doctorId;

  const DoctorHomePage({super.key, required this.doctorId});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  late DoctorController doctorController;

  @override
  void initState() {
    super.initState();
    doctorController = Get.find<DoctorController>();

    Future.microtask(() {
      doctorController.fetchPatients(widget.doctorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    return Scaffold(
      backgroundColor: AppColors.white,

      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.darkPrimary,
        actions: [
          IconButton(
            tooltip: "Logout",
            icon: const Icon(Icons.logout, color: AppColors.white),
            onPressed: () => Get.find<LoginController>().logout(),
          ),
        ],
        title: Text(
          "My Patients",
          style: TextStyle(
            fontSize: w * 0.05,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.darkPrimary,
        onPressed: () async {
          final result = await Get.toNamed(
            RouteHelper.getRegisterPatientScreen(widget.doctorId),
          );

          if (result == true) {
            doctorController.fetchPatients(widget.doctorId);
          }
        },
        child: Icon(
          Icons.person_add,
          color: AppColors.white,
          size: w * 0.065,
        ),
      ),

      body: GetBuilder<DoctorController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.patients.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "No patients found",
                    style: TextStyle(
                      fontSize: w * 0.04,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => controller.fetchPatients(widget.doctorId),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.05,
              vertical: h * 0.02,
            ),
            child: ListView.builder(
              itemCount: controller.patients.length,
              itemBuilder: (context, index) {
                final patient = controller.patients[index];

                return Container(
                  margin: EdgeInsets.only(bottom: h * 0.02),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(w * 0.04),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mediumGrey.withValues(alpha: 0.3),
                        blurRadius: w * 0.02,
                        offset: Offset(0, h * 0.005),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: w * 0.04,
                      vertical: h * 0.01,
                    ),

                    leading: CircleAvatar(
                      radius: w * 0.07,
                      backgroundColor: AppColors.darkPrimary,
                      child: Icon(
                        Icons.person,
                        color: AppColors.lightPrimary,
                        size: w * 0.07,
                      ),
                    ),

                    title: Text(
                      patient.name,
                      style: TextStyle(
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),

                    subtitle: Text(
                      patient.email,
                      style: TextStyle(
                        fontSize: w * 0.035,
                        color: AppColors.darkGrey,
                      ),
                    ),

                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: w * 0.04,
                      color: AppColors.darkPrimary,
                    ),

                    onTap: () {
                      Get.toNamed(
                        RouteHelper.getPatientInfoScreen(patient.id),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
