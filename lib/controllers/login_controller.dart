import 'dart:convert';
import 'package:digitaldailysis/controllers/patient_panel_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../data/repository/login_repo.dart';
import '../routes/route_helper.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_snackbar.dart';

class LoginController extends GetxController implements GetxService {
  final LoginRepo loginRepo;

  LoginController({required this.loginRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> login(String loginId, String password) async {
    print("Inside login function");
    if (loginId.isEmpty || password.isEmpty) {
      customSnackBar("Please enter your Login ID and password");
      return;
    }

    _isLoading = true;
    update();

    http.Response response;
    try {
      response = await loginRepo.login(loginId, password);
    } catch (e) {
      _isLoading = false;
      update();
      print("Loing error: $e");
      customSnackBar("Login Network error: $e");
      return;
    }
    print("Inside login function: Loggedin successfully");

    _isLoading = false;
    update();

    print("Login Status: ${response.statusCode}");
    print("Login Response: ${response.body}");

    // Backend may return a non-JSON body (e.g. Vercel "FUNCTION_INVOCATION_FAILED" page)
    Map<String, dynamic>? data;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {}

    if (response.statusCode == 200 && data != null) {
      final Map user = data['user'] is Map ? data['user'] : {};
      final role = (user['role'] ?? data['role'] ?? '').toString();
      final token = (data['token'] ?? '').toString();

      if (token.isEmpty) {
        customSnackBar("No token found in response");
        return;
      }

      // get user id (robust to _id or id)
      final userId = (user['id'] ?? user['_id'] ?? '').toString();
      if (userId.isEmpty) {
        customSnackBar("No user id returned by server");
        return;
      }

      // Persist session; updateHeader also stores the token
      loginRepo.apiClient.updateHeader(token);
      final prefs = loginRepo.apiClient.sharedPreferences;
      await prefs.setString(AppConstants.USER_ROLE, role);
      await prefs.setString(AppConstants.USER_ID, userId);

      if (!openHome(role, userId)) {
        customSnackBar("Invalid role received");
        print("Login returned unexpected role: $role");
      }
    } else if (response.statusCode == 401 || response.statusCode == 400) {
      customSnackBar(data?['message']?.toString() ?? "Invalid credentials");
    } else if (response.statusCode >= 500) {
      final detail = data?['error'] ?? data?['message'];
      customSnackBar(detail != null
          ? "Server error (${response.statusCode}): $detail"
          : "Server is unavailable (HTTP ${response.statusCode}). Please try again later.");
    } else {
      final msg = (data?['message'] ?? data?['error'] ?? '').toString();
      customSnackBar(msg.isNotEmpty
          ? msg
          : "Something went wrong (HTTP ${response.statusCode}).");
    }
  }

  /// Navigates to the home screen for [role]. Returns false for an unknown role.
  bool openHome(String role, String userId) {
    if (role == 'doctor') {
      Get.offAllNamed(RouteHelper.getDoctorHomeScreen(userId));
      return true;
    }
    if (role == 'patient') {
      PatientPanelController.ensure(userId,
          apiClient: loginRepo.apiClient, refresh: true);
      Get.offAllNamed(RouteHelper.getPatientHomeScreen(userId));
      return true;
    }
    return false;
  }

  /// Opens the saved user's home screen if a session exists. Returns false otherwise.
  bool restoreSession() {
    final prefs = loginRepo.apiClient.sharedPreferences;
    final token = prefs.getString(AppConstants.TOKEN) ?? '';
    final role = prefs.getString(AppConstants.USER_ROLE) ?? '';
    final userId = prefs.getString(AppConstants.USER_ID) ?? '';
    if (token.isEmpty || userId.isEmpty) return false;
    return openHome(role, userId);
  }

  Future<void> logout() async {
    final userId =
        loginRepo.apiClient.sharedPreferences.getString(AppConstants.USER_ID) ??
            '';
    if (Get.isRegistered<PatientPanelController>(tag: userId)) {
      Get.delete<PatientPanelController>(tag: userId, force: true);
    }
    await loginRepo.apiClient.clearSession();
    Get.offAllNamed(RouteHelper.getLoginPage());
  }
}
