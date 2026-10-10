// lib/controllers/patient_panel_controller.dart
import 'dart:convert';
import 'package:digitaldailysis/widgets/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:digitaldailysis/data/api/api_client.dart';
import 'package:digitaldailysis/models/patient/patient_info_model.dart';

import '../utils/app_constants.dart';

class PatientPanelController extends GetxController  implements GetxService {
  final ApiClient apiClient;
  final String patientId;

  PatientPanelController({required this.apiClient, required this.patientId});

  /// Returns the controller registered for [patientId], creating it if needed.
  /// Registered as permanent so it survives route changes until logout.
  static PatientPanelController ensure(String patientId,
      {ApiClient? apiClient, bool refresh = false}) {
    if (Get.isRegistered<PatientPanelController>(tag: patientId)) {
      final existing = Get.find<PatientPanelController>(tag: patientId);
      if (refresh) existing.fetchSummary();
      return existing;
    }
    return Get.put(
      PatientPanelController(
        apiClient: apiClient ?? Get.find<ApiClient>(),
        patientId: patientId,
      ),
      tag: patientId,
      permanent: true,
    );
  }

  RxBool isLoading = false.obs;
  RxString errorMsg = "".obs;
  // Single material session details (for detail screen)
  Rxn<MaterialSessionResponse> materialSessionDetails = Rxn<MaterialSessionResponse>();


  // Use the model you already have
  Rxn<PatientInfoResponse> summary = Rxn<PatientInfoResponse>();

  @override
  void onInit() {
    super.onInit();
    fetchSummary();
  }

  Future<void> fetchSummary() async {
    try {
      isLoading(true);
      errorMsg("");

      final uri = '${apiClient.appBaseUrl}/api/upload/patient/material-summary';
      final http.Response res = await apiClient.postData(uri, {});

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(res.body);
        print(body);
        // parse into PatientInfoResponse model
        summary.value = PatientInfoResponse.fromJson(body);
      } else {
        errorMsg('Failed to fetch data: ${res.statusCode}');
        print('fetchSummary failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      errorMsg(e.toString());
      print('fetchSummary error: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Acknowledge session endpoint (PATCH in your screenshot — using post/patch as your backend expects)
  Future<bool> acknowledgeSession(String sessionId) async {
    try {
      isLoading(true);
      errorMsg('');

      final uri = '${apiClient.appBaseUrl}/api/upload/acknowledge-material-session';

      // Use PATCH (server expects PATCH as per Postman)
      final http.Response res = await apiClient.patchData(uri, {'sessionId': sessionId});

      print('acknowledge response code: ${res.statusCode}');
      print('acknowledge response body: ${res.body}');

      if (res.statusCode == 200) {
        // refresh data after successful acknowledge
        await fetchSummary();
        return true;
      } else {
        print('acknowledge failed: ${res.statusCode} ${res.body}');
        return false;
      }
    } catch (e) {
      print('acknowledge error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }


  /// START DIALYSIS (NO VOLUNTARY DATA HERE)
  Future<String?> startDialysisDay(String materialSessionId) async {
    try {
      isLoading(true);

      final url = "${AppConstants.BASE_URL}/api/upload/start-dialysis-session";

      final body = {
        "materialSessionId": materialSessionId,
      };

      final response = await apiClient.postData(url, body);

      isLoading(false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sessionId = data["session"]["_id"];
        return sessionId;
      } else {
        customSnackBar("Start dialysis failed");
        return null;
      }
    } catch (e) {
      isLoading(false);
      customSnackBar("Error: $e");
      return null;
    }
  }

  /// FINISH DIALYSIS (VOLUNTARY + TECHNICAL PARAMETERS)
  Future<bool> finishDialysisDay(String sessionId, Map<String, dynamic> formData) async {
    try {
      isLoading(true);

      final url = "${AppConstants.BASE_URL}/api/upload/finish-dialysis-session";

      final body = {
        ...formData
      };
      print("printing dailysis body");
      print(body);

      final response = await apiClient.patchData(url, body);

      isLoading(false);

      if (response.statusCode == 200) {
        print("Complete successfully");
        //customSnackBar("Dialysis Completed Successfully", isError: false);
        return true;
      } else {
        print("Eroorrrr");
        print(response.body);
        customSnackBar("Finish failed: ${response.body}");
        return false;
      }
    } catch (e) {
      isLoading(false);
      customSnackBar("Error: $e");
      return false;
    }
  }
  Future<void> fetchPatientMaterialSummary() async {
    await fetchSummary();  // whatever your existing fetch function is called
  }


  /// UPLOAD IMAGE FOR THIS DAY
  Future<bool> uploadDialysisImage(String sessionId, String filePath) async {
    try {
      final url = "${AppConstants.BASE_URL}/api/upload/upload";

      final response = await apiClient.multipartUpload(
        uri: url,
        filePath: filePath,
        fields: {"sessionId": sessionId},
      );

      if (response.statusCode == 200) {
        print("Uploaded image");
        customSnackBar("Image Uploaded", isError: false);
        return true;
      } else {
        customSnackBar("Image upload failed");
        return false;
      }
    } catch (e) {
      customSnackBar("Error uploading image: $e");
      return false;
    }
  }

  /// Fetch single material session details (PATIENT SIDE)
  Future<void> fetchMaterialSessionDetails(String materialSessionId) async {
    try {
      isLoading(true);
      errorMsg('');

      final uri =
          '${apiClient.appBaseUrl}/api/upload/material/session-details';

      final http.Response res = await apiClient.postData(
        uri,
        {
          "materialSessionId": materialSessionId,
        },
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(res.body);

        if (body['success'] == true) {
          materialSessionDetails.value =
              MaterialSessionResponse.fromJson(body);
        } else {
          errorMsg(body['message'] ?? 'No material session found');
          print('Unexpected response body: $body');
        }
      } else {
        errorMsg('Failed: ${res.statusCode}');
        print(
            'fetchMaterialSessionDetails error ${res.statusCode}: ${res.body}');
      }
    } catch (e, stack) {
      errorMsg('Failed to load session details');
      print('fetchMaterialSessionDetails exception: $e');
      print(stack);
    } finally {
      isLoading(false);
    }
  }

}