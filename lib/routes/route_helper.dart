// lib/routes/route_helper.dart
import 'package:digitaldailysis/pages/doctor/create_active_material_screen.dart';
import 'package:digitaldailysis/pages/patient/day_dailysis_screen.dart';
import 'package:digitaldailysis/pages/patient/day_voluntary_screen.dart';
import 'package:digitaldailysis/pages/patient/material_session_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:digitaldailysis/pages/auth/LoginPage.dart';
import 'package:digitaldailysis/pages/auth/Splash_Screen.dart';
import 'package:digitaldailysis/pages/doctor/doctor_home_screen.dart';
import 'package:digitaldailysis/pages/patient/patient_home_screen.dart';
import 'package:digitaldailysis/pages/doctor/register_patient_page.dart';

// new imports (use package imports everywhere)
import 'package:digitaldailysis/pages/doctor/patient_info_screen.dart';
import 'package:digitaldailysis/pages/doctor/material_session_details.dart';
import 'package:digitaldailysis/controllers/patient_info_controller.dart';
import 'package:digitaldailysis/controllers/patient_panel_controller.dart';

class RouteHelper {
  // 🔹 Route names
  static const String splashPage = "/splash-page";
  static const String loginPage = "/login-page";
  static const String doctorHomeScreen = "/doctor-home-screen";
  static const String patientHomeScreen = "/patient-home-screen";
  static const String registerPatientScreen = "/register-patient-screen";

  // new routes
  static const String patientInfoScreen = "/patient-info-screen";
  static const String materialSessionDetailScreen = "/material-session-detail-screen";
// Add route constant
  static const String createActiveMaterialScreen = "/create-active-material";

// Add helper
  static String getCreateActiveMaterialScreen(String patientId, String doctorId) =>
      "$createActiveMaterialScreen?patientId=$patientId&doctorId=$doctorId";
  // 🔹 Route builders
  static String getSplashPage() => splashPage;
  static String getLoginPage() => loginPage;
  static String getDoctorHomeScreen(String doctorId) =>
      "$doctorHomeScreen?doctorId=$doctorId";
  static String getPatientHomeScreen(String patientId) => "$patientHomeScreen?patientId=$patientId";
  static String getRegisterPatientScreen(String doctorId) =>
      "$registerPatientScreen?doctorId=$doctorId";

  static String getPatientInfoScreen(String patientId) =>
      "$patientInfoScreen?patientId=$patientId";

  static String getMaterialSessionDetailScreen(String materialSessionId) =>
      "$materialSessionDetailScreen?materialSessionId=$materialSessionId";


  //for patients
  static const String patientMaterialSessionDetails = "/patient-material-details";

  static String getPatientMaterialSessionDetails(
      String sessionId, String patientId) =>
      "$patientMaterialSessionDetails?sessionId=$sessionId&patientId=$patientId";

  static const String dayVoluntaryScreen = "/day-voluntary";
  static const String dayDialysisScreen = "/day-dialysis";

  static String getDayVoluntaryScreen(
      String materialSessionId, int day, String patientId) =>
      "$dayVoluntaryScreen?id=$materialSessionId&day=$day&pid=$patientId";

  static String getDayDialysisScreen(String sessionId, int day,
      String materialSessionId, String patientId) =>
      "$dayDialysisScreen?sid=$sessionId&day=$day&msid=$materialSessionId&pid=$patientId";

  // 🔹 Route list
  static List<GetPage> routes = [
    GetPage(
      name: splashPage,
      page: () => SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: loginPage,
      page: () => LoginPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: doctorHomeScreen,
      page: () {
        var doctorId = Get.parameters['doctorId'];
        return DoctorHomePage(doctorId: doctorId ?? '');
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: patientMaterialSessionDetails,
      page: () {
        final sessionId = Get.parameters["sessionId"] ?? '';
        final patientId = Get.parameters["patientId"] ?? '';
        PatientPanelController.ensure(patientId);
        return MaterialSessionDetailsPage(
          sessionId: sessionId,
          patientId: patientId,
        );
      },
    ),
    GetPage(
      name: registerPatientScreen,
      page: () {
        var doctorId = Get.parameters['doctorId'];
        return RegisterPatientPage(doctorId: doctorId ?? '');
      },
      transition: Transition.fadeIn,
    ),

    // Patient info route with binding (creates controller cleanly)
    GetPage(
      name: patientInfoScreen,
      binding: BindingsBuilder(() {
        final pid = Get.parameters['patientId'] ?? '';

        // remove any previous instance to avoid stale controllers
        if (Get.isRegistered<PatientInfoController>()) {
          Get.delete<PatientInfoController>();
        }
        Get.put(PatientInfoController(patientId: pid));
      }),
      page: () {
        final patientId = Get.parameters['patientId'] ?? '';
        final doctorId = Get.parameters['doctorId'] ?? '';
        return PatientInfoScreen(patientId: patientId, doctorId: doctorId);
      },
      transition: Transition.fadeIn,
    ),

    // optional: route for material session details (we use direct Get.to with object, but included if you prefer named route)
    GetPage(
      name: materialSessionDetailScreen,
      page: () {
        // if using named route, you'll pass the MaterialSession via arguments or fetch by id
        final msArg = Get.arguments;
        if (msArg is Map && msArg['materialSession'] != null) {
          // return MaterialSessionDetailScreen(materialSession: msArg['materialSession'], patientId: '',);
          return MaterialSessionDetailScreen( patientId: '',);
        }
        // fallback empty page
        return Scaffold(body: Center(child: Text("No session provided")));
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: createActiveMaterialScreen,
      page: () {
        final patientId = Get.parameters['patientId'] ?? '';
        final doctorId = Get.parameters['doctorId'] ?? '';
        return CreateActiveMaterialScreen(doctorId: doctorId, patientId: patientId);
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: patientHomeScreen,
      page: () {
        final pid = Get.parameters['patientId'] ?? '';
        PatientPanelController.ensure(pid);
        return PatientHomeScreen(patientId: pid);
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: dayVoluntaryScreen,
      page: () {
        final pid = Get.parameters['pid'] ?? '';
        PatientPanelController.ensure(pid);
        return DayVoluntaryScreen(
          materialSessionId: Get.parameters['id'] ?? '',
          dayNumber: int.tryParse(Get.parameters['day'] ?? '') ?? 1,
          patientId: pid,
        );
      },
    ),
    GetPage(
      name: dayDialysisScreen,
      page: () {
        final pid = Get.parameters['pid'] ?? '';
        PatientPanelController.ensure(pid);
        return DayDialysisScreen(
          patientId: pid,
          sessionId: Get.parameters['sid'] ?? '',
          dayNumber: int.tryParse(Get.parameters['day'] ?? '') ?? 1,
          MaterialSessionId: Get.parameters['msid'] ?? '',
        );
      },
    ),
  ];
}
