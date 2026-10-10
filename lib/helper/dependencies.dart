import 'package:digitaldailysis/controllers/doctor_material_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/doctor_controller.dart';
import '../controllers/login_controller.dart';
import '../data/api/api_client.dart';
import '../data/repository/doctor_repo.dart';
import '../data/repository/login_repo.dart';
import '../utils/app_constants.dart';

Future<void> init() async {
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  Get.put(sharedPreferences, permanent: true);
  Get.put(ApiClient(appBaseUrl: AppConstants.BASE_URL, sharedPreferences: sharedPreferences), permanent: true);

  // Repositories
  Get.put(LoginRepo(apiClient: Get.find()), permanent: true);
  Get.put(DoctorRepo(apiClient: Get.find()), permanent: true);

  // Controllers
  // PatientPanelController (tagged by patientId) is created after login,
  // and PatientInfoController is created by the patient-info route binding.
  Get.put(LoginController(loginRepo: Get.find()), permanent: true);
  Get.put(DoctorController(doctorRepo: Get.find()), permanent: true);
  Get.put(DoctorMaterialController(apiClient: Get.find()), permanent: true);
}
