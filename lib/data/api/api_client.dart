// lib/data/api/api_client.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_constants.dart';
import 'dart:io';

class ApiClient extends GetConnect implements GetxService {
  static const Duration requestTimeout = Duration(seconds: 30);

  late String token;
  final String appBaseUrl;
  late SharedPreferences sharedPreferences;
  late Map<String, String> _mainHeaders;
  Map<String, String> get mainHeaders => _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    baseUrl = appBaseUrl;
    timeout = const Duration(seconds: 30);
    token = sharedPreferences.getString(AppConstants.TOKEN) ?? "";
    _mainHeaders = {
      'Content-type': 'application/json; charset=UTF-8',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  void updateHeader(String token) {
    this.token = token;
    _mainHeaders = {
      'Content-type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    sharedPreferences.setString(AppConstants.TOKEN, token);
  }

  Future<void> clearSession() async {
    token = "";
    _mainHeaders = {'Content-type': 'application/json; charset=UTF-8'};
    await sharedPreferences.remove(AppConstants.TOKEN);
    await sharedPreferences.remove(AppConstants.USER_ROLE);
    await sharedPreferences.remove(AppConstants.USER_ID);
  }

  Future<Response> getData(String uri, {Map<String, String>? headers}) async {
    try {
      Response response = await get(uri, headers: headers ?? _mainHeaders);
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<http.Response> postData(String uri, dynamic body) async {
    try {
      final String jsonBody = jsonEncode(body);

      http.Response response = await http.post(
        Uri.parse(uri),
        body: jsonBody,
        headers: _mainHeaders,
      ).timeout(requestTimeout);

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      return response;
    } catch (e) {
      return http.Response(
        jsonEncode({'message': 'An error occurred', 'error': e.toString()}),
        500,
      );
    }
  }

  Future<http.Response> patchData(String uri, dynamic body) async {
    try {
      final String jsonBody = jsonEncode(body);
      final response = await http
          .patch(Uri.parse(uri), body: jsonBody, headers: _mainHeaders)
          .timeout(requestTimeout);
      return response;
    } catch (e) {
      return http.Response(jsonEncode({'message': 'error', 'error': e.toString()}), 500);
    }
  }


  /// Upload a file using multipart/form-data.
  /// [uri] expects full URL string.
  /// [filePath] local path to file
  /// [fields] additional form fields (e.g. sessionId)
  /// [fileKey] the field name for the file (default 'image')
  Future<http.StreamedResponse> multipartUpload({
    required String uri,
    required String filePath,
    Map<String, String>? fields,
    String fileKey = 'image',
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(uri));

      // add headers (Authorization, etc.). Do not include content-type.
      request.headers.addAll({
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      });

      // add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final file = File(filePath);
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();

      final multipartFile = http.MultipartFile(fileKey, stream, length, filename: file.path.split('/').last);
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      // you can inspect status code, etc.
      return streamedResponse;
    } catch (e) {
      rethrow;
    }
  }
}
