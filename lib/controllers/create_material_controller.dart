// lib/controllers/create_material_controller.dart
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:digitaldailysis/data/api/api_client.dart';
import 'package:image_picker/image_picker.dart';

class CreateMaterialController extends GetxController {
  final String doctorId;
  final String patientId;

  CreateMaterialController({required this.doctorId, required this.patientId});

  var isSubmitting = false.obs;
  var errorMsg = ''.obs;

  late ApiClient apiClient;

  @override
  void onInit() {
    super.onInit();
    apiClient = Get.find<ApiClient>();
  }

  /// Start (create) a PD material session on server. Returns the created session _id
  Future<String?> startMaterialSession({
    required int sessionsCount,
    required int transferSet,
    required Map<String, int> capdFluids,
    required Map<String, int> apdFluids,
    required int icodextrin2L,
    required int minicap,
    required Map<String, dynamic>? others,
    String? notes,
  }) async {
    try {
      isSubmitting.value = true;
      errorMsg.value = '';

      final uri = '${apiClient.appBaseUrl}/api/upload/start-material-session';
      final body = {
        'patientId': patientId,
        'sessionsCount': sessionsCount,
        'pdMaterials': {
          'transferSet': transferSet,
          'capd': capdFluids,
          'apd': apdFluids,
          'icodextrin2L': icodextrin2L,
          'minicap': minicap,
          'others': others,
        },
        'notes': notes ?? '',
      };

      final http.Response res = await apiClient.postData(uri, body);

      if (res.statusCode == 200) {
        final Map<String, dynamic> parsed = jsonDecode(res.body);
        if (parsed['success'] == true && parsed['session'] != null) {
          final session = parsed['session'];
          // server returns session object with _id or id
          final id = session['_id'] ??
              session['id'] ??
              session['materialSessionId'] ??
              session['materialSessionId'];
          return id?.toString();
        } else {
          errorMsg.value = 'Unexpected response from server';
          print('startMaterialSession unexpected: $parsed');
          return null;
        }
      } else {
        errorMsg.value = 'Server error ${res.statusCode}';
        print('startMaterialSession failed: ${res.statusCode} ${res.body}');
        return null;
      }
    } catch (e) {
      errorMsg.value = 'Failed to start session: $e';
      print('startMaterialSession err: $e');
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Upload a single image file for given session _id.
  Future<bool> uploadMaterialImage({
    required String sessionId,
    required XFile imageFile,
  }) async {
    try {
      final uploadUrl =
      Uri.parse('${apiClient.appBaseUrl}/api/upload/upload');

      // Read image bytes - works on both web and mobile
      final bytes = await imageFile.readAsBytes();

      // Create multipart request
      final request = http.MultipartRequest('POST', uploadUrl);
      request.fields['sessionId'] = sessionId;

      // Add authorization header if your API requires it
      final token = apiClient.token;
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
        ),
      );

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('uploadMaterialImage success');
        return true;
      } else {
        print('uploadMaterialImage failed: ${response.statusCode} -> $body');
        errorMsg.value = 'Upload failed: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      print('uploadMaterialImage err: $e');
      errorMsg.value = 'Upload error: $e';
      return false;
    }
  }

  /// Complete flow: start session -> upload images list -> return created materialSessionId
  Future<String?> createAndUpload({
    required int sessionsCount,
    required int transferSet,
    required Map<String, int> capdFluids,
    required Map<String, int> apdFluids,
    required int icodextrin2L,
    required int minicap,
    required Map<String, dynamic>? others,
    String? notes,
    List<XFile>? imageFiles,
  }) async {
    isSubmitting.value = true;
    errorMsg.value = '';
    try {
      final sessionId = await startMaterialSession(
        sessionsCount: sessionsCount,
        transferSet: transferSet,
        capdFluids: capdFluids,
        apdFluids: apdFluids,
        icodextrin2L: icodextrin2L,
        minicap: minicap,
        others: others,
        notes: notes,
      );

      if (sessionId == null) {
        errorMsg.value = 'Failed to create session';
        return null;
      }

      // Upload selected images if any
      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (final imageFile in imageFiles) {
          final ok = await uploadMaterialImage(
            sessionId: sessionId,
            imageFile: imageFile,
          );
          if (!ok) {
            print('Image upload failed for ${imageFile.name}');
          }
        }
      }

      return sessionId;
    } finally {
      isSubmitting.value = false;
    }
  }
}